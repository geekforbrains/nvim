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
vim.opt.foldmethod = "manual"
vim.opt.foldlevel = 99

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
vim.keymap.set("n", "<leader>w", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.wo.linebreak = vim.wo.wrap
end, { noremap = true, silent = true }) -- Toggle line wrap
 
-- Plugin setup with lazy.nvim
require("lazy").setup({
  spec = {
    -- Eager: needed before the first screen is drawn.
    { "shaunsingh/nord.nvim" },
    { "nvim-tree/nvim-tree.lua" },
    { "neovim/nvim-lspconfig" }, -- data only; supplies lsp/*.lua for vim.lsp.enable()
    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
    -- `main` is required on Neovim 0.12: the archived `master` branch crashes in
    -- query directives (it predates the removal of the `all` option).
    -- `main` is a rewrite and does not support lazy-loading.
    { "nvim-treesitter/nvim-treesitter", branch = "main", lazy = false, build = ":TSUpdate" },

    -- Lazy: kept off the startup path.
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      cmd = "Telescope",
      keys = {
        { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Telescope buffers" },
        { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Telescope find files" },
        { "<leader>fw", function() require("telescope.builtin").live_grep() end, desc = "Telescope live grep" },
        {
          "<leader>fw",
          function()
            vim.cmd('noau normal! "vy')
            require("telescope.builtin").live_grep({ default_text = vim.fn.getreg("v") })
          end,
          mode = "v",
          desc = "Telescope live grep (selection)",
        },
      },
      config = function()
        -- required inside config() so it does not drag telescope onto the startup path
        local actions = require("telescope.actions")
        require("telescope").setup({
          defaults = {
            mappings = {
              i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
              },
              n = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
              },
            },
            layout_strategy = "vertical",
            layout_config = {
              vertical = { preview_height = 0.7 },
              preview_cutoff = 0,
            },
          },
        })
      end,
    },
    { "github/copilot.vim", event = "InsertEnter" },
    -- mason is only needed to install servers; vim.lsp.enable() below does the wiring.
    -- VeryLazy (not cmd) so ensure_installed still runs, just after the UI is up.
    { "mason-org/mason.nvim", event = "VeryLazy", opts = {} },
    {
      "mason-org/mason-lspconfig.nvim",
      event = "VeryLazy",
      dependencies = { "mason-org/mason.nvim" },
      opts = {
        ensure_installed = { "pylsp", "jsonls", "ts_ls" },
        automatic_enable = false, -- servers are enabled explicitly below
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "markdown.mdx" },
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {},
    },
    {
      "razak17/tailwind-fold.nvim",
      ft = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact", "htmldjango" },
      opts = {},
    },
  },
  install = { colorscheme = { "nord" } },
  checker = { enabled = true },
  -- No plugin here uses luarocks; this skips the hererocks bootstrap and the
  -- spurious ERROR it otherwise reports in `:checkhealth lazy`.
  rocks = { enabled = false },
  performance = {
    rtp = {
      -- Built-in plugins that go unused here. matchit/matchparen are deliberately
      -- kept -- they provide `%` matching and paren highlighting.
      disabled_plugins = { "gzip", "tarPlugin", "zipPlugin", "netrwPlugin", "tohtml", "tutor" },
    },
  },
})
vim.cmd("colorscheme nord")

-- Nvim-tree setup and mappings
require("nvim-tree").setup({
  disable_netrw = true,
  hijack_netrw = false,
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

-- Telescope is configured in its lazy spec above (keys = ... / config = ...).

-- Commenting: Neovim has built-in `gc`/`gcc` since 0.10, so Comment.nvim is redundant.
-- `remap = true` is required -- gc/gcc are expr mappings that must be allowed to expand.
vim.keymap.set("n", "<leader>/", "gcc", { remap = true, silent = true })
vim.keymap.set("x", "<leader>/", "gc", { remap = true, silent = true })

-- Treesitter setup
-- The `main` branch has no module system: no `configs.setup()`, no `ensure_installed`,
-- no `highlight.enable`. Parsers are installed via the Lua API and highlighting is
-- started per-buffer with `vim.treesitter.start()`.
--
-- markdown/markdown_inline are deliberately absent: Neovim 0.12 bundles both parsers
-- and their queries, and installing them here shadows the bundled ones.
-- For these languages the parser name matches the filetype, so one list serves both.
local ts_languages = { "html", "css", "javascript", "typescript", "python", "htmldjango" }
require("nvim-treesitter").install(ts_languages)

vim.api.nvim_create_autocmd("FileType", {
  pattern = ts_languages,
  callback = function()
    -- Parsers install asynchronously, so this can legitimately fail on first launch.
    pcall(vim.treesitter.start)
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt_local.foldlevel = 99
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"
    vim.opt_local.colorcolumn = ""
    vim.opt_local.foldmethod = "manual"
  end,
})

-- Lualine setup
require('lualine').setup({
  options = {
    theme = 'nord'
  }
})

-- Global LSP keybindings using LspAttach autocmd (Neovim 0.11+ way)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    local bufnr = args.buf
    local opts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

-- Mason is configured in its lazy spec above (opts = ...).
--
-- Mason normally prepends this to PATH when it loads, but it now loads on VeryLazy --
-- which fires *after* the FileType event that vim.lsp.enable() uses to spawn servers.
-- Every server here lives only in mason's bin dir, so without this the first file
-- opened gets no LSP at all (the spawn fails silently).
vim.env.PATH = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin") .. ":" .. vim.env.PATH

-- Configure language servers using the new vim.lsp.config API (Neovim 0.11+)
-- Python LSP with custom settings
vim.lsp.config("pylsp", {
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
})

-- Configure other language servers with default settings
local servers = { "ts_ls", "jsonls", "html", "cssls" }
for _, server in ipairs(servers) do
  -- Basic config for each server (configs will be loaded from nvim-lspconfig)
  vim.lsp.config(server, {})
end

-- Enable all configured language servers (including pylsp)
vim.lsp.enable({ "pylsp", "ts_ls", "jsonls", "html", "cssls" })

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
