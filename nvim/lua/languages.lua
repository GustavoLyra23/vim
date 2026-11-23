require("mason").setup()

-- Reutiliza os servidores do Zed; os instalados pelo Mason têm prioridade.
local zed = (vim.env.XDG_DATA_HOME or (vim.env.HOME .. "/.local/share")) .. "/zed"
for _, pattern in ipairs({
  "/languages/*/node_modules/.bin", "/extensions/work/*/node_modules/.bin",
  "/languages/ruff/*/*", "/extensions/work/dockerfile/docker-language-server-*",
}) do
  for _, dir in ipairs(vim.fn.glob(zed .. pattern, false, true)) do
    if vim.fn.isdirectory(dir) == 1 then vim.env.PATH = vim.env.PATH .. ":" .. dir end
  end
end

vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
local servers = {
  bashls = {},
  basedpyright = {},
  ruff = {},
  vtsls = {},
  eslint = {},
  html = {},
  cssls = {},
  jsonls = {},
  yamlls = {},
  tailwindcss = {},
  emmet_language_server = {},
  lua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
  gopls = {},
  rust_analyzer = {},
  clangd = {},
  jdtls = {},
  gradle_ls = {
    filetypes = { "groovy", "kotlin" },
    root_dir = function(bufnr, on_dir)
      local file = vim.api.nvim_buf_get_name(bufnr)
      -- O servidor Gradle não atende arquivos de código Kotlin/Groovy comuns.
      if file:match("%.gradle$") or file:match("%.gradle%.kts$") then
        on_dir(vim.fs.root(bufnr, { "settings.gradle", "settings.gradle.kts", "build.gradle", "build.gradle.kts" }) or vim.fs.dirname(file))
      end
    end,
  },
  neocmake = {},
  docker_language_server = {},
  terraformls = {},
  taplo = {},
  marksman = {},
  sqlls = {},
  zls = {},
  nil_ls = {},
  ols = {},
  hls = { filetypes = { "haskell", "lhaskell", "cabal" } },
}

local executables = {
  jdtls = "jdtls", eslint = "vscode-eslint-language-server",
  cssls = "vscode-css-language-server", html = "vscode-html-language-server",
  jsonls = "vscode-json-language-server", yamlls = "yaml-language-server",
  tailwindcss = "tailwindcss-language-server",
}
local missing = {}
for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  local cmd = vim.lsp.config[name].cmd
  local executable = executables[name] or (type(cmd) == "table" and cmd[1])
  if executable and vim.fn.executable(executable) == 1 then
    vim.lsp.enable(name)
  else
    table.insert(missing, name)
  end
end
table.sort(missing)
local prerequisites = { nil_ls = "cargo", hls = "ghcup" }
local installable = vim.tbl_filter(function(name)
  return not prerequisites[name] or vim.fn.executable(prerequisites[name]) == 1
end, missing)
require("mason-lspconfig").setup({ ensure_installed = installable })

-- O servidor de GDScript pertence ao editor Godot aberto com o projeto.
vim.lsp.enable("gdscript")

return { servers = servers, missing = missing }
