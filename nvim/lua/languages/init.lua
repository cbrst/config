local M = {}

-- ┌─────────────────────────────┐
-- │ Explicit filetype setup     │
-- └─────────────────────────────┘
function M.setup()
	-- Keep this list explicit so enabled filetype behavior is discoverable and stable.
	require("languages.lua").setup()
	require("languages.markdown").setup()
end

return M
