local M = {}

local default_keymaps = {
	surround_selection = "<leader>s",
	surround_word = "<leader>sw",
	remove_or_change_surround_word = "<leader>sr",
	toggle_or_change_surround_selection = "<leader>ts",
}

function M.setup(opts)
	opts = opts or {}
	local keymaps = vim.tbl_extend("force", default_keymaps, opts.keymaps or {})

	-- you can append your custom pairs :)
	if opts.custom_surround_pairs then
		for opening, closing in pairs(opts.custom_surround_pairs) do
			require("simple-surr.surround").add_surround_pair(opening, closing)
		end
	end

	-- you can overwrite default pairs
	if opts.overwrite_default_pairs then
		M.surround_pairs = opts.custom_surround_pairs or {}
	end

	vim.keymap.set("v", keymaps.surround_selection, function()
		local style = vim.fn.input("Enter surround style (e.g., [, {, (, }, ', \", `, custom): ")
		-- Checking if style is empty
		if style ~= nil and style ~= "" then
			require("simple-surr.surround").surround_selection(style)
		end
	end, { desc = "Surround selection with custom or predefined style" })

	vim.keymap.set("n", keymaps.surround_word, function()
		local style = vim.fn.input("Enter surround style (e.g., [, {, (, }, ', \", `, custom): ")
		-- Checking if style is empty
		if style ~= nil and style ~= "" then
			require("simple-surr.surround").surround_word(style)
		end
	end, { desc = "Surround word under cursor with custom or predefined style" })

	vim.keymap.set("n", "<leader>sr", function()
		local change = vim.fn.input("Change surround style (leave empty to remove): ")
		if change == "" then
			require("simple-surr.surround").remove_or_change_surround_word()
		else
			require("simple-surr.surround").remove_or_change_surround_word(change)
		end
	end, { desc = "Remove or change surround style of word" })

	vim.keymap.set("v", "<leader>ts", function()
		local style =
			vim.fn.input("Enter surround style (e.g., [, {, (, }, ', \", `, custom, or leave blank to remove): ")
		require("simple-surr.surround").toggle_or_change_surround_selection(style)
	end, { desc = "Toggle or change surround selection with custom or predefined style" })
end

return M
