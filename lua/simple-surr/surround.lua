local M = {}
local REMOVE_SENTINEL = "remove!"
local treesitter = require("simple-surr.treesitter")
local DEFAULT_OPTS = {
    space = "prompt",
    treesitter_nodes = {
        "arguments",
        "argument_list",
        "arguments_list",
        "parameters",
        "parameter_list",
        "jsx_element",
        "jsx_fragment",
        "table_constructor",
        "table",
    },
    treesitter_function_nodes = {
        "function_definition",
        "function_declaration",
        "function",
        "method_declaration",
    },
}
local opts = vim.tbl_deep_extend("force", {}, DEFAULT_OPTS)
local last_action = nil

M.surround_pairs = {
    ["("] = { "(", ")" },
    [")"] = { "(", ")" },
    ["{"] = { "{", "}" },
    ["}"] = { "{", "}" },
    ["["] = { "[", "]" },
    ["]"] = { "[", "]" },
    ["'"] = { "'", "'" },
    ['"'] = { '"', '"' },
    [">"] = { "<", ">" },
    ["<"] = { "<", ">" },
    ["`"] = { "`", "`" },
    ["|"] = { "|", "|" },
}

function M.set_options(user_opts)
    opts = vim.tbl_deep_extend("force", {}, DEFAULT_OPTS, user_opts or {})
end

function M.set_last_action(name, args)
    last_action = { name = name, args = args }
end

function M.repeat_last()
    if not last_action then
        return
    end

    local action = M[last_action.name]
    if type(action) == "function" then
        action(unpack(last_action.args or {}))
    end
end

function M.add_surround_pair(opening, closing)
    if type(opening) ~= "string" or type(closing) ~= "string" then
        print("Surround characters must be strings.")
        return
    end

    if #opening ~= 1 or #closing ~= 1 then
        print("Surround characters must be single characters.")
        return
    end

    for key, pair in pairs(M.surround_pairs) do
        if (key == opening and pair[2] == closing) or (pair[1] == opening and pair[2] == closing) then
            print("This surround pair already exists: " .. opening .. closing)
            return
        end
    end

    M.surround_pairs[opening] = { opening, closing }
    print("Added surround pair: " .. opening .. closing)
end

local function parse_surround_style(style)
    if type(style) ~= "string" then
        print("Invalid surround style! Use a listed key or one/two custom characters.")
        return nil, nil
    end

    local opening, closing
    if M.surround_pairs[style] then
        opening, closing = M.surround_pairs[style][1], M.surround_pairs[style][2]
    elseif #style == 1 then
        opening, closing = style, style
    elseif #style == 2 then
        opening, closing = style:sub(1, 1), style:sub(2, 2)
    elseif style == "" then
        return REMOVE_SENTINEL, REMOVE_SENTINEL
    else
        print("Invalid surround style! Use a listed key or one/two custom characters.")
        return nil, nil
    end
    return opening, closing
end

local function resolve_space(space)
    if space ~= nil then
        return space
    end

    if opts.space == "always" then
        return true
    end

    if opts.space == "never" then
        return false
    end

    if opts.space == "prompt" then
        local choice = vim.fn.input("Add spaces inside surround? (y/N): ")
        return choice:lower() == "y"
    end

    return false
end

local function normalize_pos(first_pos, second_pos)
    if first_pos[2] > second_pos[2] then
        return second_pos, first_pos
    end

    if first_pos[2] == second_pos[2] and first_pos[3] > second_pos[3] then
        return second_pos, first_pos
    end

    return first_pos, second_pos
end

local function is_word_char(char)
    return char ~= "" and char:match("[%w_]") ~= nil
end

local function get_node_at_cursor()
    return treesitter.get_node_at_cursor()
end

local function node_range_to_positions(node)
    return treesitter.node_range_to_positions(node)
end

local function find_node_by_type(node, type_list)
    return treesitter.find_node_by_type(node, type_list)
end

