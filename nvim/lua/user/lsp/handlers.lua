local M = {}

M.capabilities = vim.lsp.protocol.make_client_capabilities()

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
  return
end
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)

M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    -- disable virtual text
    virtual_lines = false,
    virtual_text = false,

    -- show signs
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "if_many", -- Or "always"
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end


local function attach_navic(client, bufnr)
  vim.g.navic_silence = true
  local status_ok, navic = pcall(require, "nvim-navic")
  if not status_ok then
    return
  end
  navic.attach(client, bufnr)
end

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap
  keymap(bufnr, "n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
  keymap(bufnr, "n", "gD", "<cmd>Telescope lsp_declarations<CR>", opts)
  keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  keymap(bufnr, "n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
  keymap(bufnr, "n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
  keymap(bufnr, "n", "<C-k>", ":lua vim.lsp.buf.signature_help()<CR>", opts)
  keymap(bufnr, "n", "ll", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  keymap(bufnr, "n", "lf", "<cmd>Format<cr>", opts)
  keymap(bufnr, "n", "la", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
  -- keymap(bufnr, "n", "<leader>rr", ":lua vim.lsp.buf.rename()<CR>", opts)
  -- keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  -- keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  -- keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
  -- keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
  -- keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.format({ async = true })' ]]
end

M.on_attach = function(client, bufnr)
  lsp_keymaps(bufnr)
  attach_navic(client, bufnr)

  if client.name == "tsserver" then
    require("lsp-inlayhints").on_attach(client, bufnr)
  end

  if client.server_capabilities.documentRangeFormattingProvider then
    local map = function(mode, key, expr, opts)
      opts = vim.tbl_extend("keep", { noremap = true, silent = true, buffer = bufnr }, opts)
      return vim.keymap.set(mode, key, expr, opts)
    end
    vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr(#{timeout_ms:250})")
    map("x", "lf", function()
        vim.lsp.buf.format({ bufnr = bufnr, async = false })
    end, { desc = "LSP range format" })
    vim.api.nvim_buf_create_user_command(bufnr, "LspRangeFormat", function(args)
        vim.lsp.buf.format({
            bufnr = bufnr,
            async = false,
            range = { start = { args.line1, 0 }, ["end"] = { args.line2, 0 } },
        })
    end, { range = true, desc = "LSP range format" })
  end

end

function M.enable_format_on_save()
  vim.cmd [[
    augroup format_on_save
      autocmd! 
      autocmd BufWritePre * lua vim.lsp.buf.format({ async = false }) 
    augroup end
  ]]
  vim.notify "Enabled format on save"
end

function M.disable_format_on_save()
  M.remove_augroup "format_on_save"
  vim.notify "Disabled format on save"
end

function M.toggle_format_on_save()
  if vim.fn.exists "#format_on_save#BufWritePre" == 0 then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

function M.remove_augroup(name)
  if vim.fn.exists("#" .. name) == 1 then
    vim.cmd("au! " .. name)
  end
end

vim.cmd [[ command! LspToggleAutoFormat execute 'lua require("user.lsp.handlers").toggle_format_on_save()' ]]

return M
