-- Treesitter languages to install and start highlighting for.
--
-- Shared by init.lua (install + FileType autocmd) and the health check, so the
-- check reports on exactly what this config asked for. For every language here
-- the parser name matches the filetype, which is why one list serves both.
--
-- markdown/markdown_inline are deliberately absent: Neovim 0.12 bundles both
-- parsers and their queries, and installing them here shadows the bundled ones.

return { "html", "css", "javascript", "typescript", "python", "htmldjango" }
