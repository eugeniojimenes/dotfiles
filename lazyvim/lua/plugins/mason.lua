return {
  -- NOTE: pin mason related pcakges to ^1.x while the various LazyVim internal
  -- features are updated to support 2.x
  -- https://github.com/LazyVim/LazyVim/issues/6039
  -- https://github.com/LazyVim/LazyVim/pull/6053
  { "williamboman/mason.nvim", version = "^1.0.0" },
  { "williamboman/mason-lspconfig.nvim", version = "^1.0.0" },
}
