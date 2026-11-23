-- nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim.lua
local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local fixture = vim.fn.tempname()
vim.fn.mkdir(fixture, "p")
-- O sandbox bloqueia sockets usados no stdio do Node; pipes preservam o protocolo LSP.
vim.fn.mkdir(fixture .. "/bin")
vim.fn.writefile({ "#!/bin/bash", "set -o pipefail", "cat | " .. vim.fn.shellescape(vim.fn.exepath("node")) .. ' "$@" | cat' }, fixture .. "/bin/node")
vim.fn.setfperm(fixture .. "/bin/node", "rwx------")
local channel = vim.fn.jobstart({
  vim.v.progpath, "--embed", "--headless", "-i", "NONE",
  "--cmd", "set rtp+=" .. vim.fn.stdpath("data") .. "/lazy/mason.nvim",
  -- Instalações usam rede e são verificadas separadamente; este teste usa os LSPs locais.
  "--cmd", 'lua require("mason-registry").refresh = function() end',
  "-u", root .. "/nvim/init.lua",
}, { rpc = true, cwd = fixture, env = { PATH = fixture .. "/bin:" .. vim.env.PATH } })
assert(channel > 0, "Não foi possível iniciar o Neovim de teste")
local function lua(code, ...)
  return vim.rpcrequest(channel, "nvim_exec_lua", code, { ... })
end
local function wait_for(code, message, timeout)
  local ready = vim.wait(timeout or 5000, function() return lua(code) end, 50)
  assert(ready, message .. " " .. vim.inspect(lua('return {file=vim.api.nvim_buf_get_name(0), ft=vim.bo.filetype, clients=vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients()), error=vim.v.errmsg}')))
end
local function git(...)
  local cmd = { "git", "-C", fixture }
  vim.list_extend(cmd, { ... })
  local result = vim.system(cmd, { text = true }):wait()
  assert(result.code == 0, result.stderr)
  return result.stdout
