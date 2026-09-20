# Everything this config needs that lives outside the repo.
#
#   brew bundle --file ~/.config/nvim/Brewfile
#
# Keep in sync with lua/config/deps.lua, which checks the same list at runtime.

brew "neovim"
brew "git"

# Provides node + npm. mason builds jsonls, ts_ls, html and cssls from npm and
# fails with a bare "failed to install" if it is absent.
brew "node"

# The tree-sitter CLI, which nvim-treesitter's `main` branch shells out to for
# every parser build.
#
# NOT the same as the `tree-sitter` formula. That one is the C library, it ships
# no binary, and Neovim depends on it -- so it appears in `brew list` while
# parser builds keep failing with ENOENT and no highlighting ever appears.
brew "tree-sitter-cli"

# Glyphs for nvim-web-devicons. The "symbols only" variant is intentional: it
# supplies the icons without replacing the terminal's text font.
cask "font-symbols-only-nerd-font"
