-- nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-ai.lua
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.abspath(debug.getinfo(1, "S").source:sub(2))))
local plugin = vim.fn.stdpath("data") .. "/lazy/codex-complete.nvim"
local fixture = vim.fn.tempname()
vim.fn.mkdir(fixture, "p")
assert(vim.system({"git", "init", "-q", fixture}):wait().code == 0)
local lines = {}
for i = 1, 600 do lines[i] = "-- contexto " .. i .. " " .. string.rep("x", 70) end
lines[601], lines[602] = "return exampleGreeting", "-- contexto depois do cursor"
vim.fn.writefile(lines, fixture .. "/main.lua")
vim.fn.writefile({'function exampleGreeting() return "salvo" end'}, fixture .. "/helper.lua")
local channel = vim.fn.jobstart({
  vim.v.progpath, "--embed", "--headless", "-i", "NONE", "--cmd", "set nomore",
  "--cmd", "set rtp^=" .. root .. "/nvim",
  "--cmd", "set rtp+=" .. vim.fn.stdpath("data") .. "/lazy/mason.nvim",
  "--cmd", 'lua require("mason-registry").refresh = function() end',
  "-u", root .. "/nvim/init.lua",
}, {rpc=true, cwd=fixture})
assert(channel > 0)
local function lua(code, ...) return vim.rpcrequest(channel, "nvim_exec_lua", code, {...}) end
local function input(keys) vim.rpcrequest(channel, "nvim_input", keys) end
local function wait_for(code, message)
  assert(vim.wait(6000, function() return lua(code) == true end, 20), message .. " " .. vim.inspect(lua('return require("codex_complete").status()')))
end
local ok, err = xpcall(function()
  lua([[
    vim.lsp.enable(vim.tbl_keys(require("languages").servers), false)
    local ai = require("codex_complete")
    local cfg = vim.deepcopy(ai._state.config)
    assert(cfg.enabled and cfg.auto_trigger and cfg.debounce_ms == 1000)
    assert(cfg.highlights.background == false)
    assert(vim.fn.maparg("<leader>ar", "n", false, true).desc == "Codex: retomar conversa")
    cfg.codex.command = {"python3", ..., "--expect-model", "gpt-6-astra", "--expect-effort", "low", "--delay"}
    ai.setup(cfg)
    _G.ai_requests = {}
    local client = ai._state.engine.client
    local request = client.request
    client.request = function(self, method, params, callback)
      _G.ai_requests[method] = vim.deepcopy(params)
      return request(self, method, params, callback)
    end
  ]], plugin .. "/tests/fixtures/mock_codex.py")
  lua('vim.cmd.edit(...); vim.api.nvim_buf_set_lines(0,0,-1,false,{\'function exampleGreeting() return "rascunho relacionado" end\'})', fixture .. "/helper.lua")
  lua('vim.cmd.edit(...); vim.api.nvim_win_set_cursor(0,{601,20})', fixture .. "/main.lua")
  input("A ")
  wait_for('return require("codex_complete").status().suggestion_visible', "IA automática não apareceu")
  lua([[
    assert(vim.api.nvim_get_current_line() == "return exampleGreeting ", "Sugestão alterou o buffer antes do aceite")
    local thread, turn = _G.ai_requests["thread/start"], _G.ai_requests["turn/start"]
    assert(thread.ephemeral and thread.sandbox == "read-only" and thread.approvalPolicy == "never")
    assert(turn.sandboxPolicy.type == "readOnly" and turn.sandboxPolicy.networkAccess == false)
    local payload = vim.json.decode(turn.input[1].text)
    assert(#payload.prefix > 24 * 1024 and #payload.prefix + #payload.suffix <= 128 * 1024)
    assert(payload.suffix:find("contexto depois do cursor", 1, true))
    assert(vim.json.encode(payload.related):find("rascunho relacionado", 1, true), "Definição não salva ficou fora do contexto")
  ]])
  input("<C-Space>")
  wait_for('return require("blink.cmp").is_visible()', "Ctrl+Espaço não abriu menu de linguagem")
  input("<Tab>")
  wait_for('return require("blink.cmp").get_selected_item() ~= nil', "Tab não selecionou item do menu")
  assert(lua('return vim.api.nvim_get_current_line()') == "return exampleGreeting ", "Tab aceitou IA ou inseriu texto sem confirmação")
  input("<M-;>")
  wait_for('return vim.api.nvim_buf_get_lines(0,601,602,false)[1] == "next_line()"', "Alt+; não aceitou a IA")
  assert(vim.fn.readfile(fixture .. "/main.lua")[601] == lines[601], "Aceitar IA salvou arquivo sem solicitação")
  print("PASS: sugestão automática, aceite por Alt+;, Blink e contexto ampliado com rascunho relacionado")

  input("<M-s>")
  wait_for('return require("codex_complete").status().suggestion_visible', "Alt+S não pediu sugestão")
  input("<M-x>")
  wait_for('return not require("codex_complete").status().suggestion_visible', "Alt+X não descartou")
  lua('require("codex_complete")._state.config.auto_trigger = false; _G.ai_requests["turn/start"] = nil')
  input("<M-s>")
  wait_for('return _G.ai_requests["turn/start"] ~= nil', "Pedido não chegou ao servidor")
  input("z")
  vim.wait(600)
  lua([[
    local s = require("codex_complete").status()
    assert(not s.engine.active and not s.suggestion_visible, "Resposta atrasada reapareceu")
    require("codex_complete")._state.config.auto_trigger = true
  ]])
  input("<Esc><Esc>")
  wait_for('return vim.fn.mode() == "n"', "Não saiu da edição")
  input(" at")
  wait_for('return not require("codex_complete").status().enabled', "Espaço a t não desligou IA")
  input(" at")
  wait_for('return require("codex_complete").status().enabled', "Espaço a t não religou IA")
  print("PASS: solicitar, descartar, cancelar resposta atrasada e alternar IA pelos atalhos")

  lua([[
    local context = require("codex_complete.context")
    local cfg = require("codex_complete")._state.config
    for _, ft in ipairs({"odin", "gdscript", "gdshader", "groovy", "terraform-vars", "lhaskell", "cabal"}) do
      vim.bo.filetype = ft
      assert(context.eligible(0, cfg, false), "IA indisponível para " .. ft)
    end
    vim.cmd.enew()
    vim.cmd.file(".env.local")
    vim.bo.filetype = "sh"
    assert(not context.eligible(0, cfg, true), ".env entrou no coletor")
    assert(vim.v.errmsg == "", vim.v.errmsg)
  ]])
  print("PASS: linguagens adicionais e exclusão de .env no coletor")
end, debug.traceback)
pcall(vim.rpcnotify, channel, "nvim_command", "qa!")
vim.fn.jobwait({channel}, 3000)
vim.fn.delete(fixture, "rf")
if not ok then error(err) end