end
local ok, err = xpcall(function()
  git("init", "-q")
  git("config", "user.name", "Neovim Test")
  git("config", "user.email", "neovim-test@example.invalid")
  vim.fn.writefile({ "linha original" }, fixture .. "/sample.txt")
  git("add", "sample.txt")
  git("commit", "-qm", "fixture")
  lua('vim.cmd.edit(...)', fixture .. "/sample.txt")
  vim.rpcrequest(channel, "nvim_input", "<C-d>")
  wait_for('return vim.api.nvim_buf_line_count(0) == 2', "Ctrl+D não duplicou a linha")
  vim.rpcrequest(channel, "nvim_input", "<C-z>")
  wait_for('return vim.api.nvim_buf_line_count(0) == 1', "Ctrl+Z não desfez a duplicação")
  vim.rpcrequest(channel, "nvim_input", "A alterada<Esc><C-s>")
  wait_for('return not vim.bo.modified', "Ctrl+S não salvou")
  assert(vim.fn.readfile(fixture .. "/sample.txt")[1] == "linha original alterada")
  print("PASS: editar, duplicar, desfazer e salvar pelos atalhos")

  wait_for('return vim.b.gitsigns_status_dict ~= nil', "Gitsigns não detectou o repositório")
  lua('require("gitsigns").stage_hunk()')
  assert(vim.wait(5000, function() return git("diff", "--cached"):find("original alterada", 1, true) ~= nil end, 50))
  lua('require("gitsigns").undo_stage_hunk()')
  assert(vim.wait(5000, function() return git("diff", "--cached") == "" end, 50))
  lua('vim.cmd.DiffviewOpen()')
  wait_for('return require("diffview.lib").get_current_view() ~= nil', "Diffview não abriu")
  lua('vim.cmd.DiffviewClose(); require("neogit").open()')
  wait_for('return vim.bo.filetype == "NeogitStatus"', "Neogit não abriu o painel")
  lua('require("neogit").close()')
  print("PASS: stage de trecho, desfazer stage, diff e painel de commits")

  vim.fn.writefile({ '{"name":"nvim-check","private":true}' }, fixture .. "/package.json")
  vim.fn.writefile({ '{"compilerOptions":{"strict":true}}' }, fixture .. "/tsconfig.json")
  vim.fn.writefile({ 'const person = { name: "Gustavo", age: 30 };', 'person.' }, fixture .. "/main.ts")
  lua('vim.cmd.edit(...)', fixture .. "/main.ts")
  wait_for('local c = vim.lsp.get_clients({bufnr=0, name="vtsls"})[1]; return c ~= nil and c.initialized', "vtsls não iniciou", 20000)
  local items = lua([[
    local client = vim.lsp.get_clients({bufnr=0, name="vtsls"})[1]
    local result, err = client:request_sync("textDocument/completion", {
      textDocument = {uri=vim.uri_from_bufnr(0)}, position = {line=1, character=7},
      context = {triggerKind=1},
    }, 10000, 0)
    assert(result and result.result, vim.inspect(err or result))
    return result.result.items or result.result
  ]])
  local labels = {}
  for _, item in ipairs(items) do labels[item.label] = true end
  assert(labels.name and labels.age, "Autocomplete TypeScript não trouxe as propriedades reais")
  print("PASS: autocomplete TypeScript com propriedades fornecidas pelo LSP")

  lua('vim.api.nvim_win_set_cursor(0, {2, 6})')
  vim.rpcrequest(channel, "nvim_input", "A<C-Space>")
  wait_for('return require("blink.cmp").is_menu_visible()', "Menu de autocomplete não abriu")
  vim.rpcrequest(channel, "nvim_input", "<CR>")
  wait_for('return vim.api.nvim_buf_line_count(0) == 3', "Enter aceitou uma sugestão sem seleção")
  assert(lua('return vim.api.nvim_buf_get_lines(0, 1, 2, false)[1]') == "person.")
  vim.rpcrequest(channel, "nvim_input", "<Esc>")
  lua('vim.api.nvim_buf_set_lines(0, 1, -1, false, {"person."}); vim.api.nvim_win_set_cursor(0, {2, 6})')
  vim.rpcrequest(channel, "nvim_input", "A<C-Space>")
  wait_for('return require("blink.cmp").is_menu_visible()', "Menu não reabriu")
  vim.rpcrequest(channel, "nvim_input", "<Tab>")
  wait_for('return require("blink.cmp").get_selected_item() ~= nil', "Tab não selecionou uma sugestão")
  vim.rpcrequest(channel, "nvim_input", "<CR>")
  wait_for('return vim.api.nvim_buf_get_lines(0, 1, 2, false)[1]:match("^person%.%a+") ~= nil', "Tab + Enter não aceitou a sugestão")
  vim.rpcrequest(channel, "nvim_input", "<Esc>")
  lua('vim.cmd.write()')
  print("PASS: menu real, Enter sem seleção e aceite com Tab + Enter")

  vim.fn.writefile({ "name = 'Gustavo'", "name." }, fixture .. "/main.py")
  lua('vim.cmd.edit(...)', fixture .. "/main.py")
  wait_for('local c = vim.lsp.get_clients({bufnr=0, name="basedpyright"})[1]; return c ~= nil and c.initialized', "basedpyright não iniciou", 20000)
  local python_items = lua([[
    local client = vim.lsp.get_clients({bufnr=0, name="basedpyright"})[1]
    local result, err = client:request_sync("textDocument/completion", {
      textDocument = {uri=vim.uri_from_bufnr(0)}, position = {line=1, character=5},
      context = {triggerKind=1},
    }, 10000, 0)
    assert(result and result.result, vim.inspect(err or result))
    return result.result.items or result.result
  ]])
  assert(vim.iter(python_items):any(function(item) return item.label == "upper" end), "Autocomplete Python não trouxe str.upper")
  print("PASS: autocomplete Python com métodos de string")

  for _, case in ipairs({
    { "style.css", "body { color: red; }", "cssls" },
    { "index.html", "<div>Neovim</div>", "html" },
    { "data.json", '{"name":"Neovim"}', "jsonls" },
    { "data.yaml", "name: Neovim", "yamlls" },
    { "script.sh", "echo Neovim", "bashls" },
    { "sample.c", "int main(void) { return 0; }", "clangd" },
    { "Dockerfile", "FROM scratch", "docker_language_server" },
  }) do
    vim.fn.writefile({ case[2] }, fixture .. "/" .. case[1])
    lua('vim.cmd.edit(...)', fixture .. "/" .. case[1])
    wait_for('local c=vim.lsp.get_clients({bufnr=0,name=' .. vim.inspect(case[3]) .. '})[1]; return c ~= nil and c.initialized', case[3] .. " não iniciou", 10000)
  end
  print("PASS: inicialização de CSS, HTML, JSON, YAML, shell, C e Docker")

  assert(lua([[
    local root_dir = require("languages").servers.gradle_ls.root_dir
    for _, name in ipairs({"build.gradle", "build.gradle.kts", "Main.kt", "Main.groovy"}) do
      local called = false
      root_dir(vim.fn.bufadd(vim.fn.getcwd() .. "/" .. name), function() called = true end)
      assert(called == (name == "build.gradle" or name == "build.gradle.kts"), name)
    end
    return true
  ]]))
  print("PASS: servidor Gradle só atende arquivos de build")

  git("add", "sample.txt")
  git("commit", "-qm", "base para conflito")
  local branch = vim.trim(git("branch", "--show-current"))
  git("switch", "-qc", "incoming")
  vim.fn.writefile({ "alteracao incoming" }, fixture .. "/sample.txt")
  git("commit", "-qam", "incoming")
  git("switch", "-q", branch)
  vim.fn.writefile({ "alteracao local" }, fixture .. "/sample.txt")
  git("commit", "-qam", "local")
  local merge = vim.system({ "git", "-C", fixture, "merge", "incoming" }, { text = true }):wait()
  assert(merge.code == 1, "O cenário de conflito não foi criado")
  lua('vim.cmd.DiffviewOpen()')
  wait_for('local v=require("diffview.lib").get_current_view(); return v ~= nil and #v.files.conflicting == 1', "Diffview não mostrou o conflito")
  lua('local v=require("diffview.lib").get_current_view(); v:set_file(v.files.conflicting[1])')
  wait_for('return #vim.api.nvim_tabpage_list_wins(0) >= 4', "Painéis de comparação e resolução não abriram")
  lua('vim.cmd.DiffviewClose()')
  print("PASS: conflito real exibido com painéis de comparação e resolução")

  -- A abertura do terminal é verificada em PTY; aqui conferimos comandos e diretório.
  local calls = lua([[
    local terminal, calls = Snacks.terminal, {}
    Snacks.terminal = function(cmd, opts) table.insert(calls, {cmd=cmd, cwd=opts.cwd}) end
    require("keymaps").codex(false)
    require("keymaps").codex(true)
    Snacks.terminal = terminal
    return calls
  ]])
  assert(vim.deep_equal(calls[1], { cmd = { "codex" }, cwd = fixture }))
  assert(vim.deep_equal(calls[2], { cmd = { "codex", "resume" }, cwd = fixture }))
  print("PASS: comandos de conversa e retomada usam o projeto atual, sem chamar IA")

  lua('require("lazy").load({plugins={"octo.nvim"}})')
  assert(lua('return vim.fn.exists(":Octo")') == 2)
  assert(lua('return require("octo.config").values.picker') == "snacks")
  print("PASS: painel de PRs carregado sem enviar ações ao GitHub")
  assert(lua('return vim.v.errmsg') == "", "Erros durante o teste: " .. lua('return vim.v.errmsg'))
end, debug.traceback)
pcall(vim.rpcnotify, channel, "nvim_command", "qa!")
vim.fn.jobwait({ channel }, 3000)
vim.fn.delete(fixture, "rf")
if not ok then error(err) end
print("PASS: verificações do Neovim concluídas")
