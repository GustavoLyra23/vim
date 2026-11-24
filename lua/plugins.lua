return {
  {
    "tinted-theming/tinted-nvim",
    lazy = false,
    priority = 1000,
    opts = { apply_scheme_on_startup = false },
  },
  {
    "nvim-mini/mini.nvim",
    config = function()
      vim.cmd.colorscheme("tomorrow-zed")
      require("mini.icons").setup({ style = "ascii" })
      require("mini.icons").mock_nvim_web_devicons()
      require("mini.statusline").setup({ use_icons = false })
      require("bufferbar").setup()
      require("mini.pairs").setup()
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      styles = {
        input = { border = "none" },
        notification = { border = "none" },
        notification_history = {
          border = "none",
          keys = { ["<Esc>"] = "close" },
          wo = { winbar = " Histórico de notificações | Esc/q: fechar " },
        },
        help = { border = "none" },
      },
      input = { enabled = true, prompt_pos = "left" },
      notifier = { enabled = true, style = "minimal" },
      picker = {
        enabled = true,
        layout = {
          config = function(layout)
            local function remove_borders(box)
              box.border = "none"
              for _, child in ipairs(box) do remove_borders(child) end
            end
            remove_borders(layout.layout)
          end,
        },
      },
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
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signcolumn = true,
      numhl = false,
      current_line_blame = true,
      current_line_blame_opts = { delay = 500, virt_text_pos = "eol" },
      current_line_blame_formatter = " <author> | <author_time:%d/%m/%Y> | <summary>",
      current_line_blame_formatter_nc = " Alteração local (sem commit)",
    },
  },
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
