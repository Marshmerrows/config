#!/bin/bash

CONFIG_DIR="$(pwd)"

ln -sfn "${CONFIG_DIR}/hammerspoon" ~/.hammerspoon
ln -sfn "${CONFIG_DIR}/nvim" ~/.config/nvim
ln -sfn "${CONFIG_DIR}/zsh/zsh_plugins.txt" ~/.zsh_plugins.txt
ln -sfn "${CONFIG_DIR}/cursor/settings.json" ~/Library/Application\ Support/Cursor/User/settings.json
ln -sfn "${CONFIG_DIR}/ghostty/config" ~/.config/ghostty/config

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
ls -l ~/.hammerspoon ~/.config/nvim ~/.zshrc ~/.zsh_plugins.txt
