import { basename, isAbsolute, relative, resolve, sep } from "node:path";
import type { AssistantMessage, Usage } from "@earendil-works/pi-ai";
import type {
  ExtensionAPI,
  ExtensionContext,
  Theme,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const WEATHER_URL = "https://wttr.in/?format=3";
const WEATHER_REFRESH_MS = 15 * 60 * 1000;
const WEATHER_TIMEOUT_MS = 5000;
const GIT_TIMEOUT_MS = 3000;
const ANSI_ESCAPE_PATTERN =
  /\x1b(?:\][^\x07]*(?:\x07|\x1b\\)|\[[0-?]*[ -/]*[@-~])|\u009b[0-?]*[ -/]*[@-~]/g;

type UsageTotals = {
  cost: number;
};

type GitState = {
  branch: string | null;
  dirty: boolean;
  ahead: number;
  behind: number;
};

function formatTokens(count: number): string {
  if (count < 1000) return `${count}`;
  if (count < 10_000) return `${(count / 1000).toFixed(1)}k`;
  if (count < 1_000_000) return `${Math.round(count / 1000)}k`;
  if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
  return `${Math.round(count / 1_000_000)}M`;
}

function formatCwd(cwd: string): string {
  const home = process.env.HOME ?? process.env.USERPROFILE;
  if (!home) return cwd;

  const resolvedCwd = resolve(cwd);
  const resolvedHome = resolve(home);
  const relativeToHome = relative(resolvedHome, resolvedCwd);
  const insideHome =
    relativeToHome === "" ||
    (relativeToHome !== ".." &&
      !relativeToHome.startsWith(`..${sep}`) &&
      !isAbsolute(relativeToHome));

  if (!insideHome) return cwd;
  return relativeToHome === "" ? "~" : `~${sep}${relativeToHome}`;
}

function sanitizeSingleLine(text: string): string {
  return text
    .replace(ANSI_ESCAPE_PATTERN, "")
    .replace(/[\u0000-\u001f\u007f]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function formatMcpFooterStatus(
  theme: Theme,
  status: string | undefined,
): string | undefined {
  if (!status) return undefined;

  const clean = sanitizeSingleLine(status);
  const ratio = clean.match(/\bMCP\s+(\d+)\/(\d+)\b/i);
  if (ratio) return theme.fg("accent", `🔌 ${ratio[1]}/${ratio[2]}`);

  const detail = clean
    .replace(/^🔌\s*/, "")
    .replace(/^MCP:?\s*/i, "");
  return detail ? theme.fg("dim", `🔌 ${detail}`) : undefined;
}

function usageTotalTokens(usage: Usage): number {
  return (
    usage.totalTokens ||
    usage.input + usage.output + usage.cacheRead + usage.cacheWrite
  );
}

function addUsage(totals: UsageTotals, usage: Usage | undefined): void {
  if (usage) totals.cost += usage.cost.total;
}

function getUsageTotals(ctx: ExtensionContext): UsageTotals {
  const totals: UsageTotals = { cost: 0 };

  for (const entry of ctx.sessionManager.getEntries()) {
    if (entry.type === "message" && entry.message.role === "assistant") {
      addUsage(totals, entry.message.usage);
    } else if (
      entry.type === "message" &&
      entry.message.role === "toolResult"
    ) {
      addUsage(totals, entry.message.usage);
    } else if (entry.type === "branch_summary" || entry.type === "compaction") {
      addUsage(totals, entry.usage);
    }
  }

  return totals;
}

function isAssistantMessage(message: unknown): message is AssistantMessage {
  return (
    typeof message === "object" &&
    message !== null &&
    "role" in message &&
    message.role === "assistant" &&
    "usage" in message
  );
}

function isSubscription(ctx: ExtensionContext): boolean {
  const model = ctx.model;
  if (!model) return false;
  if (model.provider === "kimi-coding") return true;

  const provider = ctx.modelRegistry.getProvider(model.provider);
  return (
    ctx.modelRegistry.isUsingOAuth(model) &&
    provider?.auth.oauth?.isSubscription === true
  );
}

function makeBar(percent: number | null, length: number): string {
  const normalized = percent === null ? 0 : Math.max(0, Math.min(100, percent));
  const filled = Math.round((normalized / 100) * length);
  return "█".repeat(filled) + "░".repeat(length - filled);
}

function contextText(
  percent: number | null,
  contextWindow: number,
  barLength: number,
  showWindow: boolean,
): string {
  const percentage = percent === null ? "?%" : `${Math.round(percent)}%`;
  const window =
    showWindow && contextWindow > 0 ? `/${formatTokens(contextWindow)}` : "";
  return `${makeBar(percent, barLength)} ${percentage}${window}`;
}

function styleContext(
  theme: Theme,
  text: string,
  percent: number | null,
): string {
  if (percent !== null && percent > 90) return theme.fg("error", text);
  if (percent !== null && percent > 70) return theme.fg("warning", text);
  return text;
}

function parseGitStatus(output: string): GitState {
  let branch: string | null = null;
  let dirty = false;
  let ahead = 0;
  let behind = 0;

  for (const line of output.split("\n")) {
    if (line.startsWith("# branch.head ")) {
      branch = line.slice("# branch.head ".length).trim();
    } else if (line.startsWith("# branch.ab ")) {
      const match = line.match(/^# branch\.ab \+(\d+) -(\d+)$/);
      if (match) {
        ahead = Number(match[1]);
        behind = Number(match[2]);
      }
    } else if (line && !line.startsWith("# ")) {
      dirty = true;
    }
  }

  return { branch, dirty, ahead, behind };
}

function firstFittingLine(candidates: string[], width: number): string {
  for (const candidate of candidates) {
    if (visibleWidth(candidate) <= width) return candidate;
  }
  return truncateToWidth(candidates.at(-1) ?? "", width, "");
}

function rightAlign(
  width: number,
  left: string,
  right: string,
): string | undefined {
  const leftWidth = visibleWidth(left);
  const rightWidth = visibleWidth(right);
  if (leftWidth + 3 + rightWidth > width) return undefined;
  return left + " ".repeat(width - leftWidth - rightWidth) + right;
}

export default function statusline(pi: ExtensionAPI): void {
  let enabled = true;
  let ctx: ExtensionContext | undefined;
  let requestRender: (() => void) | undefined;
  let thinkingLevel = "off";
  let liveUsage: Usage | undefined;
  let streaming = false;
  let weather: string | undefined;
  let weatherInterval: ReturnType<typeof setInterval> | undefined;
  let weatherRequest: AbortController | undefined;
  let gitState: GitState | undefined;
  let gitRefreshTimer: ReturnType<typeof setTimeout> | undefined;
  let gitRefreshInFlight = false;
  let gitRefreshPending = false;

  const stopWeather = () => {
    if (weatherInterval) clearInterval(weatherInterval);
    weatherInterval = undefined;
    weatherRequest?.abort();
    weatherRequest = undefined;
  };

  const refreshWeather = async () => {
    if (weatherRequest) return;

    const controller = new AbortController();
    weatherRequest = controller;
    const timeout = setTimeout(() => controller.abort(), WEATHER_TIMEOUT_MS);

    try {
      const response = await fetch(WEATHER_URL, {
        headers: { "User-Agent": "pi-statusline" },
        signal: controller.signal,
      });
      if (!response.ok) return;

      const nextWeather = sanitizeSingleLine(await response.text());
      if (nextWeather) {
        weather = nextWeather;
        requestRender?.();
      }
    } catch {
      // Weather is optional; retain the last successful value on failure.
    } finally {
      clearTimeout(timeout);
      if (weatherRequest === controller) weatherRequest = undefined;
    }
  };

  const startWeather = () => {
    stopWeather();
    void refreshWeather();
    weatherInterval = setInterval(
      () => void refreshWeather(),
      WEATHER_REFRESH_MS,
    );
    weatherInterval.unref?.();
  };

  const refreshGit = async () => {
    if (!ctx) return;
    if (gitRefreshInFlight) {
      gitRefreshPending = true;
      return;
    }

    gitRefreshInFlight = true;
    const cwd = ctx.cwd;
    try {
      const result = await pi.exec(
        "git",
        ["status", "--porcelain=v2", "--branch"],
        { cwd, timeout: GIT_TIMEOUT_MS },
      );
      const nextState =
        result.code === 0 ? parseGitStatus(result.stdout) : undefined;
      if (
        ctx?.cwd === cwd &&
        JSON.stringify(nextState) !== JSON.stringify(gitState)
      ) {
        gitState = nextState;
        requestRender?.();
      }
    } catch {
      if (ctx?.cwd === cwd && gitState !== undefined) {
        gitState = undefined;
        requestRender?.();
      }
    } finally {
      gitRefreshInFlight = false;
      if (gitRefreshPending) {
        gitRefreshPending = false;
        void refreshGit();
      }
    }
  };

  const scheduleGitRefresh = (delay = 100) => {
    if (gitRefreshTimer) clearTimeout(gitRefreshTimer);
    gitRefreshTimer = setTimeout(() => {
      gitRefreshTimer = undefined;
      void refreshGit();
    }, delay);
    gitRefreshTimer.unref?.();
  };

  const stopGit = () => {
    if (gitRefreshTimer) clearTimeout(gitRefreshTimer);
    gitRefreshTimer = undefined;
    gitRefreshPending = false;
  };

  const installFooter = (currentCtx: ExtensionContext) => {
    ctx = currentCtx;
    currentCtx.ui.setFooter((tui, theme, footerData) => {
      requestRender = () => tui.requestRender();
      const unsubscribeBranch = footerData.onBranchChange(() => {
        requestRender?.();
        scheduleGitRefresh(0);
      });

      return {
        dispose() {
          unsubscribeBranch();
          requestRender = undefined;
        },
        invalidate() {},
        render(width: number): string[] {
          const safeWidth = Math.max(1, width);
          const model = ctx?.model;
          const providerName = model?.provider ?? "no-provider";
          const modelName = model?.id ?? "no-model";
          const thinking = model?.reasoning ? ` · ${thinkingLevel}` : "";
          const branch = gitState?.branch ?? footerData.getGitBranch();
          const cwd = formatCwd(ctx?.cwd ?? process.cwd());
          const compactCwd = basename(cwd) || cwd;
          const gitParts: string[] = [];
          if (branch) {
            gitParts.push(
              theme.fg("muted", branch) +
                (gitState?.dirty ? theme.fg("warning", "*") : ""),
            );
            if (gitState?.ahead) {
              gitParts.push(theme.fg("accent", `⇡${gitState.ahead}`));
            }
            if (gitState?.behind) {
              gitParts.push(theme.fg("accent", `⇣${gitState.behind}`));
            }
          }

          const project = [theme.fg("accent", cwd), ...gitParts].join(" ");
          const compactProject = [
            theme.fg("accent", compactCwd),
            ...gitParts,
          ].join(" ");
          const weatherText = weather ? theme.fg("dim", weather) : "";
          const projectLine =
            (weatherText
              ? rightAlign(safeWidth, project, weatherText)
              : undefined) ??
            firstFittingLine(
              [project, compactProject, theme.fg("accent", compactCwd)],
              safeWidth,
            );

          const identity = `(${providerName}) ${modelName}${thinking}`;
          const minimalIdentity = `${modelName}${thinking}`;
          const coreUsage = ctx?.getContextUsage();
          const liveTokens =
            streaming && liveUsage ? usageTotalTokens(liveUsage) : undefined;
          const contextWindow =
            coreUsage?.contextWindow ?? model?.contextWindow ?? 0;
          const contextPercent =
            liveTokens !== undefined && contextWindow > 0
              ? (liveTokens / contextWindow) * 100
              : (coreUsage?.percent ?? null);

          const totals = ctx ? getUsageTotals(ctx) : { cost: 0 };
          if (streaming && liveUsage) totals.cost += liveUsage.cost.total;
          const subscription = ctx ? isSubscription(ctx) : false;
          const cost =
            totals.cost > 0 || subscription
              ? theme.fg(
                  "dim",
                  `$${totals.cost.toFixed(3)}${subscription ? " (sub)" : ""}`,
                )
              : undefined;
          const minimalPercent =
            contextPercent === null ? "?%" : `${Math.round(contextPercent)}%`;
          const extensionStatuses = footerData.getExtensionStatuses();
          const mcpStatus = formatMcpFooterStatus(
            theme,
            extensionStatuses.get("mcp"),
          );

          const buildStats = (
            barLength: number,
            showWindow: boolean,
            showCost: boolean,
            showMcp: boolean,
          ) => {
            const context = styleContext(
              theme,
              contextText(contextPercent, contextWindow, barLength, showWindow),
              contextPercent,
            );
            const parts = [identity, context];
            if (showCost && cost) parts.push(cost);
            if (showMcp && mcpStatus) parts.push(mcpStatus);
            return parts.join(" | ");
          };

          const statsLine = firstFittingLine(
            [
              buildStats(20, true, true, true),
              buildStats(10, true, true, true),
              buildStats(10, true, true, false),
              buildStats(10, true, false, false),
              `${identity} | ${minimalPercent}${cost ? ` | ${cost}` : ""}`,
              `${identity} | ${minimalPercent}`,
              `${minimalIdentity} | ${minimalPercent}`,
            ],
            safeWidth,
          );

          const lines = [projectLine, statsLine];
          const genericStatus = Array.from(extensionStatuses.entries())
            .filter(([name]) => name !== "mcp")
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([, text]) => sanitizeSingleLine(text))
            .filter(Boolean)
            .join(" ");
          if (genericStatus) {
            lines.push(truncateToWidth(genericStatus, safeWidth, "..."));
          }

          return lines;
        },
      };
    });
  };

  pi.on("session_start", (_event, currentCtx) => {
    ctx = currentCtx;
    thinkingLevel = pi.getThinkingLevel();
    liveUsage = undefined;
    streaming = false;
    gitState = undefined;
    if (currentCtx.mode === "tui") {
      startWeather();
      scheduleGitRefresh(0);
      if (enabled) installFooter(currentCtx);
    }
  });

  pi.on("session_shutdown", () => {
    stopWeather();
    stopGit();
    requestRender = undefined;
  });

  pi.on("model_select", (_event, currentCtx) => {
    ctx = currentCtx;
    thinkingLevel = pi.getThinkingLevel();
    requestRender?.();
  });

  pi.on("thinking_level_select", (event) => {
    thinkingLevel = event.level;
    requestRender?.();
  });

  pi.on("agent_start", () => {
    streaming = true;
    liveUsage = undefined;
    requestRender?.();
  });

  pi.on("message_update", (event) => {
    if (isAssistantMessage(event.message)) liveUsage = event.message.usage;
    requestRender?.();
  });

  pi.on("message_end", () => {
    streaming = false;
    liveUsage = undefined;
    requestRender?.();
  });

  pi.on("agent_settled", () => scheduleGitRefresh(0));
  pi.on("tool_execution_end", (event) => {
    if (["bash", "edit", "write"].includes(event.toolName)) {
      scheduleGitRefresh();
    }
  });
  pi.on("user_bash", () => scheduleGitRefresh(1000));

  pi.on("session_info_changed", () => requestRender?.());
  pi.on("session_compact", () => requestRender?.());
  pi.on("session_tree", () => requestRender?.());

  pi.registerCommand("statusline", {
    description: "Toggle the custom status line (on, off, or toggle)",
    getArgumentCompletions: (prefix) =>
      ["on", "off", "toggle"]
        .filter((value) => value.startsWith(prefix))
        .map((value) => ({ value, label: value })),
    handler: async (args, currentCtx) => {
      const action = args.trim().toLowerCase() || "toggle";
      if (!["on", "off", "toggle"].includes(action)) {
        currentCtx.ui.notify("Usage: /statusline [on|off|toggle]", "warning");
        return;
      }

      enabled = action === "toggle" ? !enabled : action === "on";
      if (enabled) installFooter(currentCtx);
      else currentCtx.ui.setFooter(undefined);
      currentCtx.ui.notify(`statusline → ${enabled ? "on" : "off"}`, "info");
    },
  });
}
