-- nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-imports.lua
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.abspath(debug.getinfo(1, "S").source:sub(2))))
local fixture = vim.fn.tempname()
vim.fn.mkdir(fixture .. "/bin", "p")
-- O sandbox exige pipes no stdio do Node.
vim.fn.writefile({"#!/bin/bash", "set -o pipefail", "cat | " .. vim.fn.shellescape(vim.fn.exepath("node")) .. ' "$@" | cat'}, fixture .. "/bin/node")
vim.fn.setfperm(fixture .. "/bin/node", "rwx------")
assert(vim.system({"git", "init", "-q", fixture}):wait().code == 0)
vim.fn.writefile({'{"private":true}'}, fixture .. "/package.json")
vim.fn.writefile({'{"compilerOptions":{"strict":true,"noUnusedLocals":true,"target":"ES2020","module":"ESNext","moduleResolution":"bundler"}}'}, fixture .. "/tsconfig.json")
vim.fn.writefile({"export function greet() { return 'oi'; }", "export function sparkle() { return 42; }", "export const unused = 1;"}, fixture .. "/helpers.ts")
vim.fn.writefile({'import { unused } from "./helpers";', "console.log(greet());", 'const bad: number = "oops";'}, fixture .. "/main.ts")
local channel = vim.fn.jobstart({
  vim.v.progpath, "--embed", "--headless", "-i", "NONE", "--cmd", "set nomore",
  "--cmd", "set rtp^=" .. root .. "/nvim",
  "--cmd", "set rtp+=" .. vim.fn.stdpath("data") .. "/lazy/mason.nvim",
  "--cmd", 'lua require("mason-registry").refresh = function() end',
  "-u", root .. "/nvim/init.lua",
}, {rpc=true, cwd=fixture, env={PATH=fixture .. "/bin:" .. vim.env.PATH, GOPROXY="off", GOTOOLCHAIN="local"}})
assert(channel > 0)
local function lua(code, ...)
  return vim.rpcrequest(channel, "nvim_exec_lua", code, {...})
end
local function input(keys)
  vim.rpcrequest(channel, "nvim_input", keys)
end
local function wait_for(code, message, timeout)
  assert(vim.wait(timeout or 5000, function() return lua(code) == true end, 50), message .. " " .. vim.inspect(lua('return {error=vim.v.errmsg, messages=vim.fn.execute("messages")}')))
end
local function open(file)
  lua('vim.cmd.edit(...)', fixture .. "/" .. file)
end
local function contents(file)
  return table.concat(vim.fn.readfile(fixture .. "/" .. file), "\n")
end
local function ready(name)
  wait_for('local c=vim.lsp.get_clients({bufnr=0,name=' .. vim.inspect(name) .. '})[1]; return c ~= nil and c.initialized', name .. " não iniciou", 20000)
