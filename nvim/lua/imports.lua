local M = {}
local actions = {
  gopls = { "source.organizeImports" },
  vtsls = { "source.addMissingImports.ts", "source.organizeImports" },
}

local function request(client, method, params, buf)
  local response, err = client:request_sync(method, params, 2000, buf)
  if not response or response.err then
    error(("Imports (%s): %s"):format(client.name, vim.inspect(err or response.err)))
  end
  return response.result
end

function M.organize(buf, automatic)
  buf = buf or vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype ~= "" or file == "" then return end

  if vim.bo[buf].filetype == "python" and vim.fn.executable("ruff") == 1 then
    local before = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
    -- Limita as correções a imports, preservando noqa e fixes marcados como inseguros.
    local result = vim.system({
      "ruff", "check", "--fix-only", "--select", "F401,I", "--no-unsafe-fixes",
      "--stdin-filename", file, "-",
    }, { stdin = before, text = true, cwd = vim.fs.dirname(file) }):wait(2000)
    if result.code ~= 0 then error(("Imports (ruff, saída %d): %s"):format(result.code, result.stderr or "")) end
    if result.stdout ~= before then
      -- Aplica apenas os trechos alterados para preservar o cursor no restante do código.
      local changes = vim.text.diff(before, result.stdout, { result_type = "indices" })
      local lines = vim.split(result.stdout, "\n", { plain = true })
      for index = #changes, 1, -1 do
        local old_start, old_count, new_start, new_count = unpack(changes[index])
        local first = old_count == 0 and old_start or old_start - 1
        vim.api.nvim_buf_set_lines(buf, first, first + old_count, false,
          vim.list_slice(lines, new_start, new_start + new_count - 1))
      end
    end
    return
  end

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf, method = "textDocument/codeAction" })) do
    if actions[client.name] then
      for _, kind in ipairs(actions[client.name]) do
        local result = request(client, "textDocument/codeAction", {
          textDocument = { uri = vim.uri_from_bufnr(buf) },
          range = { start = { line = 0, character = 0 }, ["end"] = { line = 0, character = 0 } },
          context = { only = { kind }, diagnostics = {}, triggerKind = 1 },
        }, buf)
        for _, action in ipairs(result or {}) do
          if action.kind == kind and not action.disabled then
            if not action.edit and not action.command and client:supports_method("codeAction/resolve") then
              action = request(client, "codeAction/resolve", action, buf)
            end
            if action.edit then vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding) end
            if action.command then
              request(client, "workspace/executeCommand", action.command, buf)
            end
          end
        end
      end
      return
    end
  end
  if not automatic then
    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
  end
end

vim.api.nvim_create_user_command("OrganizarImports", function() M.organize() end, { desc = "Adicionar e limpar imports" })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("AutomaticImports", { clear = true }),
  callback = function(event)
    local ok, err = pcall(M.organize, event.buf, true)
    if not ok then vim.notify(err, vim.log.levels.ERROR) end
  end,
})

return M
