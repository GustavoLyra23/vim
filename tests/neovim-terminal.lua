-- nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-terminal.lua
local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local fixture = vim.fn.tempname()
vim.fn.mkdir(fixture, 'p')
local channel = vim.fn.jobstart({
  vim.v.progpath, '--embed', '--headless', '-i', 'NONE', '--cmd', 'set nomore',
  '--cmd', 'set rtp+=' .. vim.fn.stdpath('data') .. '/lazy/mason.nvim',
  '--cmd', 'lua require("mason-registry").refresh = function() end',
  '-u', root .. '/nvim/init.lua',
}, { rpc = true, cwd = fixture })
assert(channel > 0)
local function lua(code, ...)
  return vim.rpcrequest(channel, 'nvim_exec_lua', code, {...})
end
local function wait_for(code, message)
  assert(vim.wait(5000, function() return lua(code) end, 50), message)
end
local ok, err = xpcall(function()
  -- Shell sem configuração pessoal para verificar somente o terminal do editor.
  local original = lua('vim.o.shell="/bin/sh"; vim.api.nvim_buf_set_lines(0,0,-1,false,{"rascunho preservado"}); return vim.api.nvim_get_current_buf()')
  local windows = lua('return #vim.api.nvim_list_wins()')
  vim.rpcrequest(channel, 'nvim_input', '<Space>bt')
  wait_for('return vim.bo.buftype == "terminal" and vim.fn.mode() == "t"', 'Terminal não abriu para digitação')
  local terminal = lua('return vim.api.nvim_get_current_buf()')
  assert(terminal ~= original)
  assert(lua('return #vim.api.nvim_list_wins()') == windows, 'Terminal abriu outra janela')
  assert(lua('return vim.bo.buflisted'), 'Terminal não aparece como buffer')
  assert(lua('return MiniTabline.make_tabline_string():find("%" .. ... .. "@MiniTablineSwitchBuffer@", 1, true) ~= nil', terminal))
  lua([[vim.fn.chansend(vim.b.terminal_job_id, "pwd > " .. vim.fn.shellescape(...) .. "\n")]], fixture .. '/cwd')
  assert(vim.wait(5000, function() return vim.fn.filereadable(fixture .. '/cwd') == 1 end, 50))
  assert(vim.fn.readfile(fixture .. '/cwd')[1] == fixture, 'Shell abriu no diretório errado')
  vim.rpcrequest(channel, 'nvim_input', '<C-\\><C-n>')
  wait_for('return vim.fn.mode() == "n"', 'Não saiu da digitação do terminal')
  vim.rpcrequest(channel, 'nvim_input', '<Space>bb')
  wait_for('local p=Snacks.picker.get({source="buffers"})[1]; return p and #p:items() >= 2', 'Lista de buffers não abriu')
  lua([[
    local original, terminal = ...
    local p = Snacks.picker.get({source='buffers'})[1]
    local found = {}
    for index, item in ipairs(p:items()) do found[item.buf] = index end
    assert(found[original] and found[terminal], 'Rascunho ou terminal ausente da lista')
    p.list:move(found[original], true)
  ]], original, terminal)
  vim.rpcrequest(channel, 'nvim_input', '<CR>')
  wait_for('return vim.api.nvim_get_current_buf() == ' .. original, 'Não voltou ao rascunho')
  assert(lua('return vim.api.nvim_get_current_line()') == 'rascunho preservado')
  assert(lua('return vim.bo.modified'), 'Rascunho perdeu indicação de alteração')
  assert(lua('return vim.fn.jobwait({vim.b[...].terminal_job_id}, 0)[1]', terminal) == -1, 'Trocar de buffer encerrou o shell')
  lua('vim.fn.jobstop(vim.b[...].terminal_job_id)', terminal)
  assert(lua('return vim.v.errmsg') == '', lua('return vim.v.errmsg'))
  print('PASS: terminal listado, shell no projeto e troca de buffer preservando rascunho e processo')
end, debug.traceback)
pcall(vim.rpcnotify, channel, 'nvim_command', 'qa!')
vim.fn.jobwait({channel}, 3000)
vim.fn.delete(fixture, 'rf')
if not ok then error(err) end
