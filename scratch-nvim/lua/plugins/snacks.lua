return {
  {
    "folke/snacks.nvim",
    dependencies = {
      "echasnovski/mini.icons",
    },
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
                                                                       
         ████ ██████           █████      ██                     
        ███████████             █████                             
        █████████ ███████████████████ ███   ███████████   
       █████████  ███    █████████████ █████ ██████████████   
      █████████ ██████████ █████████ █████ █████ ████ █████   
    ███████████ ███    ███ █████████ █████ █████ ████ █████  
   ██████  █████████████████████ ████ █████ █████ ████ ██████ 
          ]],
        },
      },
      indent = { enabled = true },
      input = { enabled = true },
      git = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },
}
