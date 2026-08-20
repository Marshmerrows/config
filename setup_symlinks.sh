#!/bin/bash

CONFIG_DIR="$(pwd)"

ln -sfn "${CONFIG_DIR}/hammerspoon" ~/.hammerspoon
ln -sfn "${CONFIG_DIR}/nvim" ~/.config/nvim
ln -sfn "${CONFIG_DIR}/ghostty" ~/.config/ghostty
ln -sfn "${CONFIG_DIR}/zsh/zsh_plugins.txt" ~/.zsh_plugins.txt
ln -sfn "${CONFIG_DIR}/claude/settings.json" ~/.claude/settings.json
mkdir -p ~/.config/herdr ~/dev
ln -sfn "${CONFIG_DIR}/herdr/config.toml" ~/.config/herdr/config.toml
ln -sfn "${CONFIG_DIR}/herdr/control" ~/dev/control

# Pi resources live in this repo and are linked into Pi's global config.
link_pi_resources() {
    local source_dir="$1"
    local target_dir="$2"

    [ -d "$source_dir" ] || return
    mkdir -p "$target_dir"

    for resource in "$source_dir"/*; do
        [ -e "$resource" ] || continue
        ln -sfn "$resource" "$target_dir/$(basename "$resource")"
    done
}

link_pi_resources "${CONFIG_DIR}/pi/extensions" ~/.pi/agent/extensions
link_pi_resources "${CONFIG_DIR}/pi/skills" ~/.pi/agent/skills
link_pi_resources "${CONFIG_DIR}/pi/prompts" ~/.pi/agent/prompts
link_pi_resources "${CONFIG_DIR}/pi/themes" ~/.pi/agent/themes
ln -sfn "${CONFIG_DIR}/pi/mcp.json" ~/.pi/agent/mcp.json
ln -sfn "${CONFIG_DIR}/pi/keybindings.json" ~/.pi/agent/keybindings.json

# Shared global agent instructions (one file, both tools)
mkdir -p ~/.claude ~/.codex
ln -sfn "${CONFIG_DIR}/ai/AGENTS.md" ~/.claude/CLAUDE.md
ln -sfn "${CONFIG_DIR}/ai/AGENTS.md" ~/.codex/AGENTS.md

# Create or update ~/.zshrc that sources the shared config
SOURCE_LINE="source \"${CONFIG_DIR}/zsh/zshrc\""
if [ ! -f ~/.zshrc ]; then
    echo "$SOURCE_LINE" > ~/.zshrc
    echo "Created ~/.zshrc with source line"
else
    if ! grep -q "source.*${CONFIG_DIR}/zsh/zshrc" ~/.zshrc; then
        # Create temp file with source line at top, then append existing content
        echo "$SOURCE_LINE" > ~/.zshrc.tmp
        cat ~/.zshrc >> ~/.zshrc.tmp
        mv ~/.zshrc.tmp ~/.zshrc
        echo "Added source line to existing ~/.zshrc"
    else
        echo "Source line already exists in ~/.zshrc"
    fi
fi

echo "Symlinks created successfully:"
ls -l ~/.hammerspoon ~/.config/nvim ~/.config/ghostty ~/.zshrc ~/.zsh_plugins.txt \
    ~/.claude/settings.json ~/.claude/CLAUDE.md ~/.codex/AGENTS.md \
    ~/.pi/agent/extensions/statusline.ts ~/.pi/agent/mcp.json \
    ~/.pi/agent/keybindings.json \
    ~/.config/herdr/config.toml ~/dev/control
