-- nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-git-ui.lua
local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local fixture = vim.fn.tempname()
vim.fn.mkdir(fixture, 'p')
local channel
local function git(...)
  local cmd = {'git', '-C', fixture}
  vim.list_extend(cmd, {...})
  local result = vim.system(cmd, {text=true}):wait()
  assert(result.code == 0, result.stderr)
  -- Simula voltar ao editor depois de executar Git em outro terminal.
  if channel then vim.rpcrequest(channel, 'nvim_exec_lua', 'vim.api.nvim_exec_autocmds("FocusGained",{})', {}) end
  return result.stdout
end
git('init', '-q')
git('config', 'user.name', 'Bob Test')
git('config', 'user.email', 'bob@example.invalid')
for _, file in ipairs({'mod 100%.fixture', 'clean.fixture', 'deleted.fixture'}) do
  vim.fn.writefile({'original'}, fixture .. '/' .. file)
end
git('add', '.')
git('commit', '-qm', 'base fixture', '--author=Alice Test <alice@example.invalid>')
channel = vim.fn.jobstart({
  vim.v.progpath, '--embed', '--headless', '-i', 'NONE', '--cmd', 'set nomore',
  '--cmd', 'set rtp+=' .. vim.fn.stdpath('data') .. '/lazy/mason.nvim',
  '--cmd', 'lua require("mason-registry").refresh = function() end',
  '-u', root .. '/nvim/init.lua',
  '-c', 'CodexCompleteDisable',
}, {rpc=true, cwd=fixture})
assert(channel > 0)
local function lua(code, ...)
  return vim.rpcrequest(channel, 'nvim_exec_lua', code, {...})
end
local function wait_for(code, message)
  local ready = vim.wait(8000, function() return lua(code) == true end, 50)
  assert(ready, message .. ' ' .. vim.inspect(lua('return {file=vim.api.nvim_buf_get_name(0), git=require("bufferbar").status(vim.api.nvim_get_current_buf()), error=vim.v.errmsg}')))
end
local function open(file)
  return lua('vim.api.nvim_cmd({cmd="edit",args={...},magic={file=false}},{}); return vim.api.nvim_get_current_buf()', fixture .. '/' .. file)
end
local function status(buf, expected)
  wait_for('return require("bufferbar").status(' .. buf .. ') == ' .. vim.inspect(expected), 'Estado Git incorreto: ' .. expected)
end
local function color(buf, expected)
  lua([[
    local buf, kind = ...
    vim.api.nvim_set_current_buf(buf)
    local state = vim.bo[buf].modified and 'ModifiedCurrent' or 'Current'
    local group = 'MiniTabline' .. kind .. state
    local bar = require('bufferbar').render()
    assert(bar:find('%#' .. group .. '#%' .. buf .. '@MiniTablineSwitchBuffer@', 1, true), bar)
    local normal = vim.api.nvim_get_hl(0, {name='Normal', link=false})
    local hl = vim.api.nvim_get_hl(0, {name=group, link=false})
    assert(hl.bg == normal.bg, 'Cor do Git mudou o fundo')
    assert(kind == '' or hl.fg ~= normal.fg, 'Arquivo alterado ficou sem cor')
    local display = vim.api.nvim_eval_statusline(vim.o.tabline, {use_tabline=true, maxwidth=200})
    assert(display.str ~= '', 'Barra não foi renderizada')
  ]], buf, expected)
