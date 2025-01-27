local path = vim.fn.stdpath("config") .. "/lua/languages"
for _, file in ipairs(vim.fn.readdir(path, [[v:val =~ '\\.lua$']])) do
	if file ~= "init.lua" then
		require("languages." .. file:gsub("%.lua$", ""))
	end
end
