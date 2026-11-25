local M = {}
local repositories = {}

local function refresh_repo(root)
  local repo = repositories[root] or { files = {} }
  repositories[root] = repo
  if repo.running then repo.dirty = true; return end
  repo.running = true
  vim.system({ "git", "-C", root, "--no-optional-locks", "status", "--porcelain=v1", "-z", "--untracked-files=all" }, {},
    vim.schedule_wrap(function(result)
      repo.running = false
      repo.files = {}
      if result.code == 0 then
        local entries = vim.split(result.stdout, "\0", { trimempty = true })
        local i = 1
        while i <= #entries do
          local status, path = entries[i]:sub(1, 2), entries[i]:sub(4)
          repo.files[root .. "/" .. path] = status
          -- No formato -z, renomes e cópias têm um segundo campo com o caminho anterior.
          i = i + (status:find("[RC]") and 2 or 1)
        end
        repo.error = nil
      elseif repo.error ~= result.stderr then
        repo.error = result.stderr
        vim.notify("Falha ao atualizar as cores do Git: " .. result.stderr, vim.log.levels.WARN)
      end
      vim.cmd.redrawtabline()
      if repo.dirty then repo.dirty = false; refresh_repo(root) end
    end))
end

function M.refresh()
  local roots = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      local root = Snacks.git.get_root(buf)
      if root then roots[root] = true end
    end
  end
  for root in pairs(roots) do refresh_repo(root) end
end

function M.status(buf)
  if vim.bo[buf].buftype ~= "" then return "  " end
  local root = Snacks.git.get_root(buf)
  local repo = root and repositories[root]
  return repo and repo.files[vim.api.nvim_buf_get_name(buf)] or "  "
end

local function colors()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  for kind, source in pairs({ [""] = "Normal", GitAdd = "GitSignsAdd", GitChange = "GitSignsChange", GitDelete = "GitSignsDelete" }) do
    local fg = vim.api.nvim_get_hl(0, { name = source, link = false }).fg or normal.fg
    for _, state in ipairs({ "Current", "Visible", "Hidden", "ModifiedCurrent", "ModifiedVisible", "ModifiedHidden", "Fill", "Tabpagesection", "Trunc" }) do
      vim.api.nvim_set_hl(0, "MiniTabline" .. kind .. state, {
        fg = fg, bg = normal.bg,
        bold = state:find("Current") ~= nil,
        underline = state:find("Modified") ~= nil,
      })
    end
  end
end

function M.render()
  -- Mantém os rótulos, cliques e truncamento do mini.tabline; troca só o destaque.
  return MiniTabline.make_tabline_string():gsub("%%#MiniTabline([^#]+)#%%(%d+)@MiniTablineSwitchBuffer@", function(state, id)
    local buf = tonumber(id)
    local status = M.status(buf)
    local kind = ""
    if status:find("[DU]") or status == "AA" then
      kind = "GitDelete"
    elseif status == "??" or status:find("[AC]") then
      kind = "GitAdd"
    elseif status:find("[MRT]") or (vim.bo[buf].buftype == "" and vim.bo[buf].modified) then
      kind = "GitChange"
    end
    return "%#MiniTabline" .. kind .. state .. "#%" .. id .. "@MiniTablineSwitchBuffer@"
  end)
end

function M.setup()
  require("mini.tabline").setup({ show_icons = false })
  vim.o.tabline = "%!v:lua.require'bufferbar'.render()"
  local group = vim.api.nvim_create_augroup("BufferBar", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = colors })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufFilePost", "FileChangedShellPost", "FocusGained", "TermLeave", "TermClose" },
    { group = group, callback = M.refresh })
  vim.api.nvim_create_autocmd("User", { group = group, pattern = { "GitSignsUpdate", "NeogitStatusRefreshed" }, callback = M.refresh })
  colors()
  M.refresh()
end

return M
