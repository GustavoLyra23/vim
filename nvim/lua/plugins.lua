return {
  {
    "nvim-mini/mini.nvim",
    config = function()
      -- Adwaita Dark do Ghostty, com o fundo personalizado do terminal.
      require("mini.base16").setup({ palette = {
        base00 = "#1c1c1f", base01 = "#1d1d20", base02 = "#241f31", base03 = "#c0bfbc",
        base04 = "#c0bfbc", base05 = "#ffffff", base06 = "#f6f5f4", base07 = "#ffffff",
        base08 = "#ed333b", base09 = "#f5c211", base0A = "#f8e45c", base0B = "#57e389",
        base0C = "#4fd2fd", base0D = "#51a1ff", base0E = "#c061cb", base0F = "#c061cb",
      } })
      vim.api.nvim_set_hl(0, "Visual", { fg = "#5e5c64", bg = "#ffffff" })
      for index, color in ipairs({
        "#241f31", "#c01c28", "#2ec27e", "#f5c211", "#1e78e4", "#9841bb", "#0ab9dc", "#c0bfbc",
        "#5e5c64", "#ed333b", "#57e389", "#f8e45c", "#51a1ff", "#c061cb", "#4fd2fd", "#f6f5f4",
      }) do
        vim.g["terminal_color_" .. (index - 1)] = color
      end
      require("mini.icons").setup({ style = "ascii" })
      require("mini.icons").mock_nvim_web_devicons()
      require("mini.statusline").setup({ use_icons = false })
      require("mini.tabline").setup({ show_icons = false })
      require("mini.pairs").setup()
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      input = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true },
      explorer = { enabled = true },
      terminal = { win = { position = "bottom", height = 0.4 } },
      dashboard = {
        enabled = true,
        preset = {
          header = "NEOVIM\n\ni: editar   Esc: navegar   Espaco: atalhos   Ctrl+S: salvar",
          keys = {
            { key = "f", desc = "Abrir arquivo", action = ":lua Snacks.picker.files()" },
            { key = "n", desc = "Novo arquivo", action = ":ene | startinsert" },
            { key = "s", desc = "Buscar no projeto", action = ":lua Snacks.picker.grep()" },
            { key = "r", desc = "Arquivos recentes", action = ":lua Snacks.picker.recent()" },
            { key = "g", desc = "Git e commits", action = ":Neogit" },
            { key = "a", desc = "Conversas do Codex", action = ":lua require('keymaps').codex(true)" },
            { key = "p", desc = "Pull requests", action = ":Octo pr list" },
            { key = "h", desc = "Guia de uso", action = ":NeovimGuia" },
            { key = "q", desc = "Sair", action = ":qa" },
          },
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 250,
      icons = { mappings = false },
      spec = {
        { "<leader>f", group = "Arquivos e busca" },
        { "<leader>c", group = "Codigo" },
        { "<leader>g", group = "Git e diff" },
        { "<leader>a", group = "IA / Codex" },
        { "<leader>o", group = "GitHub" },
        { "<leader>b", group = "Abas" },
      },
    },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      fuzzy = { implementation = "lua" },
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Esc>"] = { "hide", "fallback" },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
        documentation = { auto_show = true },
        menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind" } } } },
      },
      signature = { enabled = true },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp", "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
    config = function() require("languages") end,
  },
  { "lewis6991/gitsigns.nvim", opts = { signcolumn = true, numhl = false } },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      enhanced_diff_hl = true,
      use_icons = false,
      view = { merge_tool = { layout = "diff3_mixed", disable_diagnostics = true } },
    },
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "sindrets/diffview.nvim", "folke/snacks.nvim" },
    opts = {
      integrations = { diffview = true, snacks = true },
      graph_style = "ascii",
      -- Ctrl+S no painel atualiza a tela sem colocar todos os arquivos no stage.
      mappings = { status = { ["<c-s>"] = "RefreshBuffer" } },
    },
  },
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    opts = { picker = "snacks", enable_builtin = true, file_panel = { icons = false } },
  },
}
