-- Add node_modules to the search path
vim.opt_local.path:append("node_modules/**")

-- Tell Neovim to try these extensions if it can't find the file
vim.opt_local.suffixesadd = { ".js", ".jsx", ".ts", ".tsx", ".d.ts", ".json" }
