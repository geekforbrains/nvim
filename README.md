# nvim config

Neovim 0.12+, lazy.nvim, nord.

## Setup on a new machine

Prerequisites: [Homebrew](https://brew.sh) and `xcode-select --install`.

```sh
gh repo clone geekforbrains/nvim ~/.config/nvim
~/.config/nvim/bootstrap.sh
```

`bootstrap.sh` is idempotent and does everything headless, so the first real
`nvim` opens fully working:

1. `brew bundle` -- external tools and the Nerd Font (see `Brewfile`)
2. iTerm2 **Nord** profile -- copies `iterm/nord.json` into iTerm2's
   DynamicProfiles folder (loaded live, even with iTerm2 running)
3. `:Lazy! restore` -- plugins at exactly the commits in `lazy-lock.json`
4. treesitter parsers, blocking until compiled
5. language servers from `lua/config/servers.lua`, via mason
6. `:checkhealth config` -- exits non-zero if anything failed

Then three manual steps:

**iTerm2 default profile** -- Settings -> Profiles -> select **Nord** ->
Other Actions... -> **Set as Default**. New tabs and windows then open in Nord.
iTerm2 does not accept a default-profile change from outside while it is
running, so this one is a click. `:checkhealth config` warns until it is done.

**iTerm2 font** -- or every icon renders as a `?` box. With iTerm2 open:

> Settings -> Profiles -> Text -> check "Use a different font for non-ASCII
> text" -> **Symbols Nerd Font Mono**

It applies immediately. Leave the main font alone; only glyphs it lacks come
from the Nerd Font. `:checkhealth config` verifies this when run inside iTerm2.
`set-iterm-nerdfont.py` does the same unattended, but only with iTerm2 fully
quit (run it from Terminal.app) -- iTerm2 rewrites its prefs on exit and would
silently undo it.

**Copilot** -- `:Copilot setup` once (needs a browser).

## Gotchas this config already handles

- **Light Nord.** Neovim asks the terminal for its background colour, and
  nord.nvim switches to its light palette on a light terminal profile.
  `init.lua` sets `background=dark` so Nord is always the dark theme. The
  terminal's own colours are separate -- that is what the iTerm2 Nord profile
  is for.
- **iTerm2 Nord profile.** `iterm/nord.json` is the official
  [nordtheme/iterm2](https://github.com/nordtheme/iterm2) colours as a dynamic
  profile with `"Dynamic Profile Parent Name": "Default"`, so fonts (including
  the Nerd Font setting) come from Default, and nothing is duplicated. It also
  turns off iTerm2's separate light/dark-mode colours, which would otherwise
  show the light set whenever macOS is in light mode. Its fixed `Guid` keeps
  "Set as Default" pointing at it across reinstalls.
- **Dirty lockfile after first launch.** lazy.nvim bootstraps itself from its
  latest stable tag, usually newer than the lockfile. `bootstrap.sh` runs
  `:Lazy! restore` to pin it back.
- **"Plugin Updates -- Press ENTER" on every launch.** The update checker still
  runs but no longer notifies. Use `:Lazy` to see and apply updates, then commit
  `lazy-lock.json`.
- **No LSP on the first file.** mason loads on `VeryLazy`, after the first
  `FileType` event, so `init.lua` puts mason's bin dir on `PATH` itself. Servers
  install on first interactive launch if `bootstrap.sh` was skipped.

## Layout

| File | Purpose |
| --- | --- |
| `bootstrap.sh` | One-shot, idempotent setup on a new machine |
| `Brewfile` | External tools; kept in sync with `deps.lua` |
| `set-iterm-nerdfont.py` | Sets iTerm2's non-ASCII font without the GUI |
| `iterm/nord.json` | iTerm2 Nord dynamic profile, installed by `bootstrap.sh` |
| `init.lua` | Options, keymaps, plugin specs, LSP and treesitter wiring |
| `lua/config/servers.lua` | Language servers. **Single source of truth** |
| `lua/config/languages.lua` | Treesitter languages |
| `lua/config/deps.lua` | External tools, why each is needed, how to install |
| `lua/config/health.lua` | `:checkhealth config`, including iTerm2's font setting |

## Why the indirection

Each of these was a silent failure, not a hypothetical:

- **`servers.lua` feeds both `ensure_installed` and `vim.lsp.enable()`.** They
  were once separate lists and drifted: `html` and `cssls` were enabled but
  never installed. A server enabled without being installed does not warn. It
  does not appear in `:LspLog`. There is simply no LSP on those filetypes.
  Adding a key here now installs *and* enables it, and no edit can desync them.

- **`deps.lua` names every external tool and its install command.** Missing
  tools surface far from their cause: mason reported `failed to install jsonls`
  without mentioning that `npm` was absent, and nvim-treesitter compiled nothing
  because the `tree-sitter` CLI was missing while the identically-named brew
  formula was installed. `init.lua` warns once at startup with the exact fix.

- **Icons degrade to plain text when no Nerd Font is installed.** A terminal
  never reports its font, so the glyphs cannot be probed. What can be detected
  is a machine with no Nerd Font at all -- which is what actually happened, and
  which made the file tree a column of `?` boxes that read as a broken config
  rather than a missing font.
