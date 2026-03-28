# Simple Surround Plugin

This Neovim plugin provides a simple way to surround selected text or the word under the cursor with custom or predefined styles. It also includes functionality to remove or change surrounding characters.
But it is just fit with my needs (simple), if you find alternative to it, please use.
(I will add more functions that I think I need to use while surrounding text. Such as: surround a line, selected text after spliting by specified character, for instance: ",")

## Features

- Surround selected text or the word under the cursor with various styles such as `()`, `{}`, `[]`, `""`, `''`, and more.
- Supports custom styles with one or two characters.
- Remove or change the existing surrounding style.
- Toggle surround for selections.
- Operator-pending surround motions (surround with any motion/text object).
- Tree-sitter-aware surrounds for structural nodes (arguments, functions, tables, JSX).
- Multi-element surround with configurable separator (e.g., `abc, def, ghj` -> `"abc", "def", "ghj"`).
- Smart spacing preservation in multi-surround (keeps spaces if present, no spaces for CSV-style input).
- Prefix/suffix mode for language constructs (e.g., `if (x)`, `<!-- comment -->`).
- Unwrap mode for quick removal of surround characters.
- Visual block support for column-wise selections (`Ctrl-v`).
- Optional repeat support via `repeat.vim`.
- Configurable spacing policy inside surrounds.
- Fully customizable keymaps.
- Built-in help documentation (`:help simple-surr`).

## DEMO

(TODO)

## Installation

### Using Packer

