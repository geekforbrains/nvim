-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Core settings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.fillchars = { vert = " ", horiz = " ", eob = " " }
vim.opt.wrap = false

-- Indentation settings
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Key mappings for navigation and commands
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })
vim.keymap.set("n", "<leader>,", ":noh<CR>", { noremap = true, silent = true }) -- Clear search highlights
vim.keymap.set("n", "<leader>x", ":bd<CR>", { noremap = true, silent = true }) -- Close buffer

-- Plugin setup with lazy.nvim
require("lazy").setup({
  spec = {
    { "shaunsingh/nord.nvim" },
    { "nvim-tree/nvim-tree.lua" },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "github/copilot.vim" },
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "numToStr/Comment.nvim" },
    { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
    { "razak17/tailwind-fold.nvim", config = true },
    { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  },
  install = { colorscheme = { "nord" } },
  checker = { enabled = true },
})
vim.cmd("colorscheme nord")

-- Nvim-tree setup and mappings
require("nvim-tree").setup({
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')
    local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }
    api.config.mappings.default_on_attach(bufnr)
    vim.keymap.set('n', '<CR>', api.node.open.edit, opts)
    vim.keymap.set('n', 'i', api.node.open.horizontal, opts)
    vim.keymap.set('n', 's', api.node.open.vertical, opts)
  end,
  sort = { sorter = "case_sensitive" },
  view = { width = 24 },
  renderer = { group_empty = true },
  filters = { 
    dotfiles = true,
    custom = { "node_modules", "__pycache__" },
  },
})
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })

-- Telescope setup and mappings
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      },
      n = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      },
    },
    layout_strategy = "vertical",
    layout_config = {
      vertical = { preview_height = 0.7 },
      preview_cutoff = 0,
    },
  },
})
vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fw", require("telescope.builtin").live_grep, { noremap = true, silent = true })
vim.keymap.set("v", "<leader>fw", function()
  vim.cmd('noau normal! "vy')
  local selected_text = vim.fn.getreg("v") -- Get the yanked text from visual mode selection
  require("telescope.builtin").live_grep({ default_text = selected_text })
end, { noremap = true, silent = true })

-- Comment.nvim setup and mappings
require("Comment").setup({
  mappings = { basic = true, extra = false, extended = false }
})
vim.keymap.set(
  "n", 
  "<leader>/", 
  "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", 
  { noremap = true, silent = true }
)
vim.keymap.set(
  "v",
  "<leader>/",
  "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", 
  { noremap = true, silent = true }
)

-- Treesitter setup
require("nvim-treesitter.configs").setup({
  ensure_installed = { "html", "css", "javascript", "typescript", "python", "htmldjango" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"  -- Fold css classes using tailwind-fold.nvim
vim.opt.foldlevel = 99  -- Start with all folds open

-- Lualine setup
require('lualine').setup({
  options = {
    theme = 'nord'
  }
})

-- Mason and LSP configuration for Python (pylsp)
require("mason").setup()
require("mason-lspconfig").setup({ ensure_installed = { "pylsp" } })
require("lspconfig").pylsp.setup({
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
  on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  end,
})

-- Autocommands
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if #vim.fn.argv() > 0 then
      require("nvim-tree.api").tree.toggle({ focus = false })
    else
      require("nvim-tree.api").tree.open()
    end
  end,
})
