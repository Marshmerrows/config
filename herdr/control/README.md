# Development Control

This repository is the home of a persistent Herdr conductor agent. The conductor turns a task prompt into a named branch, creates an isolated worktree-backed workspace, starts a worker agent, and monitors it.

## Open the Control Workspace

From inside Herdr:

```bash
herdr workspace create --cwd ~/dev/control --label control --focus
```

Start a supported agent in that workspace and ask it to read `AGENTS.md` and act as the conductor.

Example request:

> In skusafe, fix the product search resetting after changing pages. Create an isolated workspace and delegate the implementation.

The conductor should derive a branch such as:

```text
fix/preserve-product-search-pagination
```

and a workspace label such as:

```text
skusafe-preserve-product-search-pagination
```

## Manual Bring-Up

Create and open a worktree-backed workspace:

```bash
herdr worktree create \
  --cwd ~/dev/skusafe \
  --base origin/main \
  --branch fix/preserve-product-search-pagination \
  --label skusafe-preserve-product-search-pagination \
  --focus
```

Herdr returns the new workspace and pane identifiers. Use those returned identifiers rather than predicting them.

List active workspaces and worktrees:

```bash
herdr workspace list
herdr worktree list --cwd ~/dev/skusafe
```

## Manual Teardown

Closing a workspace preserves its checkout and Git branch:

```bash
herdr workspace close <workspace-id>
```

Removing a task worktree removes its checkout and closes its linked Herdr workspace, but preserves the Git branch:

```bash
herdr worktree remove --workspace <workspace-id>
```

Normal removal refuses a dirty checkout. Inspect it before doing anything else:

```bash
git -C <worktree-path> status --short --branch
```

Do not use `--force` unless the changes to be discarded have been shown and destructive removal was explicitly approved. Branch deletion, remote deletion, merging, and pull-request creation are separate explicit actions.
