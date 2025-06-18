vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, nowait)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc, nowait = nowait or false })
    end

    ---- TODO: search if there is an way to move this to keymap.lua (and if it's a good practice)
    map("K", vim.lsp.buf.hover, "Hover Documentation")
    map("gl", vim.diagnostic.open_float, "Open Diagnostic Float")
    map("gs", vim.lsp.buf.signature_help, "Signature Documentation")
    map("gd", function() Snacks.picker.lsp_definitions() end, "Goto Definition")
    -- map("gD", vim.lsp.buf.declaration, "Goto Declaration")
    map("gD", function() Snacks.picker.lsp_declarations() end, "Goto Declaration")
    map("gv", "<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", "Goto Definition in Vertical Split")
    map("gr", function() Snacks.picker.lsp_references() end, "References", true)
    map("gI", function() Snacks.picker.lsp_implementations() end, "Goto Implementation")
    map("gy", function() Snacks.picker.lsp_type_definitions() end, "Goto T[y]pe Definition")
    map("<leader>l", "", "Language server protocol options")
    map("<leader>ls", function() Snacks.picker.lsp_symbols() end, "LSP Symbols")
    map("<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, "LSP Workspace Symbols")
    map("<leader>la", vim.lsp.buf.code_action, "Code Action")
    map("<leader>lr", vim.lsp.buf.rename, "Rename all references")
    map("<leader>lf", vim.lsp.buf.format, "Format")

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentFormattingProvider then
      local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      -- When LSP detaches: Clears the highlighting
      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
        end,
      })
    end

    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hit then
      map("<leader>th", function ()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, "[T]oggle Inlay [H]ints")
    end
  end,
})

vim.lsp.config("*", {
  capabilities = require("blink-cmp").get_lsp_capabilities()
})
