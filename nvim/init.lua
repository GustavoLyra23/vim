vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.keymodel = "startsel,stopsel"
vim.opt.selectmode = "key"
vim.opt.selection = "exclusive"
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 5
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.undofile = true
vim.opt.confirm = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.diffopt:append({ "algorithm:histogram", "linematch:60" })
vim.opt.shell = "zsh"

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = false,
  float = { border = "rounded", source = true },
  signs = { text = { [1] = "E", [2] = "W", [3] = "I", [4] = "H" } },
})

vim.filetype.add({
  extension = { odin = "odin", gdshader = "gdshader", tfvars = "terraform-vars", txt = "markdown" },
  pattern = { ["%.env.*"] = "sh", [".*%.env"] = "sh", [".*%.gradle%.kts"] = "kotlin" },
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath .. "/lua/lazy/init.lua") then
  local output = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_err_writeln("Falha ao instalar lazy.nvim: " .. output)
    return
  end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup(require("plugins"), {
  change_detection = { notify = false },
  checker = { enabled = false },
})
require("keymaps")
