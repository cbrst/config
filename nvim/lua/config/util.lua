local M = {}

-- ┌──────────────────────────────┐
-- │ Visual-command input helpers │
-- └──────────────────────────────┘
function M.get_visual_selection()
	local start = vim.fn.getpos("'<")
	local finish = vim.fn.getpos("'>")
	local line_count = math.abs(finish[2] - start[2]) + 1
	local lines = vim.api.nvim_buf_get_lines(0, start[2] - 1, finish[2], false)

	if #lines == 0 then
		return ""
	end

	local start_column = start[3]
	local end_column = finish[3]
	if line_count == 1 then
		return string.sub(lines[1], start_column, end_column)
	end

	-- Trim only the selected boundaries while preserving whole intervening lines.
	lines[1] = string.sub(lines[1], start_column)
	lines[line_count] = string.sub(lines[line_count], 1, end_column)
	return table.concat(lines, "\n")
end

function M.prompt_command(command, prompt)
	local input = vim.fn.input(prompt .. ": ", M.get_visual_selection())
	if input == "" then
		vim.notify("Command cancelled")
		return
	end

	-- Use the structured API so user input remains a command argument, not Ex code.
	vim.api.nvim_cmd({ cmd = command, args = { input } }, {})
end

return M
