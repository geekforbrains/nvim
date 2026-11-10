#!/usr/bin/env bash
# One-shot setup on a new Mac. Idempotent -- safe to re-run any time.
#
#   gh repo clone geekforbrains/nvim ~/.config/nvim
#   ~/.config/nvim/bootstrap.sh
#
# Does everything up front, headless, so the first real `nvim` opens fully
# working instead of installing plugins, parsers and servers on screen.
set -euo pipefail

cd "$(dirname "$0")"
step() { printf '\n==> %s\n' "$*"; }

command -v brew >/dev/null || { echo "error: install Homebrew first (https://brew.sh)" >&2; exit 1; }
xcode-select -p >/dev/null 2>&1 || {
  echo "error: no C compiler (treesitter parsers need one). Run: xcode-select --install, then re-run" >&2
  exit 1
}

step "External tools (Brewfile)"
brew bundle --file Brewfile

# A dynamic profile, so iTerm2 picks it up live -- even while running, unlike
# its main prefs, which it overwrites on quit. It inherits everything (fonts,
# including the Nerd Font setting) from the "Default" profile and only adds
# the official Nord colours (nordtheme/iterm2). Making it the default profile
# is one click in the GUI; see README.
step "iTerm2 Nord profile"
if [ -d /Applications/iTerm.app ]; then
  dest="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  mkdir -p "$dest"
  cp iterm/nord.json "$dest/nord.json"
  echo "installed $dest/nord.json"
else
  echo "iTerm2 not installed; skipped"
fi

# init.lua bootstraps lazy.nvim from its latest stable tag, which is usually
# newer than lazy-lock.json and dirties the lockfile. `restore` pins every
# plugin, lazy.nvim included, to exactly what the lockfile says.
step "Plugins (pinned to lazy-lock.json)"
nvim --headless "+Lazy! restore" +qa

# init.lua also starts parser installs, but asynchronously -- a headless nvim
# can exit before they finish. Install again here and block until done.
step "Treesitter parsers"
nvim --headless \
  "+lua require('nvim-treesitter').install(require('config.languages')):wait(300000)" +qa

# mason-lspconfig installs servers on VeryLazy, which never fires headless.
# Map lua/config/servers.lua (lspconfig names) to mason package names and
# install those; :MasonInstall blocks when headless.
step "Language servers (mason)"
pkgs=$(nvim --headless "+lua (function()
  require('lazy').load({ plugins = { 'mason.nvim', 'mason-lspconfig.nvim' } })
  local map = require('mason-lspconfig.mappings').get_mason_map().lspconfig_to_package
  local registry = require('mason-registry')
  local out = {}
  for name in pairs(require('config.servers')) do
    local pkg = map[name]
    if not (pkg and registry.is_installed(pkg)) then out[#out + 1] = pkg or name end
  end
  table.sort(out)
  io.stdout:write(table.concat(out, ' '))
end)()" +qa)
if [ -z "$pkgs" ]; then
  echo "all installed"
else
  echo "installing: $pkgs"
  nvim --headless "+lua require('lazy').load({ plugins = { 'mason.nvim', 'mason-lspconfig.nvim' } })" \
    "+MasonInstall $pkgs" +qa
fi

step "Health check"
report=$(mktemp)
nvim --headless "+checkhealth config" "+w! $report" +qa >/dev/null 2>&1
cat "$report"
if grep -q "ERROR" "$report"; then
  rm -f "$report"
  echo
  echo "Some checks failed -- see the fixes listed above."
  [ "${TERM_PROGRAM:-}" = "iTerm.app" ] || echo "(The iTerm2 font check only runs from inside iTerm2.)"
  exit 1
fi
rm -f "$report"

step "Done"
[ "${TERM_PROGRAM:-}" = "iTerm.app" ] || cat <<'EOF'
Not running inside iTerm2, so its font setting was not checked. If you use it:
  iTerm2 > Settings > Profiles > Text > "Use a different font for non-ASCII text"
  > Symbols Nerd Font Mono. Then run :checkhealth config from nvim in iTerm2.
EOF
echo "Optional: :Copilot setup (needs a browser)."
