local path = vim.fn.stdpath("config") .. "/lua/languages"

for _, file in ipairs(vim.fn.readdir(path)) do
	-- Filter in Lua so every language module loads independently of Vim regex escaping.
	if file ~= "init.lua" and file:sub(-4) == ".lua" then
		require("languages." .. file:gsub("%.lua$", ""))
	end
end
