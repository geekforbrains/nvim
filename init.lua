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

-- Function to toggle the quickfix list
function _G.toggle_quickfix()
  local quickfix_open = false
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      quickfix_open = true
      break
    end
  end

  if quickfix_open then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end

-- Core settings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable unused providers for better performance
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
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
vim.opt.colorcolumn = "100"

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
vim.keymap.set("n", "<leader>o", toggle_quickfix, { noremap = true, silent = true }) -- Toggle quidkfix list
vim.keymap.set("n", "<leader>w", ":set wrap!<CR>", { noremap = true, silent = true }) -- Toggle line wrap
 
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
  view = { 
    width = 24,
    preserve_window_proportions = true,  -- Prevent nvim-tree from resizing
    adaptive_size = false,  -- Keep fixed width
    debounce_delay = 15,  -- Default is good for performance
  },
  renderer = { 
    group_empty = true,
    icons = {
      show = {
        git = false,  -- Disable git icons for performance
        diagnostics = false,  -- Disable diagnostic icons
      },
    },
    highlight_git = "none",  -- Disable git highlighting
    highlight_diagnostics = "none",  -- Disable diagnostics highlighting
    highlight_opened_files = "none",  -- Disable opened files highlighting
    highlight_modified = "none",  -- Disable modified highlighting
  },
  filters = {
    dotfiles = false,  -- Show dotfiles (like .env)
    custom = { 
      "node_modules", 
      "__pycache__", 
      "^env$", 
      "^.git$",
      "dist",
      "build",
      ".next",
      ".nuxt",
      ".cache",
      "coverage",
      ".pytest_cache",
      ".mypy_cache",
      "*.egg-info",
    },  -- Expanded filter list for better performance
  },
  git = {
    enable = false,  -- Disable git integration for major performance improvement
  },
  diagnostics = {
    enable = false,  -- Already disabled, keeping for clarity
  },
  modified = {
    enable = false,  -- Disable modified status tracking
  },
  filesystem_watchers = {
    enable = true,
    debounce_delay = 50,
    ignore_dirs = {
      "/node_modules",
      "/.git",
      "/dist",
      "/build",
      "/.next",
      "/__pycache__",
    },
  },
  update_focused_file = {
    enable = false,  -- Disable auto-update when changing files
  },
  actions = {
    open_file = {
      resize_window = false,  -- Prevent window resizing overhead
      window_picker = {
        enable = false,  -- Disable window picker to prevent resize issues
      },
    },
    change_dir = {
      enable = false,  -- Prevent directory changes from affecting window size
    },
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

-- Global LSP keybindings that apply to all LSP servers
local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
end

-- Mason and LSP configuration
require("mason").setup()
require("mason-lspconfig").setup({ 
  ensure_installed = { "pylsp", "jsonls" },
  automatic_enable = false  -- Disable automatic setup to prevent duplicates
})

-- Setup for Python LSP
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
  on_attach = on_attach,
})

-- Setup any other language servers that you have installed via Mason
-- This ensures the global keybindings are applied to all language servers
local lspconfig = require("lspconfig")
local servers = { "ts_ls", "jsonls", "html", "cssls" } -- Add any other servers you use

for _, server in ipairs(servers) do
  if lspconfig[server] then
    lspconfig[server].setup({
      on_attach = on_attach,
    })
  end
end

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

-- Force nvim-tree to maintain its width when opening files after closing the last one
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    -- Only run if we just opened a file and nvim-tree exists
    local tree_win = vim.fn.win_findbuf(vim.fn.bufnr("NvimTree_1"))[1]
    if tree_win and #vim.api.nvim_list_wins() == 2 then
      vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(tree_win) then
          vim.api.nvim_win_set_width(tree_win, 24)
        end
      end, 10)
    end
  end,
})
