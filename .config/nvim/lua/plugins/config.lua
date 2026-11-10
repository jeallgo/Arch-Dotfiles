return {
  -- Tema y Estética
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-lualine/lualine.nvim" },
  { "akinsho/bufferline.nvim", version = "*" },
  { "goolord/alpha-nvim" },

  -- Utilidades y Navegación
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim", tag = "0.1.8" },
  { "Rolv-Apneseth/tfm.nvim" },
  { "folke/which-key.nvim" },

  -- Edición y LSP / Autocompletado
  { "neovim/nvim-lspconfig" },
  { "stevearc/conform.nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python", "php", "lua", "nix", "html", "css", "json", "markdown", "markdown_inline" },
        highlight = { enable = true },
      })
    end,
  },

  -- Obsidian / Notas
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
  },

  -- Autocompletado (CMP y fuentes)
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
}
