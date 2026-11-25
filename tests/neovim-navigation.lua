-- nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-navigation.lua
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.abspath(debug.getinfo(1, "S").source:sub(2))))
local fixture = vim.fn.tempname()
vim.fn.mkdir(fixture, "p")
vim.fn.writefile({"module example.invalid/navigation", "", "go 1.23"}, fixture .. "/go.mod")
local lines = {
  "package navigation", "", "var Counter = 1", "",
  "func First() {", "  Counter++", "}", "", "type Server struct{}",
  "func (s Server) Second() {}", "", "func Third() {}",
}
vim.fn.writefile(lines, fixture .. "/main.go")
local channel = vim.fn.jobstart({
  vim.v.progpath, "--embed", "--headless", "-i", "NONE", "--cmd", "set nomore",
  "--cmd", "set rtp^=" .. root .. "/nvim",
  "--cmd", "set rtp+=" .. vim.fn.stdpath("data") .. "/lazy/mason.nvim",
  "--cmd", 'lua require("mason-registry").refresh = function() end',
  "-u", root .. "/nvim/init.lua",
}, {rpc=true, cwd=fixture, env={GOPROXY="off", GOTOOLCHAIN="local"}})
assert(channel > 0)
local function lua(code, ...) return vim.rpcrequest(channel, "nvim_exec_lua", code, {...}) end
local function input(keys) vim.rpcrequest(channel, "nvim_input", keys) end
local function wait_for(code, message, timeout)
  assert(vim.wait(timeout or 5000, function() return lua(code) == true end, 50), message .. " " .. vim.inspect(lua('return {line=vim.fn.line("."),error=vim.v.errmsg}')))
end
local function jump(keys, line)
  input(keys)
  wait_for('return vim.fn.line(".") == ' .. line, keys .. " não chegou à linha " .. line)
end
local ok, err = xpcall(function()
  lua('vim.cmd.edit(...)', fixture .. "/main.go")
  wait_for('local c=vim.lsp.get_clients({bufnr=0,name="gopls"})[1]; return c ~= nil and c.initialized', "gopls não iniciou", 20000)
  jump("<C-M-Down>", 5)
  jump("<C-M-Down>", 10)
  jump("<C-M-Left>", 5)
  jump("<C-M-Right>", 10)
  jump("<C-M-Up>", 5)
  jump("i<C-M-Down>", 10)
  assert(lua('return vim.fn.mode()') == "i", "Salto saiu do modo de edição")
  jump("<C-M-Up>", 5)
  input("<Esc><Esc>")
  wait_for('return vim.fn.mode() == "n"', "Não saiu da edição")
  print("PASS: quatro setas com Ctrl+Alt, funções e métodos do gopls, inclusive no modo de edição")

  lua('vim.api.nvim_win_set_cursor(0,{12,5}); _G.nav_notice=nil; vim.notify=function(message) _G.nav_notice=message end')
  input("<C-M-Down>")
  wait_for('return _G.nav_notice ~= nil', "Fim do arquivo não avisou")
  assert(lua('return vim.fn.line(".")') == 12, "Salto voltou ao início sem solicitação")
  lua('vim.api.nvim_win_set_cursor(0,{1,0}); _G.nav_notice=nil')
  input("<C-M-Up>")
  wait_for('return _G.nav_notice ~= nil', "Início do arquivo não avisou")
  assert(lua('return vim.fn.line(".")') == 1)
  assert(vim.deep_equal(lua('return vim.api.nvim_buf_get_lines(0,0,-1,false)'), lines), "Navegação alterou código")
  print("PASS: limites do arquivo avisam e preservam o código")

  lua([[
    local original = vim.lsp.buf.document_symbol
    local pending
    vim.lsp.buf.document_symbol = function(opts) pending = opts.on_list end
    local navigation = require("keymaps").goto_function
    local symbols = {items={{kind="Function",lnum=12,col=6},{kind="Variable",lnum=3,col=5},{kind="Function",lnum=5,col=6}}}
    navigation(1)
    pending(symbols)
    assert(vim.fn.line(".") == 5, "Não escolheu a função mais próxima")
    navigation(1)
    vim.api.nvim_win_set_cursor(0,{6,2})
    pending(symbols)
    assert(vim.fn.line(".") == 6, "Resposta atrasada moveu o cursor")
    navigation(1)
    vim.api.nvim_buf_set_lines(0,2,3,false,{"var Counter = 2"})
    pending(symbols)
    assert(vim.fn.line(".") == 6, "Resposta anterior à edição moveu o cursor")
    navigation(1)
    vim.cmd.enew()
    pending(symbols)
    assert(vim.fn.line(".") == 1 and vim.api.nvim_buf_get_name(0) == "", "Resposta atrasada mudou outro buffer")
    vim.lsp.buf.document_symbol = original
    assert(vim.v.errmsg == "", vim.v.errmsg)
  ]])
  print("PASS: símbolos fora de ordem e respostas após mover, editar ou trocar de buffer")
end, debug.traceback)
pcall(vim.rpcnotify, channel, "nvim_command", "qa!")
vim.fn.jobwait({channel}, 3000)
vim.fn.delete(fixture, "rf")
if not ok then error(err) end
