-- nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-themes.lua
local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local channel = vim.fn.jobstart({
  vim.v.progpath, "--embed", "--headless", "-i", "NONE",
  "--cmd", "set nomore",
  "--cmd", "set rtp+=" .. vim.fn.stdpath("data") .. "/lazy/mason.nvim",
  "--cmd", 'lua require("mason-registry").refresh = function() end',
  "-u", root .. "/nvim/init.lua",
}, { rpc = true, cwd = root })
assert(channel > 0)
local function lua(code, ...)
  return vim.rpcrequest(channel, "nvim_exec_lua", code, { ... })
end
local function wait_for(code, message)
  assert(vim.wait(5000, function() return lua(code) end, 50), message)
end
local ok, err = xpcall(function()
  assert(lua('return vim.g.colors_name') == "tomorrow-zed")
  lua([[
    function _G.check_tabline()
      local normal = vim.api.nvim_get_hl(0, {name='Normal', link=false})
      for _, group in ipairs(vim.fn.getcompletion('MiniTabline', 'highlight')) do
        local hl = vim.api.nvim_get_hl(0, {name=group, link=false})
        assert(hl.bg == normal.bg, group .. ' tem fundo diferente do editor')
        if not group:find('MiniTablineGit', 1, true) then
          assert(hl.fg == normal.fg, group .. ' mudou a cor de um buffer sem alterações')
        end
      end
      assert(vim.api.nvim_get_hl(0, {name='MiniTablineCurrent'}).bold, 'Buffer ativo sem indicação')
      assert(vim.api.nvim_get_hl(0, {name='MiniTablineModifiedHidden'}).underline, 'Buffer modificado sem indicação')
    end
    check_tabline()
  ]])
  local count = lua([[
    local schemes = vim.fn.globpath(vim.fn.stdpath('data') .. '/lazy/tinted-nvim', 'colors/*.vim', false, true)
    assert(#schemes >= 200, 'Coleção de temas incompleta')
    for _, path in ipairs(schemes) do
      local name = vim.fn.fnamemodify(path, ':t:r')
      vim.cmd.colorscheme(name)
      local normal = vim.api.nvim_get_hl(0, {name='Normal', link=false})
      assert(normal.fg and normal.bg, name .. ' não definiu as cores do editor')
      check_tabline()
    end
    vim.cmd.colorscheme('tomorrow-zed')
    return #schemes
  ]])
  print('PASS: ' .. count .. ' temas da coleção carregam sem erros')

  local pastel = vim.json.decode(table.concat(vim.fn.readfile(root .. '/zed/themes/pastel-branco.json'), '\n')).themes[1].style
  lua([[
    local style = ...
    vim.cmd.colorscheme('pastel-branco')
    local function color(hex) return tonumber(hex:sub(2), 16) end
    local normal = vim.api.nvim_get_hl(0, {name='Normal', link=false})
    assert(normal.bg == color(style['editor.background']))
    assert(normal.fg == color(style['editor.foreground']))
    for group, token in pairs({
      Comment='comment', Keyword='keyword', Statement='keyword', Type='type',
      Function='function', Number='number', String='string', Boolean='boolean',
      Constant='constant', PreProc='preproc', Define='preproc', Macro='function.macro',
      Identifier='variable', Operator='operator', Delimiter='punctuation',
    }) do
      assert(vim.api.nvim_get_hl(0, {name=group, link=false}).fg == color(style.syntax[token].color), group)
    end
    for _, group in ipairs({'LineNr', 'SignColumn', 'CursorLine', 'EndOfBuffer'}) do
      local hl = vim.api.nvim_get_hl(0, {name=group, link=false})
      assert((hl.bg or normal.bg) == normal.bg, group)
    end
    assert(vim.opt.fillchars:get().eob == '~')
    check_tabline()
    vim.cmd.colorscheme('tomorrow-zed')
  ]], pastel)
  print('PASS: Pastel Branco tem a mesma paleta nos dois editores e fundo uniforme')

  for _, confirm in ipairs({false, true}) do
    lua('vim.cmd.Temas()')
    wait_for('local p=Snacks.picker.get({source="colorschemes"})[1]; return p and #p:items() >= 200 and vim.fn.mode() == "i"', 'Seletor não abriu')
    vim.rpcrequest(channel, 'nvim_input', 'pastel-branco')
    wait_for('return vim.g.colors_name == "pastel-branco"', 'Prévia não aplicou o tema selecionado')
    lua([[
      local picker = Snacks.picker.get({source='colorschemes'})[1]
      assert(picker:current().text == 'pastel-branco')
      local buf = picker.preview.win.buf
      assert(vim.bo[buf].syntax == 'c' or vim.treesitter.highlighter.active[buf], 'Prévia sem destaque de sintaxe')
      local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
      assert(text:find('ListNode', 1, true), 'Prévia não mostrou a amostra de código')
    ]])
    vim.rpcrequest(channel, 'nvim_input', confirm and '<CR>' or '<Esc><Esc>')
    local expected = confirm and 'pastel-branco' or 'tomorrow-zed'
    wait_for('return #Snacks.picker.get({source="colorschemes"}) == 0 and vim.fn.mode() == "n" and vim.g.colors_name == ' .. vim.inspect(expected), 'Confirmar/cancelar deixou o tema errado')
    assert(lua('return vim.o.background') == (confirm and 'light' or 'dark'))
  end
  lua('vim.cmd.colorscheme("tomorrow-zed")')
  assert(lua('return vim.v.errmsg') == '', lua('return vim.v.errmsg'))
  print('PASS: prévia em C, Esc restaura o tema, Enter aplica e a barra mantém o fundo uniforme')
end, debug.traceback)
pcall(vim.rpcnotify, channel, 'nvim_command', 'qa!')
vim.fn.jobwait({channel}, 3000)
if not ok then error(err) end
