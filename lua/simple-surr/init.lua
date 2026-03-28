local M = {}
local surround = require("simple-surr.surround")

local function prompt_for_style(msg)
    msg = msg or "Enter surround style (e.g., [, {, (, }, ', \", `, custom): "
    return vim.fn.input(msg)
end

local default_keymaps = {
    surround_selection = "<leader>s",
    surround_word = "<leader>sw",
    remove_or_change_surround_word = "<leader>sr",
    toggle_or_change_surround_selection = "<leader>ts",
    surround_motion = "gs",
    surround_line = "gss",
    surround_treesitter = "gst",
    surround_function = "gsf",
    surround_multi = "gsm",
    surround_prefix_suffix = "gsp",
    unwrap = "sd",
    surround_block = "gsb",
}

local operator_state = {
    style = nil,
}

local function set_repeat()
    if vim.fn.exists("*repeat#set") == 1 then
        vim.fn["repeat#set"]("\\<Plug>(simple-surr-repeat)")
    end
end

function M.operatorfunc(type)
    if not operator_state.style then
        return
    end

    surround.operator_surround(operator_state.style, type)
    operator_state.style = nil
    set_repeat()
end

function M.setup(opts)
    opts = opts or {}

    vim.opt.rtp:append(vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h:h:h"))

    local keymaps = vim.tbl_extend("force", default_keymaps, opts.keymaps or {})
    local surround_opts = {}
    if opts.space then
        surround_opts.space = opts.space
    end
    if opts.treesitter_nodes then
        surround_opts.treesitter_nodes = opts.treesitter_nodes
    end
    if opts.treesitter_function_nodes then
        surround_opts.treesitter_function_nodes = opts.treesitter_function_nodes
    end
    surround.set_options(surround_opts)

    if opts.overwrite_default_pairs then
        surround.surround_pairs = {}
    end

    if opts.custom_surround_pairs then
        for opening, closing in pairs(opts.custom_surround_pairs) do
            if type(closing) == "table" then
                surround.add_surround_pair(closing[1], closing[2])
            elseif type(closing) == "string" then
                surround.add_surround_pair(opening, closing)
            end
        end
    end

    vim.keymap.set("v", keymaps.surround_selection, function()
        local style = prompt_for_style()
        if style ~= nil and style ~= "" then
            surround.surround_selection(style)
            set_repeat()
        end
    end, { desc = "Surround selection with custom or predefined style" })

    vim.keymap.set("n", keymaps.surround_word, function()
        local style = prompt_for_style()
        if style ~= nil and style ~= "" then
            surround.surround_word(style)
            set_repeat()
        end
    end, { desc = "Surround word under cursor with custom or predefined style" })

    vim.keymap.set("n", keymaps.remove_or_change_surround_word, function()
        local change = vim.fn.input("Change surround style (leave empty to remove): ")
        if change == "" then
            surround.remove_or_change_surround_word()
        else
            surround.remove_or_change_surround_word(change)
        end
        set_repeat()
    end, { desc = "Remove or change surround style of word" })

    vim.keymap.set("v", keymaps.toggle_or_change_surround_selection, function()
        local style = vim.fn.input("Enter surround style (e.g., [, {, (, }, ', \", `, custom, or leave blank to remove): ")
        surround.toggle_or_change_surround_selection(style)
        set_repeat()
    end, { desc = "Toggle or change surround selection with custom or predefined style" })

    vim.keymap.set("n", keymaps.surround_motion, function()
        local style = prompt_for_style()
        if not style or style == "" then
            return ""
        end
        operator_state.style = style
        vim.go.operatorfunc = "v:lua.require'simple-surr'.operatorfunc"
        return "g@"
    end, { expr = true, desc = "Surround with operator-pending motion" })

    vim.keymap.set("n", keymaps.surround_line, function()
        local style = prompt_for_style()
        if style ~= nil and style ~= "" then
            surround.surround_line(style)
            set_repeat()
        end
    end, { desc = "Surround current line" })

    vim.keymap.set("n", keymaps.surround_treesitter, function()
        local style = prompt_for_style()
        if style ~= nil and style ~= "" then
            surround.surround_treesitter_node(style)
            set_repeat()
        end
    end, { desc = "Surround tree-sitter node" })

    vim.keymap.set("n", keymaps.surround_function, function()
        local style = prompt_for_style()
        if style ~= nil and style ~= "" then
            surround.surround_treesitter_function(style)
            set_repeat()
        end
    end, { desc = "Surround tree-sitter function node" })

    vim.keymap.set("n", "<Plug>(simple-surr-repeat)", function()
        surround.repeat_last()
    end, { desc = "Repeat last simple-surr action" })

    vim.keymap.set("v", keymaps.surround_multi, function()
        local style = prompt_for_style()
        if not style or style == "" then
            return
        end
        local separator = vim.fn.input("Enter separator (default: ,): ")
        if separator == "" then
            separator = ","
        end
        surround.surround_multi(style, separator)
        set_repeat()
    end, { desc = "Surround multiple elements with separator" })

    vim.keymap.set("n", keymaps.surround_prefix_suffix, function()
        local prefix = vim.fn.input("Enter prefix: ")
        if not prefix or prefix == "" then
            return
        end
        local suffix = vim.fn.input("Enter suffix: ")
        if not suffix or suffix == "" then
            return
        end
        surround.surround_prefix_suffix(prefix, suffix)
        set_repeat()
    end, { desc = "Surround with prefix and suffix" })

    vim.keymap.set("n", keymaps.unwrap, function()
        local style = vim.fn.input("Enter unwrap style to remove (leave empty for auto-detect): ")
        surround.unwrap(style)
        set_repeat()
    end, { desc = "Unwrap/remove surround characters from word" })

    vim.keymap.set("v", keymaps.unwrap, function()
        local style = vim.fn.input("Enter unwrap style to remove (leave empty for auto-detect): ")
        surround.unwrap_selection(style)
        set_repeat()
    end, { desc = "Unwrap/remove surround from selection" })

    vim.keymap.set("x", keymaps.surround_block, function()
        local style = prompt_for_style()
        if style ~= nil and style ~= "" then
            surround.surround_block(style)
            set_repeat()
        end
    end, { desc = "Surround visual block (column selection)" })
end

return M
