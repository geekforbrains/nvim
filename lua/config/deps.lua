-- External tools this config depends on, and what breaks without each.
--
-- Everything listed here lives OUTSIDE this repo. Neovim cannot install any of
-- it, and every one of these failed silently at least once: a missing tool
-- surfaces far from its cause, in an error that names neither the tool nor the
-- fix. This module is the single place that knows about them. init.lua warns at
-- startup; `:checkhealth config` reports in full.

local M = {}

M.executables = {
  {
    cmd = "git",
    why = "lazy.nvim clones plugins; nvim-treesitter fetches parser repos",
    install = "brew install git",
  },
  {
    cmd = "npm",
    why = "mason builds jsonls, ts_ls, html and cssls from npm",
    install = "brew install node",
  },
  {
    cmd = "tree-sitter",
    -- Homebrew's `tree-sitter` formula is the C library only and ships no
    -- binary -- and Neovim itself depends on it, so it shows up in `brew list`
    -- looking like the box is already covered while every parser build keeps
    -- failing with ENOENT. The CLI is a separate formula.
    why = "nvim-treesitter's `main` branch compiles every parser with the CLI",
    install = "brew install tree-sitter-cli",
  },
  {
    cmd = "python3",
    why = "mason builds pylsp with pip",
    install = "brew install python",
  },
  {
    cmd = "cc",
    why = "nvim-treesitter links the parsers it compiles",
    install = "xcode-select --install",
  },
}

M.nerd_font = {
  why = "nvim-web-devicons draws file icons with Nerd Font glyphs",
  install = "brew install --cask font-symbols-only-nerd-font",
}

--- Executables from M.executables that are not on PATH.
function M.missing()
  local out = {}
  for _, dep in ipairs(M.executables) do
    if vim.fn.executable(dep.cmd) == 0 then
      out[#out + 1] = dep
    end
  end
  return out
end

--- Whether a Nerd Font is installed on this machine.
---
--- A terminal never reports its font to the program running inside it, so the
--- glyphs themselves cannot be probed from here. Checking that a Nerd Font is
--- installed at all is the closest available proxy, and it catches the failure
--- that actually happened: no Nerd Font anywhere on the machine, so every icon
--- rendered as a missing-glyph box.
---@return boolean installed, string[] paths
function M.has_nerd_font()
  if vim.fn.has("mac") == 0 then
    return true, {} -- unknown platform: assume yes rather than degrade wrongly
  end
  local found = {}
  for _, dir in ipairs({ vim.fn.expand("~/Library/Fonts"), "/Library/Fonts" }) do
    if vim.fn.isdirectory(dir) == 1 then
      vim.list_extend(found, vim.fn.globpath(dir, "*Nerd*", false, true))
    end
  end
  return #found > 0, found
end

return M
