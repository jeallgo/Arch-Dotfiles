-- =====================================================================
-- 1. BLOQUEAR FLECHAS Y MOSTRAR COMANDOS INCOMPLETOS
-- =====================================================================
local keys = { "<Up>", "<Down>", "<Left>", "<Right>" }
for _, key in ipairs(keys) do
  vim.keymap.set({ "n", "i", "v" }, key, "<Nop>", { noremap = true, silent = true })
end

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showcmd = true
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>c", ":bd<CR>", { silent = true })
vim.keymap.set("n", "<leader>t", ":botright 10split | terminal<CR>a", {silent = true })

-- funcion para ejecutar en f5 como si fuera vscode pero usando tmux y PHP
vim.keymap.set("n", "<F5>", function()
  vim.cmd("w")
  local current_file = vim.fn.shellescape(vim.fn.expand("%"))
  
  vim.fn.system("tmux send-keys -t {bottom} Clear C-m 'php " .. current_file .. "' C-m")
end, { desc = "Ejecutar PHP en panel de abajo de Tmux", silent = true })


local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
  wk.setup({})
end

-- =====================================================================
-- BOOTSTRAP DE LAZY.NVIM
-- =====================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Carga tus opciones generales, mapeos y keymaps antiguos (mantén tu bloque 1 intacto)
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showcmd = true

-- =====================================================================
-- CARGA DE PLUGINS CON LAZY
-- =====================================================================
require("lazy").setup("plugins.config")

-- =====================================================================
-- 2. CONFIGURACIÓN DE TEMA (CATPPUCCIN CON TRANSPARENCIA)
-- =====================================================================
local catppuccin_ok, catppuccin = pcall(require, "catppuccin")
if catppuccin_ok then
  catppuccin.setup({
    transparent_background = true,
    integrations = {
      bufferline = true,
      cmp = true,
      lualine = true,
      treesitter = true,
      which_key = true,
    },
  })
end

vim.cmd.colorscheme("catppuccin")

local function make_transparent()
  local groups = {
    "Normal", "NormalNC", "NormalFloat", "FloatBorder",
    "SignColumn", "StatusLine", "StatusLineNC",
    "BufferLineFill", "BufferLineBackground", "BufferLineBufferUnselected",
    "BufferLineBufferSelected", "BufferLineTab", "BufferLineTabSelected",
    "BufferLineSeparator", "BufferLineSeparatorSelected", "BufferLineIndicatorSelected"
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end

make_transparent()
vim.api.nvim_create_autocmd("ColorScheme", { callback = make_transparent })

-- =====================================================================
-- 3. INTEGRACIÓN DE YAZI (TFM.NVIM)
-- =====================================================================
local tfm_ok, tfm = pcall(require, "tfm")
if tfm_ok then
  tfm.setup({
    file_manager = "yazi",
    replace_netrw = true,
    enable_cmd = true,
    ui = {
      border = "rounded",
      height = 0.85,
      width = 0.85,
      x = 0.5,
      y = 0.5,
    },
  })
    vim.keymap.set("n", "<C-n>", function()
    tfm.open()
  end, { desc = "Abrir Yazi (TFM)", silent = true })
end

-- =====================================================================
-- 4. BARRA DE ESTADO INFERIOR (LUALINE) TRANSPARENTE
-- =====================================================================
local lualine_ok, lualine = pcall(require, "lualine")
if lualine_ok then
  local transparent_theme = require("lualine.themes.auto")

  -- Volvemos transparentes todas las secciones excepto la 'a' (que contiene el modo NORMAL, COMMAND, etc.)
  for mode, sections in pairs(transparent_theme) do
    if type(sections) == "table" then
      for section_name, section_style in pairs(sections) do
        if section_name ~= "a" and type(section_style) == "table" then
          section_style.bg = "NONE"
        end
      end
    end
  end

  lualine.setup({
    options = {
      theme = transparent_theme,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      globalstatus = true,
    },
  })
end

-- =====================================================================
-- 5. BARRA DE PESTAÑAS SUPERIOR (BUFFERLINE) TRANSPARENTE
-- =====================================================================
local bufferline_ok, bufferline = pcall(require, "bufferline")
if bufferline_ok then
  bufferline.setup({
    options = {
      mode = "buffers",
      numbers = "ordinal",
      separator_style = "thin",
    },
    highlights = {
      fill = { bg = "NONE" },
      background = { bg = "NONE" },
      tab = { bg = "NONE" },
      tab_selected = { bg = "NONE" },
      tab_close = { bg = "NONE" },
      buffer_visible = { bg = "NONE" },
      buffer_selected = { bg = "NONE", bold = true, italic = false },
      separator = { bg = "NONE" },
      separator_selected = { bg = "NONE" },
      separator_visible = { bg = "NONE" },
      close_button = { bg = "NONE" },
      close_button_visible = { bg = "NONE" },
      close_button_selected = { bg = "NONE" },
      modified = { bg = "NONE" },
      modified_visible = { bg = "NONE" },
      modified_selected = { bg = "NONE" },
      indicator_selected = { bg = "NONE" },
    },
  })

  vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true })
  vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true })
  vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { silent = true })
end

-- =====================================================================
-- 6. CONFIGURACIÓN DE AUTOCOMPLETADO "CMP"
-- =====================================================================

local cmp_ok, cmp = pcall(require, "cmp")
if cmp_ok then
  cmp.setup({
    mapping = cmp.mapping.preset.insert({
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping.select_next_item(),
      ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'buffer' },
      { name = 'path' },
    })
  })
