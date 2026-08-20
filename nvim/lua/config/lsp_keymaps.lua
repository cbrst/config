local M = {}

-- ┌────────────────────────────┐
-- │ Buffer-local LSP behavior  │
-- └────────────────────────────┘
function M.setup()
	local attach_group = vim.api.nvim_create_augroup("ConfigLspAttach", { clear = true })
	local highlight_group = vim.api.nvim_create_augroup("ConfigLspHighlight", { clear = true })

	vim.api.nvim_create_autocmd("LspAttach", {
		group = attach_group,
		callback = function(event)
			local function map(keys, action, description, mode)
				vim.keymap.set(mode or "n", keys, action, { buffer = event.buf, desc = "LSP: " .. description })
			end

			-- Telescope keeps code-navigation results searchable and previewable.
			local telescope = require("telescope.builtin")
			map("gd", telescope.lsp_definitions, "[G]oto [D]efinition")
			map("gr", telescope.lsp_references, "[G]oto [R]eferences")
			map("gI", telescope.lsp_implementations, "[G]oto [I]mplementation")
			map("<leader>D", telescope.lsp_type_definitions, "Type [D]efinition")
			map("<leader>ds", telescope.lsp_document_symbols, "[D]ocument [S]ymbols")
			map("<leader>ws", telescope.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
			map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
			map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
			map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					group = highlight_group,
					callback = vim.lsp.buf.document_highlight,
				})
				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					group = highlight_group,
					callback = vim.lsp.buf.clear_references,
				})
			end

			if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
				map("<leader>th", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
				end, "[T]oggle Inlay [H]ints")
			end
		end,
	})

	vim.api.nvim_create_autocmd("LspDetach", {
		group = attach_group,
		callback = function(event)
			-- Remove only the detached buffer's highlights without disturbing other clients.
			vim.lsp.buf.clear_references()
			vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = event.buf })
		end,
	})
end

return M
