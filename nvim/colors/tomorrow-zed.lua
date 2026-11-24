-- Paleta da extensão biaqat/tomorrow-theme-zed, Tomorrow Night 1.2.1.
vim.o.background = "dark"
require("mini.base16").setup({ palette = {
  base00 = "#1e1f21", base01 = "#1e1f21", base02 = "#373b41", base03 = "#969896",
  base04 = "#b4b7b4", base05 = "#c5c8c6", base06 = "#f2f2f2", base07 = "#ffffff",
  base08 = "#cc6666", base09 = "#de935f", base0A = "#f0c674", base0B = "#b5bd68",
  base0C = "#8abeb7", base0D = "#81a2be", base0E = "#b294bb", base0F = "#de935f",
} })
vim.g.colors_name = "tomorrow-zed"
for group, color in pairs({
  Identifier = "#c5c8c6", Operator = "#c5c8c6", Delimiter = "#c5c8c6",
  Type = "#de935f", Typedef = "#de935f", Structure = "#de935f",
  Statement = "#b294bb", Repeat = "#b294bb", Exception = "#b294bb", StorageClass = "#b294bb",
  Function = "#85b7b1", Tag = "#92b2ca",
  ["@keyword.return"] = "#b294bb",
  ["@variable"] = "#c5c8c6", ["@variable.member"] = "#c5c8c6",
  ["@type"] = "#de935f", ["@type.builtin"] = "#de935f",
  ["@function"] = "#85b7b1", ["@function.method"] = "#85b7b1",
  ["@tag"] = "#92b2ca",
}) do
  vim.api.nvim_set_hl(0, group, { fg = color })
end
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#c5c8c6", bg = "#17181a" })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#63666e", bg = "#1e1f21" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bg = "#1e1f21" })

-- Deixa a imagem do Ghostty aparecer atrás do editor, mantendo os popups opacos.
if vim.env.TERM_PROGRAM == "ghostty" then
  for _, group in ipairs({ "Normal", "NormalNC", "LineNr", "CursorLineNr", "SignColumn", "FoldColumn", "CursorLine", "EndOfBuffer" }) do
    local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
    highlight.bg = nil
    vim.api.nvim_set_hl(0, group, highlight)
  end
end
