return {
  -- settings = {
  --   python = {
  --     analysis = {
  --       typeCheckingMode = "basic",
  --       diagnosticMode = "workspace",
  --       inlayHints = {
  --         variableTypes = true,
  --         functionReturnTypes = true,
  --       },
  --     },
  --   },
  -- },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        disableOrganizeImports = true,
        diagnosticSeverityOverrides = {
          reportGeneralTypeIssues = "information",
        }
      }
    },
  },
  capabilities = {
    document_formatting = false
  }
}