end
local ok, err = xpcall(function()
  local clean = open('clean.fixture')
  status(clean, '  ')
  color(clean, '')
  wait_for('return vim.b.gitsigns_blame_line and vim.b.gitsigns_blame_line:find("Alice Test",1,true) ~= nil', 'Autor do commit não apareceu na linha')
  assert(lua('return vim.b.gitsigns_blame_line:find("base fixture",1,true) ~= nil'))

  local modified = open('mod 100%.fixture')
  status(modified, '  ')
  lua('vim.api.nvim_buf_set_lines(0,0,-1,false,{"alterada"})')
  color(modified, 'GitChange')
  lua('vim.cmd.write()')
  status(modified, ' M')
  color(modified, 'GitChange')
  wait_for('return vim.b.gitsigns_blame_line and vim.b.gitsigns_blame_line:find("Alteração local (sem commit)",1,true) ~= nil', 'Mudança local recebeu autoria de commit')
  assert(lua('return vim.api.nvim_eval_statusline(vim.o.tabline,{use_tabline=true,maxwidth=200}).str:find("100%",1,true) ~= nil'), 'Nome com % foi corrompido')
  git('add', 'mod 100%.fixture')
  status(modified, 'M ')
  color(modified, 'GitChange')
  print('PASS: autor real, alteração local, nome com % e cor preservada depois do stage')

  vim.fn.writefile({'novo'}, fixture .. '/new.fixture')
  local added = open('new.fixture')
  status(added, '??')
  color(added, 'GitAdd')
  git('add', 'new.fixture')
  status(added, 'A ')
  color(added, 'GitAdd')

  local deleted = open('deleted.fixture')
  status(deleted, '  ')
  git('rm', '-q', 'deleted.fixture')
  status(deleted, 'D ')
  color(deleted, 'GitDelete')
  lua('vim.cmd.colorscheme("pastel-branco")')
  color(modified, 'GitChange')
  color(added, 'GitAdd')
  color(deleted, 'GitDelete')
  lua('vim.cmd.colorscheme("tomorrow-zed")')
  git('mv', 'clean.fixture', 'renamed %.fixture')
  local renamed = open('renamed %.fixture')
  status(renamed, 'R ')
  color(renamed, 'GitChange')
  lua('vim.api.nvim_set_current_buf(...); vim.api.nvim_buf_set_lines(0,0,-1,false,{"depois do stage"}); vim.cmd.write()', modified)
  status(modified, 'MM')
  vim.fn.writefile({'novo sem stage'}, fixture .. '/fresh.fixture')
  lua('vim.api.nvim_buf_set_lines(0,0,-1,false,{"rascunho sem salvar"})')
  local index_before = git('write-tree')
  lua('vim.cmd.Changes()')
  wait_for([[
    local view = require('diffview.lib').get_current_view()
    return view ~= nil and #view.files.working >= 2 and #view.files.staged >= 4
  ]], 'Changes não listou stage e working tree')
  lua([[
    local view = require('diffview.lib').get_current_view()
    local paths = {}
    for _, kind in ipairs({'working', 'staged'}) do
      paths[kind] = {}
      for _, entry in ipairs(view.files[kind]) do paths[kind][entry.path] = true end
    end
    assert(paths.working['fresh.fixture'], 'Arquivo novo sem stage ausente')
    assert(paths.working['mod 100%.fixture'], 'Alteração fora do stage ausente')
    for _, name in ipairs({'mod 100%.fixture', 'new.fixture', 'deleted.fixture', 'renamed %.fixture'}) do
      assert(paths.staged[name], 'Arquivo do stage ausente: ' .. name)
    end
  ]])
  wait_for('local v=require("diffview.lib").get_current_view(); return v.cur_entry and v.cur_entry.opened == true', 'Changes não abriu o diff')
  lua('vim.cmd.DiffviewClose()')
  assert(git('write-tree') == index_before, 'A revisão modificou o stage')
  assert(vim.fn.readfile(fixture .. '/mod 100%.fixture')[1] == 'depois do stage', 'A revisão salvou o rascunho')
  assert(lua('return vim.bo[...].modified', modified), 'A revisão perdeu o rascunho')
  lua('vim.api.nvim_buf_set_lines(...,0,-1,false,{"depois do stage"}); vim.bo[...].modified=false', modified)
  git('add', 'mod 100%.fixture')
  print('PASS: Changes mostra stage, working tree, novos, removidos e renomes sem salvar ou alterar o índice')
  git('commit', '-qm', 'changes fixture')
  status(modified, '  ')
  status(added, '  ')
  color(modified, '')
  color(added, '')
  local branch = vim.trim(git('branch', '--show-current'))
  git('switch', '-qc', 'incoming')
  vim.fn.writefile({'incoming'}, fixture .. '/new.fixture')
  git('commit', '-qam', 'incoming')
  git('switch', '-q', branch)
  vim.fn.writefile({'local'}, fixture .. '/new.fixture')
  git('commit', '-qam', 'local')
  local merge = vim.system({'git','-C',fixture,'merge','incoming'}, {text=true}):wait()
  assert(merge.code == 1, 'Conflito não foi criado')
  lua('vim.api.nvim_exec_autocmds("FocusGained",{})')
  status(added, 'UU')
  color(added, 'GitDelete')
  assert(lua('return vim.v.errmsg') == '', lua('return vim.v.errmsg'))
  print('PASS: novos, removidos, renomeados e conflitos com cores, troca de tema e limpeza após commit')
end, debug.traceback)
pcall(vim.rpcnotify, channel, 'nvim_command', 'qa!')
vim.fn.jobwait({channel}, 3000)
vim.fn.delete(fixture, 'rf')
if not ok then error(err) end
