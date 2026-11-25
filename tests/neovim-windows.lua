-- nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-windows.lua
local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local channel = vim.fn.jobstart({
  vim.v.progpath, "--embed", "--headless", "-i", "NONE", "--cmd", "set nomore",
  "--cmd", "set rtp^=" .. root .. "/nvim",
  "--cmd", "set rtp+=" .. vim.fn.stdpath("data") .. "/lazy/mason.nvim",
  "--cmd", 'lua require("mason-registry").refresh = function() end',
  "-u", root .. "/nvim/init.lua",
}, { rpc = true, cwd = root })
assert(channel > 0)
local function lua(code, ...)
  return vim.rpcrequest(channel, "nvim_exec_lua", code, { ... })
end
local function input(keys)
  vim.rpcrequest(channel, "nvim_input", keys)
end
local function wait_for(code, message)
  assert(vim.wait(5000, function() return lua(code) == true end, 50), message)
end
local function borderless(win)
  wait_for(("return vim.api.nvim_win_get_config(%d).border == 'none'"):format(win), "Janela com borda: " .. win)
end
local ok, err = xpcall(function()
  wait_for('return vim.v.vim_did_enter == 1', "Neovim não terminou de iniciar")
  lua('Snacks.input.enable()') -- No modo gráfico, isso ocorre no evento UIEnter.
  local original = lua('return vim.api.nvim_get_current_win()')
  for _, key in ipairs({ "<Esc>", "q", "<Space>x" }) do
    input("<Space>n")
    wait_for('return vim.bo.filetype == "snacks_notif_history"', "Histórico não abriu")
    local history = lua('return vim.api.nvim_get_current_win()')
    borderless(history)
    input(key)
    wait_for('return not vim.api.nvim_win_is_valid(' .. history .. ')', "Histórico não fechou: " .. key)
    assert(lua('return vim.api.nvim_get_current_win()') == original)
  end
  print("PASS: histórico da foto sem borda; Esc, q e Espaço x fecham")

  -- Reproduz plugins que ignoram winborder e definem uma borda explícita.
  local custom = lua([[
    return vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), false, {
      relative="editor", row=1, col=1, width=30, height=4,
      border="double", title="Título", footer="Rodapé",
    })
  ]])
  borderless(custom)
  lua('vim.api.nvim_win_close(..., false)', custom)
  local diagnostic = lua([[
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {"rascunho preservado"})
    local ns = vim.api.nvim_create_namespace("window-test")
    vim.diagnostic.set(ns, 0, {{lnum=0, col=0, message="Exemplo", severity=vim.diagnostic.severity.WARN}})
    local _, win = vim.diagnostic.open_float({focusable=true})
    return win
  ]])
  borderless(diagnostic)
  lua('local win=...; if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, false) end', diagnostic)
  lua('vim.ui.input({prompt="Nome: "}, function(value) _G.input_cancelled = value == nil end)')
  wait_for('return vim.bo.filetype == "snacks_input" and vim.fn.mode() == "i"', "Input não abriu")
  borderless(lua('return vim.api.nvim_get_current_win()'))
  assert(lua('return vim.wo.statuscolumn:find("Nome:", 1, true) ~= nil'), "Input perdeu o rótulo ao remover a borda")
  input("<Esc>")
  wait_for('return vim.fn.mode() == "n"', "Input não saiu da digitação")
  input("<Esc>")
  wait_for('return _G.input_cancelled == true and vim.fn.mode() == "n"', "Input não cancelou")
  print("PASS: bordas explícitas, diagnóstico e campo de entrada")

  lua([[
    require("lazy").load({plugins={"octo.nvim"}})
    _G.octo_test_win = require("octo.ui.window").create_centered_float({content={"Prévia local"}, header="Octo"})
  ]])
  borderless(lua('return _G.octo_test_win'))
  lua('vim.api.nvim_win_close(_G.octo_test_win, false)')
  for _, theme in ipairs({"pastel-branco", "tomorrow-zed"}) do
    lua('vim.cmd.colorscheme(...)', theme)
    input("<Space>bb")
    wait_for('local p=Snacks.picker.get({source="buffers"})[1]; return p ~= nil and p.input.win:valid() and vim.fn.mode() == "i"', "Busca não abriu")
    lua([[
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        assert(config.relative == "" or not config.border or config.border == "none", "Borda na busca")
      end
    ]])
    input("<Esc><Esc>")
    wait_for('return #Snacks.picker.get({source="buffers"}) == 0 and vim.fn.mode() == "n"', "Busca não fechou")
  end
  print("PASS: popup do Octo e buscas nos temas claro e escuro")

  input("<Space>bv")
  wait_for('return #vim.api.nvim_tabpage_list_wins(0) == 2', "Divisão vertical não abriu")
  assert(lua('return vim.fn.winlayout()[1]') == "row", "Painéis não ficaram lado a lado")
  assert(lua('return vim.api.nvim_win_get_position(0)[2]') > 0, "Novo painel não ficou à direita")
  local draft = lua('vim.cmd.enew(); vim.api.nvim_buf_set_lines(0,0,-1,false,{"segundo rascunho"}); return vim.api.nvim_get_current_buf()')
  input("<Space>x")
  wait_for('return #vim.api.nvim_tabpage_list_wins(0) == 1', "Painel não fechou")
  assert(lua('return vim.api.nvim_get_current_line()') == "rascunho preservado")
  assert(lua('return vim.bo[...].modified', draft), "Fechar painel descartou a alteração")
  assert(lua('return vim.api.nvim_buf_get_lines(...,0,-1,false)[1]', draft) == "segundo rascunho")
  assert(lua('return vim.v.errmsg') == "", lua('return vim.v.errmsg'))
  print("PASS: divisão à direita e fechamento preservam os dois rascunhos")
end, debug.traceback)
pcall(vim.rpcnotify, channel, "nvim_command", "qa!")
vim.fn.jobwait({ channel }, 3000)
if not ok then error(err) end
