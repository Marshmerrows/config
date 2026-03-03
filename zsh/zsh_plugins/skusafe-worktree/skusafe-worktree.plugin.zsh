# skusafe-worktree: show worktree URL on Pure's ❯ line
#
# Uses psvar[13] — same pattern Pure uses for virtualenv (psvar[12]).
#
#   ~/dev/worktrees/foo emdash/branch ↑1
#   (https://app.skusafe35.test) ❯

_skusafe_wt_precmd() {
  psvar[13]=()

  # walk up to find monorepo root
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.sku" ]]; then
      break
    fi
    dir="${dir:h}"
  done
  [[ "$dir" == "/" ]] && return

  # only activate for worktrees
  [[ -f "$dir/api/.env.worktree" ]] || return

  # read slot number
  local slot=0
  if [[ -f "$dir/.sku/instance.env" ]]; then
    local line
    while IFS= read -r line; do
      if [[ "$line" =~ ^SKU_SLOT=([0-9]+)$ ]]; then
        slot="${match[1]}"
        break
      fi
    done < "$dir/.sku/instance.env"
  fi

  if (( slot == 0 )); then
    psvar[13]="https://app.skusafe.test"
  else
    psvar[13]="https://app.skusafe${slot}.test"
  fi
}

PROMPT="%(13V.%F{242}(%f%F{cyan}%13v%f%F{242})%f .)${PROMPT}"

autoload -Uz add-zsh-hook
add-zsh-hook precmd _skusafe_wt_precmd
