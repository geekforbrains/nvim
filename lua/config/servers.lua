-- Single source of truth for language servers.
--
-- Both mason-lspconfig's `ensure_installed` and `vim.lsp.enable()` are derived
-- from this table, so the two cannot drift apart. They did drift: `html` and
-- `cssls` were enabled but never listed for install, and a server that is
-- enabled without being installed fails to spawn with no error anywhere -- no
-- message, no entry in :LspLog, just no LSP on those filetypes.
--
-- Keys are nvim-lspconfig server names (what `vim.lsp.enable()` and
-- mason-lspconfig both take). Values are passed straight to `vim.lsp.config()`.

return {
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          flake8 = { enabled = true },
          pycodestyle = { enabled = false },
          mccabe = { enabled = false },
          pyflakes = { enabled = false },
        },
      },
    },
  },
  ts_ls = {},
  jsonls = {},
  html = {},
  cssls = {},
}
