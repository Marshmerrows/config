curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz
tar xzf nvim-macos-arm64.tar.gz
sudo mv nvim-macos-arm64 /usr/local/nvim-nightly

# Add to PATH (add to your .zshrc or .bashrc)
export PATH="/usr/local/nvim-nightly/bin:$PATH"
