local M = {}

function M.get_node_at_cursor()
    if vim.treesitter and vim.treesitter.get_node then
        return vim.treesitter.get_node()
    end

    if vim.treesitter and vim.treesitter.get_node_at_pos then
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        return vim.treesitter.get_node_at_pos(0, row - 1, col)
    end

    return nil
end

function M.node_range_to_positions(node)
    local start_row, start_col, end_row, end_col = node:range()
    if end_col == 0 and end_row > start_row then
        end_row = end_row - 1
        end_col = #vim.fn.getline(end_row + 1)
    end

    local start_pos = { 0, start_row + 1, start_col + 1, 0 }
    local end_pos = { 0, end_row + 1, math.max(1, end_col), 0 }
    return start_pos, end_pos
end

function M.find_node_by_type(node, type_list)
    if not node then
        return nil
    end

    local type_set = {}
    for _, value in ipairs(type_list) do
        type_set[value] = true
    end

    local current = node
    while current do
        if type_set[current:type()] then
            return current
        end
        current = current:parent()
    end

    return nil
end

return M
