-- nvim --headless -u NONE -i NONE -l ~/.config/nvim/tests/background.lua
local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
vim.opt.rtp:prepend(root)
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/mini.nvim")

local groups = { "Normal", "NormalNC", "LineNr", "CursorLineNr", "SignColumn", "FoldColumn", "CursorLine", "EndOfBuffer" }
vim.env.TERM_PROGRAM = "Alacritty"
vim.cmd.colorscheme("tomorrow-zed")
local opaque = {}
for _, group in ipairs(groups) do
  opaque[group] = vim.api.nvim_get_hl(0, { name = group, link = false })
end
assert(opaque.Normal.bg == 0x1e1f21 and opaque.Normal.fg == 0xc5c8c6)
local popup = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })

vim.env.TERM_PROGRAM = "ghostty"
vim.cmd.colorscheme("tomorrow-zed")
for _, group in ipairs(groups) do
  local expected = vim.deepcopy(opaque[group])
  expected.bg = nil
  assert(vim.deep_equal(vim.api.nvim_get_hl(0, { name = group, link = false }), expected), group)
end
assert(vim.deep_equal(vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false }), popup))

vim.cmd.colorscheme("pastel-branco")
assert(vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg == 0xfdfcf9)
vim.env.TERM_PROGRAM = "Alacritty"
vim.cmd.colorscheme("tomorrow-zed")
assert(vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg == opaque.Normal.bg)
assert(vim.v.errmsg == "", vim.v.errmsg)
print("PASS: imagem no Ghostty, cores do texto preservadas, popups e outros terminais com fundo opaco")
