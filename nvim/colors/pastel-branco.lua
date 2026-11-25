vim.o.background = "light"
require("mini.base16").setup({ palette = {
  base00 = "#fdfcf9", base01 = "#fdfcf9", base02 = "#e9e5f1", base03 = "#4b7d4b",
  base04 = "#72736c", base05 = "#292d32", base06 = "#1f252b", base07 = "#15191d",
  base08 = "#a45a64", base09 = "#6651ae", base0A = "#8b6747", base0B = "#57783b",
  base0C = "#417c84", base0D = "#292d32", base0E = "#a34f9e", base0F = "#8b6747",
} })
vim.g.colors_name = "pastel-branco"
for group, color in pairs({
  Identifier = "#292d32", Delimiter = "#292d32",
  Type = "#a34f9e", Typedef = "#a34f9e", Constant = "#a34f9e", Boolean = "#a34f9e",
  Statement = "#a34f9e", Repeat = "#a34f9e", Exception = "#a34f9e", StorageClass = "#a34f9e",
  Macro = "#8b6747", Define = "#8b6747", Include = "#8b6747",
  ["@keyword.return"] = "#a34f9e",
  ["@variable"] = "#292d32", ["@variable.member"] = "#292d32",
  ["@type"] = "#a34f9e", ["@type.builtin"] = "#a34f9e",
  ["@constant"] = "#a34f9e", ["@constant.builtin"] = "#a34f9e",
  ["@function.macro"] = "#8b6747",
}) do
  vim.api.nvim_set_hl(0, group, { fg = color })
end
vim.api.nvim_set_hl(0, "LineNr", { fg = "#999990", bg = "#fdfcf9" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#999990", bg = "#fdfcf9" })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#292d32", bg = "#f5f3ee" })
