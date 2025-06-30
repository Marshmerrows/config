#!/bin/bash

CONFIG_DIR="$(pwd)"

ln -sfn "${CONFIG_DIR}/hammerspoon" ~/.hammerspoon
ln -sfn "${CONFIG_DIR}/vim/vimrc" ~/.vimrc
ln -sfn "${CONFIG_DIR}/zsh/zsh_plugins.txt" ~/.zsh_plugins.txt

# Create ~/.zshrc that sources the shared config
echo "source \"${CONFIG_DIR}/zsh/zshrc\"" > ~/.zshrc

echo "Symlinks created successfully:"
ls -l ~/.hammerspoon ~/.vimrc ~/.zshrc ~/.zsh_plugins.txt
