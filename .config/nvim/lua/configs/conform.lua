return {
  formatters_by_ft = {
    python = { "black" },
    php = { "php_cs_fixer" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}
