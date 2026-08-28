vim.cmd([[colorscheme catppuccin]])

vim.lsp.enable({ "qmlls" })
vim.lsp.config( "qmlls", {
	cmd = { "qmlls", "-E" },
	filetypes = { "qml" }
})
