local surround = require("simple-surr.surround")

describe("simple-surr", function()
    before_each(function()
        vim.opt.rtp:append(vim.fn.getcwd())
        surround.set_options({ space = "never" })
        vim.cmd("enew!")
    end)

    it("normalizes reversed ranges", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "foo bar" })
        surround.surround_range("()", { 0, 1, 3, 0 }, { 0, 1, 1, 0 }, false)
        assert.equals("(foo) bar", vim.api.nvim_get_current_line())
    end)

    it("surrounds the word under cursor only", function()
        vim.api.nvim_set_current_line("foo foo")
        vim.api.nvim_win_set_cursor(0, { 1, 5 })
        surround.surround_word("[]", false)
        assert.equals("foo [foo]", vim.api.nvim_get_current_line())
    end)

    it("surrounds line via operator", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha", "beta" })
        vim.fn.setpos("'[", { 0, 1, 1, 0 })
        vim.fn.setpos("']", { 0, 1, 5, 0 })
        surround.operator_surround("{}", "line", false)
        assert.equals("{alpha}", vim.api.nvim_buf_get_lines(0, 0, 1, false)[1])
    end)

    it("applies spacing policy", function()
        vim.api.nvim_set_current_line("word")
        vim.api.nvim_win_set_cursor(0, { 1, 1 })
        surround.surround_word("()", true)
        assert.equals("( word )", vim.api.nvim_get_current_line())
    end)

    it("accepts custom surround pairs via setup", function()
        require("simple-surr").setup({
            custom_surround_pairs = {
                ["!"] = { "!", "!" },
            },
        })
        vim.api.nvim_set_current_line("wow")
        vim.api.nvim_win_set_cursor(0, { 1, 1 })
        surround.surround_word("!", false)
        assert.equals("!wow!", vim.api.nvim_get_current_line())
    end)
end)