To install this plugin using [packer.nvim](https://github.com/wbthomason/packer.nvim), add the following to your `plugins.lua` or equivalent:

```lua
use {
    'kunkka19xx/simple-surr',
    config = function()
        require('simple-surr').setup {
            keymaps = {
                surround_selection = "<leader>s",       -- Keymap for surrounding selection
                surround_word = "<leader>sw",          -- Keymap for surrounding word
                remove_or_change_surround_word = "<leader>sr", -- Keymap for removing/changing surrounding word
                toggle_or_change_surround_selection = "<leader>ts", -- Keymap for removing/changing surrounding selected text
                surround_motion = "gs",                -- Operator-pending surround
                surround_line = "gss",                 -- Surround current line
                surround_treesitter = "gst",           -- Surround tree-sitter node
                surround_function = "gsf",             -- Surround tree-sitter function node
                surround_multi = "gsm",               -- Multi-element surround with separator
                surround_prefix_suffix = "gsp",        -- Prefix/suffix surround
                unwrap = "sd",                        -- Unwrap/remove surround
                surround_block = "gsb",                -- Visual block surround
            }
        }
    end
}
```

### Using Lazy

```lua
return {
    'kunkka19xx/simple-surr',
    config = function()
        require("simple-surr").setup {
            keymaps = {
                surround_selection = "<leader>s",       -- Keymap for surrounding selection
                surround_word = "<leader>sw",          -- Keymap for surrounding word
                remove_or_change_surround_word = "<leader>sr", -- Keymap for removing/changing surrounding word
                toggle_or_change_surround_selection = "<leader>ts", -- Keymap for removing/changing surrounding selected text
                surround_motion = "gs",                -- Operator-pending surround
                surround_line = "gss",                 -- Surround current line
                surround_treesitter = "gst",           -- Surround tree-sitter node
                surround_function = "gsf",             -- Surround tree-sitter function node
                surround_multi = "gsm",               -- Multi-element surround with separator
                surround_prefix_suffix = "gsp",        -- Prefix/suffix surround
                unwrap = "sd",                        -- Unwrap/remove surround
                surround_block = "gsb",                -- Visual block surround
            },
        }
    end,
}
```

## Setup

The plugin can be configured using the `setup` function. You can override the default keymaps:

```lua
require('simple-surr').setup {
    keymaps = {
        surround_selection = "<leader>s",       -- Keymap for surrounding selection
        surround_word = "<leader>sw",          -- Keymap for surrounding word
        remove_or_change_surround_word = "<leader>sr", -- Keymap for removing/changing surrounding word
        surround_motion = "gs",                -- Operator-pending surround
        surround_line = "gss",                 -- Surround current line
        surround_treesitter = "gst",           -- Surround tree-sitter node
        surround_function = "gsf",             -- Surround tree-sitter function node
        surround_multi = "gsm",               -- Multi-element surround with separator
        surround_prefix_suffix = "gsp",        -- Prefix/suffix surround
        unwrap = "sd",                        -- Unwrap/remove surround
        surround_block = "gsb",                -- Visual block surround
    }
}
```

If no configuration is provided, the plugin will use the default keymaps:

- `<leader>s`: Surround selected text.
- `<leader>sw`: Surround the word under the cursor.
- `<leader>sr`: Remove or change the surrounding style of a word.
- `gs`: Operator-pending surround (use with a motion/text object).
- `gss`: Surround current line.
- `gst`: Surround tree-sitter node under cursor (arguments/table/JSX/etc.).
- `gsf`: Surround nearest tree-sitter function node.
- `gsm`: Surround multiple elements separated by a character.
- `gsp`: Surround with prefix and suffix.
- `sd`: Unwrap/remove surround characters.
- `gsb`: Surround visual block (column selection).

## Usage

### Surround Selected Text

1. Visually select the text you want to surround.
2. Press `<leader>s` (or your configured keymap).
3. Enter the desired surround style (e.g., `(`, `{`, `[`, `'`, `"`, `\``, or custom styles like `<>`).
4. (Optional) Add spaces inside the surrounding characters by typing `y` when prompted (see spacing policy below).

### Surround Word Under Cursor

1. Place the cursor on the word you want to surround.
2. Press `<leader>sw` (or your configured keymap).
3. Enter the desired surround style.
4. (Optional) Add spaces inside the surrounding characters by typing `y` when prompted (see spacing policy below).

### Remove or Change Surround Style

1. Place the cursor on the word you want to modify.
2. Press `<leader>sr` (or your configured keymap).
3. Enter the new surround style or leave it blank to remove the existing surrounding characters.

### Toggle Surround for Selection

1. Visually select the text you want to toggle or change the surround for.
2. Press `<leader>ts` (or your configured keymap).
3. Enter the new surround style or leave it blank to remove the existing surrounding characters.

### Surround with Motion (Operator-Pending)

1. Press `gs` (or your configured keymap).
2. Enter the desired surround style.
3. Execute any motion/text object (e.g., `iw`, `ap`, `i(`, `}`) to surround that range.

### Surround Current Line

1. Press `gss` (or your configured keymap).
2. Enter the desired surround style.

### Surround Tree-sitter Node

1. Place the cursor inside arguments/function/table/JSX node.
2. Press `gst` (or `gsf` for function node).
3. Enter the desired surround style.

### Repeat Last Action

If you have [repeat.vim](https://github.com/tpope/vim-repeat) installed, you can use `.` to repeat the last simple-surr action.

### Surround Multiple Elements

Surround multiple elements separated by a character (e.g., comma, semicolon):

1. Visually select the text containing multiple elements (e.g., `abc, def, ghj`).
2. Press `gsm` (or your configured keymap).
3. Enter the desired surround style (e.g., `"`).
4. Enter the separator character (default: `,`).

Examples:
- `abc, def, ghj` with `"` and `,` -> `"abc", "def", "ghj"`
- `foo,bar,baz` with `"` and `,` -> `"foo","bar","baz"` (no spaces, CSV-style)
- `foo; bar; baz` with `()` and `;` -> `(foo); (bar); (baz)`

### Prefix/Suffix Surround

Surround with different prefix and suffix (useful for language constructs):

1. Visually select the text you want to surround.
2. Press `gsp` (or your configured keymap).
3. Enter the prefix (e.g., `if (`).
4. Enter the suffix (e.g., `)`).

Examples:
- `x` with prefix `if (` and suffix `)` -> `if (x)`
- `content` with prefix `<!--` and suffix `-->` -> `<!-- content -->`
- `x` with prefix `{{` and suffix `}}` -> `{{ x }}`

### Unwrap/Remove Surround

Quickly remove surround characters from text:

1. Place cursor on a surrounded word (normal mode) or select surrounded text (visual mode).
2. Press `sd` (or your configured keymap).
3. Enter the surround style to remove (or leave empty for auto-detect).

Examples:
- `("hello")` with `sd` and empty -> `hello`
- `["world"]` with `sd` and `[` -> `world`

### Visual Block Surround

Surround a column-wise selection (like in spreadsheets):

1. Enter visual block mode with `Ctrl-v`.
2. Select the columns you want to surround using any motion.
3. Press `gsb` (or your configured keymap).
4. Enter the surround style.

Supported visual block motions: `h`, `l`, `w`, `e`, `b`, `$`, `0`, `f{char}`, `t{char}`, `F{char}`, `T{char}`, `j`, `k`, `gg`, `G`, etc.

Examples:

Select columns and surround:
```
a b c   ->   |a| |b| |c|
d e f         |d| |e| |f|
```

Select entire lines with `Ctrl-v$` and surround:
```
go          ->   [go]
goose       ->   [goose]
gotools     ->   [gotools]
pgformatter ->   [pgformatter]
sqlc        ->   [sqlc]
```

Select to end of each line with `$`:
```
foo      ->   [foo]
bar      ->   [bar]
bazzzz   ->   [bazzzz]
```

Select from specific column to end with `l$`:
```
abc          ->   [abc]
defgh        ->   [defgh]
ijklmnop     ->   [ijklmnop]
```

Note: Lines shorter than the selection start column are skipped.

## Customization

You can customize the predefined surround pairs through setup function:

```lua
require("simple-surr").setup({
    custom_surround_pairs = {
        ["|"] = {"|", "|"},  -- Custom surround pair
        ["$"] = {"$", "$"},  -- Custom surround pair
        ["b"] = {"{", ")"},  -- Custom surround pair
    },
    -- if you want append pairs, not overwirte, please don't set *overwrite_default_pairs* value
    overwrite_default_pairs = true,  -- Overwrite the default surround pairs
    -- spacing policy: "prompt" (default), "always", or "never"
    space = "prompt",
    -- override tree-sitter node types
    treesitter_nodes = { "arguments", "parameters", "table_constructor" },
    treesitter_function_nodes = { "function_definition", "function" },
})
```

## License

This plugin is released under the MIT License.