function M.surround_range(style, start_pos, end_pos, space)
    local opening, closing = parse_surround_style(style)
    if not opening or not closing then
        return
    end

    local add_spaces = resolve_space(space)
    local inner_prefix = add_spaces and " " or ""
    local inner_suffix = add_spaces and " " or ""

    local normalized_start, normalized_end = normalize_pos(start_pos, end_pos)
    local start_line = normalized_start[2]
    local end_line = normalized_end[2]

    if start_line == end_line then
        local line = vim.fn.getline(start_line)
        local front = line:sub(1, normalized_start[3] - 1)
        local selected = line:sub(normalized_start[3], normalized_end[3])
        local after = line:sub(normalized_end[3] + 1)

        line = front .. opening .. inner_prefix .. selected .. inner_suffix .. closing .. after
        vim.fn.setline(start_line, line)
        vim.fn.setpos(".", { normalized_start[1], normalized_start[2], normalized_start[3] + #opening, 0 })
    else
        local first_line = vim.fn.getline(start_line)
        local front = first_line:sub(1, normalized_start[3] - 1)
        local selected = first_line:sub(normalized_start[3])
        first_line = front .. opening .. inner_prefix .. selected
        vim.fn.setline(start_line, first_line)

        local last_line = vim.fn.getline(end_line)
        local selected_end = last_line:sub(1, normalized_end[3])
        local after = last_line:sub(normalized_end[3] + 1)
        last_line = selected_end .. inner_suffix .. closing .. after
        vim.fn.setline(end_line, last_line)
    end

    vim.fn.setpos(".", normalized_start)
    M.set_last_action("surround_range", { style, start_pos, end_pos, add_spaces })
end

function M.surround_selection(style)
    M.surround_range(style, vim.fn.getpos("v"), vim.fn.getpos("."))
end

function M.surround_word(style, space)
    local opening, closing = parse_surround_style(style)
    if not opening or not closing then
        return
    end

    local word = vim.fn.expand("<cword>")
    if word == "" then
        return
    end

    local add_spaces = resolve_space(space)
    local inner_prefix = add_spaces and " " or ""
    local inner_suffix = add_spaces and " " or ""
    local col_start = vim.fn.col(".")
    local current_line = vim.fn.getline(".")
    local word_pattern = vim.pesc(word)
    local search_from = 1

    while true do
        local start_idx, end_idx = current_line:find(word_pattern, search_from)
        if not start_idx then
            break
        end

        local before = start_idx > 1 and current_line:sub(start_idx - 1, start_idx - 1) or ""
        local after = end_idx < #current_line and current_line:sub(end_idx + 1, end_idx + 1) or ""
        local is_whole_word = not is_word_char(before) and not is_word_char(after)

        if is_whole_word and col_start >= start_idx and col_start <= end_idx then
            local updated_line = current_line:sub(1, start_idx - 1)
                .. opening
                .. inner_prefix
                .. word
                .. inner_suffix
                .. closing
                .. current_line:sub(end_idx + 1)
            vim.api.nvim_set_current_line(updated_line)
            vim.fn.cursor(0, col_start + #opening)
            M.set_last_action("surround_word", { style, add_spaces })
            return
        end

        search_from = end_idx + 1
    end
end

function M.surround_line(style, line_number, space)
    local line = line_number or vim.fn.line(".")
    local line_text = vim.fn.getline(line)
    if line_text == "" then
        return
    end

    M.surround_range(style, { 0, line, 1, 0 }, { 0, line, #line_text, 0 }, space)
end

function M.remove_or_change_surround_word(change, space)
    local word = vim.fn.expand("<cword>")
    if word == "" then
        return
    end

    local col_start = vim.fn.col(".")
    local current_line = vim.fn.getline(".")
    local new_opening, new_closing = nil, nil
    local inner_prefix = ""
    local inner_suffix = ""

    if change then
        new_opening, new_closing = parse_surround_style(change)
        if not new_opening or not new_closing then
            return
        end

        local add_spaces = resolve_space(space)
        inner_prefix = add_spaces and " " or ""
        inner_suffix = add_spaces and " " or ""
    end

    local updated_line = current_line:gsub(
        "([%(%)%{%}%[%]%\"'`<>,])%s*" .. vim.pesc(word) .. "%s*([%(%)%{%}%[%]%\"'`<>,])",
        function(opening, closing)
            if change then
                return new_opening .. inner_prefix .. word .. inner_suffix .. new_closing
            else
                return word
            end
        end,
        1
    )

    if current_line ~= updated_line then
        vim.api.nvim_set_current_line(updated_line)
        vim.fn.cursor(0, col_start)
        M.set_last_action("remove_or_change_surround_word", { change, change and inner_prefix == " " })
    else
        print("No surround characters found!")
    end
end

function M.operator_surround(style, motion_type, space)
    local start_pos = vim.fn.getpos("'[")
    local end_pos = vim.fn.getpos("']")

    if motion_type == "line" then
        local start_line = start_pos[2]
        local end_line = end_pos[2]
        start_pos[3] = 1
        end_pos[3] = #vim.fn.getline(end_line)
        M.surround_range(style, start_pos, end_pos, space)
        return
    end

    if motion_type == "char" or motion_type == "v" then
        M.surround_range(style, start_pos, end_pos, space)
    end
end

function M.surround_treesitter_node(style, node_types, space)
    if not vim.treesitter then
        print("Tree-sitter is not available.")
        return
    end

    local node = get_node_at_cursor()
    if not node then
        print("Tree-sitter node not found.")
        return
    end

    local target = find_node_by_type(node, node_types or opts.treesitter_nodes) or node
    local start_pos, end_pos = node_range_to_positions(target)
    M.surround_range(style, start_pos, end_pos, space)
end

function M.surround_treesitter_function(style, space)
    M.surround_treesitter_node(style, opts.treesitter_function_nodes, space)
end

function M.toggle_or_change_surround_selection(style)
    local opening, closing = parse_surround_style(style)
    if not opening or not closing then
        return
    end

    local add_spaces = false
    if not (opening == REMOVE_SENTINEL and closing == REMOVE_SENTINEL) then
        add_spaces = resolve_space(nil)
    end
    local inner_prefix = add_spaces and " " or ""
    local inner_suffix = add_spaces and " " or ""

    local start_pos, end_pos = normalize_pos(vim.fn.getpos("v"), vim.fn.getpos("."))
    local start_line = start_pos[2]
    local end_line = end_pos[2]

    local start_line_text = vim.fn.getline(start_line)
    local end_line_text = vim.fn.getline(end_line)
    local first_char = start_line_text:sub(start_pos[3], start_pos[3])
    local last_char = end_line_text:sub(end_pos[3], end_pos[3])

    if not M.surround_pairs[first_char] or M.surround_pairs[first_char][2] ~= last_char then
        print("Error: Selected text is not surrounded by a valid pair!")
        return
    end

    if opening == REMOVE_SENTINEL and closing == REMOVE_SENTINEL then
        if start_line == end_line then
            local selected = start_line_text:sub(start_pos[3], end_pos[3])
            local front = start_line_text:sub(1, start_pos[3] - 1)
            local after = start_line_text:sub(end_pos[3] + 1)
            local edited = string.sub(selected, 2, -2)
            vim.fn.setline(start_line, front .. edited .. after)
            M.set_last_action("toggle_or_change_surround_selection", { style })
        else
            local first_selected = start_line_text:sub(start_pos[3])
            local last_selected = end_line_text:sub(1, end_pos[3])
            local first_edited = string.sub(first_selected, 2, -1)
            local last_edited = string.sub(last_selected, 1, -2)
            vim.fn.setline(start_line, start_line_text:sub(1, start_pos[3] - 1) .. first_edited)
            vim.fn.setline(end_line, last_edited .. end_line_text:sub(end_pos[3] + 1))
            M.set_last_action("toggle_or_change_surround_selection", { style })
        end
    elseif M.surround_pairs[first_char] and M.surround_pairs[first_char][2] == last_char then
        if start_line == end_line then
            local selected = start_line_text:sub(start_pos[3] + 1, end_pos[3] - 1)
            local front = start_line_text:sub(1, start_pos[3] - 1)
            local after = start_line_text:sub(end_pos[3] + 1)
            vim.fn.setline(start_line, front .. opening .. inner_prefix .. selected .. inner_suffix .. closing .. after)
            M.set_last_action("toggle_or_change_surround_selection", { style })
        else
            local first_selected = start_line_text:sub(start_pos[3] + 1)
            local last_selected = end_line_text:sub(1, end_pos[3] - 1)
            vim.fn.setline(
                start_line,
                start_line_text:sub(1, start_pos[3] - 1) .. opening .. inner_prefix .. first_selected
            )
            vim.fn.setline(end_line, last_selected .. inner_suffix .. closing .. end_line_text:sub(end_pos[3] + 1))
            M.set_last_action("toggle_or_change_surround_selection", { style })
        end
    else
        print("Error: input character does not have a valid pair!")
    end

    vim.fn.setpos(".", start_pos)
end

return M