end
-- =====================================================================
-- 7. CONFIGURACIÓN DE OBSIDIAN.NVIM
-- =====================================================================
local obsidian_ok, obsidian = pcall(require, "obsidian")
if obsidian_ok then
  obsidian.setup({
    legacy_commands = false,
    workspaces = {
      {
        name = "personal",
        path = vim.fn.expand("~/Vault"),
      },
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. "-" .. suffix
    end,
  })
end

-- =====================================================================
-- 8. CONFORM, LSP Y ALPHA DASHBOARD
-- =====================================================================
local conform_ok, conform = pcall(require, "conform")
if conform_ok then
  conform.setup(require("configs.conform"))
end

pcall(require, "configs.lspconfig")

local alpha_ok, alpha = pcall(require, "alpha")
if alpha_ok then
  local dashboard = require("alpha.themes.dashboard")
  local ok, matugen = pcall(require, "custom.matugen_colors")
  local accent      = ok and matugen.colors.base07 or "#AECBE6"
  local text_col    = ok and matugen.colors.base07 or "#f38ba8"
  local belle_color = ok and matugen.colors.base07 or "#f38ba8"

  local function set_alpha_highlights()
    vim.api.nvim_set_hl(0, "AlphaBelle",  { fg = belle_color, bold = true })
    vim.api.nvim_set_hl(0, "AlphaAccent", { fg = accent,     bold = true })
    vim.api.nvim_set_hl(0, "AlphaText",   { fg = text_col })
  end

  set_alpha_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = set_alpha_highlights })

  dashboard.section.header.val = {
    [[⡇⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⢁⣿⣿⡏⠉⠉⠉⠉⠉⠉⠉⠉⠉⢹⣇⠉⠉⢳⣌⢉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⡇]],
    [[⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠇⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣧⠀⠀⢻⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇]],
    [[⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣰⠀⠀⢸⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣷⣄⠀⠹⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇]],
    [[⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⢸⢸⣿⡿⠿⢃⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠻⠿⣿⣦⣀⠙⢿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇]],
    [[⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣈⣛⣋⡄⢨⣨⣶⣶⣶⣷⡶⡀⠀⠀⠀⠀⠀⢀⠀⢿⣷⣶⣶⣶⣶⣷⣤⣭⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇]],
    [[⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡄⣇⣟⠿⣿⣿⣷⣱⡀⠀⠀⠀⠀⢸⡄⢸⣿⠿⢛⠛⠛⠻⢿⡟⣽⠆⡀⠀⠀⠀⠀⠀⠀⠀⡇]],
    [[⡇⠀⠀⠀⠀⠀⠀⠀⠂⠀⠀⠓⠀⠐⠒⠈⠻⣷⣌⠟⣿⣧⣵⡐⡄⠀⠀⠸⡿⠀⠀⠀⢀⡀⠀⠀⠀⠈⠃⢜⡁⠀⠀⠀⠀⠀⠀⠀⡇]],
    [[⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⡐⠀⠀⠠⠤⠀⠀⠈⠻⣦⣽⣿⣿⣷⡜⠆⠀⠀⣵⡆⠀⠈⠛⠁⠀⠀⢢⡀⠘⢿⡇⠀⠀⠀⠀⠀⠀⠀⡇]],
    [[⡇⠀⠀⠀⠀⠀⠀⠀⢀⢡⡀⢀⢠⠀⠀⠆⡀⣿⣧⣼⣿⣿⣿⣿⣯⣼⣷⣄⠸⣇⢠⣲⣤⣜⣠⢀⣾⠟⣠⣾⣇⠀⠀⣠⣤⠀⠀⠀⡇]],
    [[⡇⠀⠀⠀⠀⠀⠀⠀⠈⠆⣩⣈⠻⣿⣿⠞⣡⡿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣜⡢⢝⣻⠛⠋⠵⠖⠖⣢⣿⡇⠀⠀⣭⡹⣇⠀⠀⡇]],
    [[⡇⠀⠀⠀⠀⠀⠀⠀⠀⠰⣶⣭⣛⣓⣂⣭⣵⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡖⢶⠒⠿⠷⢿⣿⣿⡇⠀⠈⣿⢡⣿ ⠀⡇]],
    [[⡇ ⠀⠀⠀⠀⠀⠀⠀⠀⠉⣋⠉⣫⣼⣿⣿⣿⣿⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣶⣶⣾⣿⣿⠀⢀⡠⢟⣼⠏ ⠀⡇]],
    [[⡇⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⢀⣼⡰⢛⣁⣀⣀⣀⡇]],
  }
  dashboard.section.header.opts.hl = "AlphaBelle"

  dashboard.section.buttons.val = {
    dashboard.button("f", "󰈞  Find file",           ":Telescope find_files<CR>"),
    dashboard.button("e", "󰝒  New file",            ":ene <BAR> startinsert <CR>"),
    dashboard.button("p", "󰄉  Find project",        ":Telescope projects<CR>"),
    dashboard.button("r", "󰄄  Recently used files", ":Telescope oldfiles<CR>"),
    dashboard.button("t", "󰱽  Find text",            ":Telescope live_grep<CR>"),
    dashboard.button("o", "󰠮  Obsidian New Note",   ":ObsidianNew<CR>"),
    dashboard.button("c", "󰒓  Configuration",        ":e ~/.config/nvim/init.lua<CR>"),
    dashboard.button("q", "󰅚  Quit Neovim",         ":qa<CR>"),
  }

  for _, button in ipairs(dashboard.section.buttons.val) do
    button.opts.hl_shortcut = "AlphaAccent"
    button.opts.hl = {
      { "AlphaAccent", 0, 3 },
      { "AlphaText",   3, 160 },
    }
  end

  dashboard.section.footer.opts.hl = "AlphaAccent"
  alpha.setup(dashboard.opts)
end
