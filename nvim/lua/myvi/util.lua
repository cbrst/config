local M = {}

-- Function to get visually selected text
M.get_visual_selection = function()
	local s_start = vim.fn.getpos("'<")
	local s_end = vim.fn.getpos("'>")
	local n_lines = math.abs(s_end[2] - s_start[2]) + 1
	local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)

	if #lines == 0 then
		return ""
	end

	-- Modify first and last line if there are multiple lines
	if n_lines > 1 then
		local s_col = s_start[3]
		local e_col = s_end[3]
		lines[1] = string.sub(lines[1], s_col)
		lines[n_lines] = string.sub(lines[n_lines], 1, e_col)
		return table.concat(lines, "\n")
	end

	-- Handle single line selection
	local s_col = s_start[3]
	local e_col = s_end[3]
	return string.sub(lines[1], s_col, e_col)
end

-- Prompt the user for an argument and run a command with it
M.prompt_command = function(command, prompt)
	-- Get selected text
	local selected_text = M.get_visual_selection()

	-- Prompt for input
	local input = vim.fn.input(prompt .. ": ", selected_text)

	-- Exit if cancelled
	if input == "" then
		print("\nCommand cancelled")
		return
	end

	-- Build command table
	local cmd = {
		cmd = command,
		args = { input },
	}

	-- Execute the command
	vim.api.nvim_cmd(cmd, {})
end

return M