end
local ok, err = xpcall(function()
  open("main.ts")
  ready("vtsls")
  wait_for('return vim.iter(vim.diagnostic.get(0)):any(function(d) return d.code == 2322 end)', "Erro real de tipo não apareceu", 15000)
  input("A<C-S-q>")
  wait_for('local p=Snacks.picker.get({source="diagnostics_buffer"})[1]; return p ~= nil and #p:items() > 0 and vim.fn.mode() == "i"', "Ctrl+Shift+Q não abriu os erros")
  lua([[
    local p=Snacks.picker.get({source="diagnostics_buffer"})[1]
    assert(vim.iter(p:items()):any(function(item) return item.item.code == 2322 end), "Erro de tipo ausente da lista")
  ]])
  input("<Esc><Esc>")
  wait_for('return vim.fn.mode() == "n" and #Snacks.picker.get({source="diagnostics_buffer"}) == 0', "Lista de erros não fechou")
  print("PASS: Ctrl+Shift+Q mostra erro real de TypeScript enquanto se edita")

  lua('vim.cmd.write()')
  local ts = contents("main.ts")
  assert(ts:match("import.-greet.-from"), ts)
  assert(not ts:find("unused", 1, true), ts)
  assert(ts:find('const bad: number = "oops";', 1, true), "Limpeza alterou código fora dos imports")
  assert(lua('return not vim.bo.modified'), "Imports ficaram fora do arquivo salvo")
  lua('vim.api.nvim_buf_set_lines(0,0,-1,false,{\'import { unused } from "./helpers";\', "console.log(greet());"})')
  input("<C-M-o>")
  wait_for('local s=table.concat(vim.api.nvim_buf_get_lines(0,0,-1,false),"\\n"); return s:match("import.-greet.-from") ~= nil and not s:find("unused",1,true)', "Ctrl+Alt+O não organizou imports")
  assert(contents("main.ts") == ts, "Atalho de imports salvou sem solicitação")
  print("PASS: TypeScript adiciona e remove imports ao salvar e pelo atalho")

  lua('vim.api.nvim_buf_set_lines(0,0,-1,false,{"console.log(spark"}); vim.api.nvim_win_set_cursor(0,{1,17})')
  input("A<C-Space>")
  wait_for('return vim.iter(require("blink.cmp").get_items()):any(function(item) return item.label == "sparkle" end)', "Autoimport não apareceu no autocomplete", 15000)
  lua([[
    local cmp=require("blink.cmp")
    for index, item in ipairs(cmp.get_items()) do
      if item.label == "sparkle" then assert(cmp.accept({index=index})); return end
    end
    error("Sugestão sumiu")
  ]])
  wait_for('return table.concat(vim.api.nvim_buf_get_lines(0,0,-1,false),"\\n"):match("import.-sparkle.-from") ~= nil', "Aceitar autocomplete não adicionou import")
  input("<Esc>")
  wait_for('return vim.fn.mode() == "n"', "Autocomplete não saiu da edição")
  print("PASS: Blink inclui o import ao aceitar uma sugestão real do LSP")

  vim.fn.writefile({"import os", "import sys", "import json  # noqa: F401", "", "print(sys.version)", "x = missing_name"}, fixture .. "/main.py")
  open("main.py")
  ready("basedpyright")
  lua('vim.api.nvim_win_set_cursor(0,{5,8}); vim.cmd.write()')
  local py = contents("main.py")
  assert(not py:find("import os", 1, true), py)
  assert(py:find("import sys", 1, true) and py:find("import json  # noqa: F401", 1, true), py)
  assert(py:find("x = missing_name", 1, true), "Ruff aplicou correção fora dos imports")
  assert(lua('return not vim.bo.modified'))
  assert(lua('return vim.api.nvim_get_current_line()') == "print(sys.version)", "Limpeza moveu o cursor para outro trecho")
  print("PASS: Python remove import sem uso, preservando noqa, imports usados e o restante do código")

  vim.fn.writefile({"invalid = ["}, fixture .. "/ruff.toml")
  lua([[
    local notify=vim.notify
    vim.notify=function(message) _G.ruff_error=message end
    vim.api.nvim_buf_set_lines(0,0,-1,false,{"import os", "print('preservado')"})
    vim.cmd.write()
    vim.notify=notify
    assert(_G.ruff_error:find("Imports (ruff, saída",1,true))
  ]])
  assert(contents("main.py") == "import os\nprint('preservado')", "Falha do Ruff alterou conteúdo")
  vim.fn.delete(fixture .. "/ruff.toml")

  vim.fn.writefile({"module example.invalid/importstest", "", "go 1.23"}, fixture .. "/go.mod")
  vim.fn.writefile({"package main", "", 'import "os"', "", 'func main() { fmt.Println("oi") }'}, fixture .. "/main.go")
  open("main.go")
  ready("gopls")
  wait_for('return #vim.diagnostic.get(0) > 0', "gopls não analisou o arquivo", 20000)
  lua('vim.cmd.write()')
  local go = contents("main.go")
  assert(go:find('"fmt"', 1, true) and not go:find('"os"', 1, true), go)
  assert(lua('return not vim.bo.modified'))
  print("PASS: Go adiciona fmt e remove os antes de gravar")

  -- Uma falha de servidor deve avisar e preservar o arquivo que o usuário salvou.
  open("main.ts")
  lua([[
    local client=vim.lsp.get_clients({bufnr=0,name="vtsls"})[1]
    local request, notify = client.request_sync, vim.notify
    client.request_sync=function() return nil, "timeout de teste" end
    vim.notify=function(message) _G.import_error=message end
    vim.api.nvim_buf_set_lines(0,0,-1,false,{"const preserved = 123;"})
    vim.cmd.write()
    client.request_sync, vim.notify=request, notify
    assert(_G.import_error:find("timeout de teste",1,true))
  ]])
  assert(contents("main.ts") == "const preserved = 123;")
  vim.fn.writefile({"primeiro"}, fixture .. "/first.fixture")
  vim.fn.writefile({"segundo"}, fixture .. "/second.fixture")
  open("first.fixture")
  open("second.fixture")
  input("<C-M-Left>")
  wait_for('return vim.api.nvim_buf_get_name(0):match("/first.fixture$") ~= nil', "Ctrl+Alt+Left não voltou")
  input("<C-M-Right>")
  wait_for('return vim.api.nvim_buf_get_name(0):match("/second.fixture$") ~= nil', "Ctrl+Alt+Right não avançou")
  lua('vim.o.shell="/bin/sh"; vim.cmd.vsplit()')
  input("<C-S-t>")
  wait_for('return vim.bo.buftype == "terminal" and vim.fn.mode() == "t"', "Ctrl+Shift+T não abriu terminal")
  local job = lua('return vim.b.terminal_job_id')
  input("<S-Esc>")
  wait_for('return #vim.api.nvim_tabpage_list_wins(0) == 1 and vim.fn.mode() == "n"', "Shift+Esc não fechou o painel")
  assert(lua('return vim.fn.jobwait({...},0)[1]', job) == -1, "Fechar painel encerrou o shell")
  lua('vim.fn.jobstop(...)', job)
  assert(lua('return vim.v.errmsg') == "", lua('return vim.v.errmsg'))
  print("PASS: erro na organização avisa e mantém o conteúdo salvo")
  print("PASS: voltar/avançar, novo terminal e fechar painel pelos atalhos")
end, debug.traceback)
pcall(vim.rpcnotify, channel, "nvim_command", "qa!")
vim.fn.jobwait({channel}, 3000)
vim.fn.delete(fixture, "rf")
if not ok then error(err) end
