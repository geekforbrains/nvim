-- `:checkhealth config`
--
-- Covers the gaps the plugins' own checks miss. Every problem this reports has
-- happened and was invisible: mason said "failed to install jsonls" without
-- mentioning npm; nvim-treesitter compiled nothing because the tree-sitter CLI
-- was absent while the same-named brew formula was installed; two servers were
-- enabled but never installed; and no Nerd Font on the machine turned every
-- file icon into a missing-glyph box.

local deps = require("config.deps")
local servers = require("config.servers")
local languages = require("config.languages")

local H = vim.health
local M = {}

local function check_executables()
  H.start("config: external tools")
  for _, dep in ipairs(deps.executables) do
    local path = vim.fn.exepath(dep.cmd)
    if path ~= "" then
      H.ok(("%s -> %s"):format(dep.cmd, path))
    else
      H.error(("`%s` not found on PATH -- %s"):format(dep.cmd, dep.why), { dep.install })
    end
  end
end

local function check_font()
  H.start("config: icons")
  local ok, found = deps.has_nerd_font()
  if ok then
    if #found == 0 then
      H.info("not a macOS host; skipping the font check")
    else
      H.ok(("Nerd Font installed (%d file%s), e.g. %s")
        :format(#found, #found == 1 and "" or "s", vim.fn.fnamemodify(found[1], ":t")))
      H.info("the terminal must also be told to use it for non-ASCII text")
    end
  else
    H.warn("no Nerd Font installed -- " .. deps.nerd_font.why, {
      deps.nerd_font.install,
      "then point the terminal's non-ASCII font at it",
      "icons are falling back to plain text until then",
    })
  end
end

-- mason loads on VeryLazy, which may not have fired when checkhealth runs.
local function load_mason()
  pcall(function()
    require("lazy").load({ plugins = { "mason.nvim", "mason-lspconfig.nvim" } })
  end)
  local ok_reg, registry = pcall(require, "mason-registry")
  local ok_map, mappings = pcall(require, "mason-lspconfig.mappings")
  if not (ok_reg and ok_map) then
    return nil, nil
  end
  local ok_get, map = pcall(mappings.get_mason_map)
  return registry, ok_get and map.lspconfig_to_package or nil
end

local function check_servers()
  H.start("config: language servers")
  local registry, to_package = load_mason()

  local names = vim.tbl_keys(servers)
  table.sort(names)
  for _, name in ipairs(names) do
    -- Read the resolved config, so this sees the same `cmd` vim.lsp.enable()
    -- will spawn rather than a second hardcoded copy of the binary names.
    local ok, cfg = pcall(function()
      return vim.lsp.config[name]
    end)
    local cmd = ok and cfg and cfg.cmd or nil

    if type(cmd) == "table" and cmd[1] then
      -- Static command: the binary name is known, so check PATH directly.
      if vim.fn.executable(cmd[1]) == 1 then
        H.ok(("%s -> %s"):format(name, cmd[1]))
      else
        H.error(("%s: `%s` is not executable"):format(name, cmd[1]), {
          "install it with :Mason",
          "if the install itself failed, :MasonLog has the real cause",
        })
      end
    elseif to_package and registry then
      -- `cmd` is a function (lspconfig builds the command at spawn time), so
      -- there is no binary name to test. Ask mason whether the package backing
      -- this server is installed instead.
      local pkg_name = to_package[name]
      local ok_pkg, pkg = pcall(registry.get_package, pkg_name)
      if not ok_pkg then
        H.warn(("%s: no mason package known; cannot verify"):format(name))
      elseif pkg:is_installed() then
        H.ok(("%s -> %s (mason)"):format(name, pkg_name))
      else
        H.error(("%s: mason package `%s` is not installed"):format(name, pkg_name), {
          "install it with :Mason",
          "if the install itself failed, :MasonLog has the real cause",
        })
      end
    else
      H.warn(("%s: could not resolve a command or a mason package"):format(name))
    end
  end
end

local function check_parsers()
  H.start("config: treesitter parsers")
  local missing = {}
  for _, lang in ipairs(languages) do
    if #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) > 0 then
      H.ok(lang)
    else
      missing[#missing + 1] = lang
    end
  end
  if #missing > 0 then
    H.error("no parser built for: " .. table.concat(missing, ", "), {
      "run :TSInstall " .. table.concat(missing, " "),
      "parsers build with the tree-sitter CLI -- confirm it is present above",
    })
  end
end

function M.check()
  check_executables()
  check_font()
  check_servers()
  check_parsers()
end

return M
