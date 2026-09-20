# nvim config

Neovim 0.12+, lazy.nvim, nord.

## Setup on a new machine

```sh
brew bundle --file ~/.config/nvim/Brewfile   # external tools (see Brewfile)
nvim                                         # lazy.nvim bootstraps plugins
```

Then point the terminal at the Nerd Font, or every icon renders as a
missing-glyph box. In iTerm2:

> Settings -> Profiles -> Text -> check "Use a different font for non-ASCII
> text" -> **Symbols Nerd Font Mono**

Leave the main font alone; only the glyphs the main font lacks come from the
Nerd Font. `set-iterm-nerdfont.py` does this from the command line instead, and
must run with iTerm2 fully quit -- it rewrites its preferences on exit.

Finally:

```vim
:checkhealth config
```

## Layout

| File | Purpose |
| --- | --- |
| `init.lua` | Options, keymaps, plugin specs, LSP and treesitter wiring |
| `lua/config/servers.lua` | Language servers. **Single source of truth** |
| `lua/config/languages.lua` | Treesitter languages |
| `lua/config/deps.lua` | External tools, why each is needed, how to install |
| `lua/config/health.lua` | `:checkhealth config` |

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
