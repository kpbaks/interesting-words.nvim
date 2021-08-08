local config = require("interesting-words.config")
local utils = require("interesting-words.utils")
local cmd = vim.cmd
local M = {}

-- telescope ???

M.interesting_words = {}
local count = 1
M.match_ids = {}

local function color_word(word)
    local idx

    if M.opts.random then
        idx = math.random(#M.opts.colors)
    else
        idx = count
        -- reset count to 1, if idx larger than length of table
        if count >= #M.opts.colors then
            count = 1
        else
            count = count + 1
        end
    end
    local match_id = vim.fn.matchadd("InterestingWord" .. idx, word)
    M.interesting_words[word] = match_id
end

local function uncolor_word(word)
    local match_id = M.interesting_words[word]
    if match_id ~= nil then
        vim.fn.matchdelete(match_id)
        M.interesting_words[word] = nil
    end
end
M.add_interesting_word = function(mode)
    local modes = {
        n = function()
            return vim.fn.expand("<cword>")
        end,
        v = function()
            return utils.get_visual_selection()
        end,
    }
    local current_word
    local fn = modes[mode]
    if fn ~= nil then
        current_word = fn()
    end

    if not (current_word:len() > 0) then
        return
    end

    -- if utils.check_ignore_case(current_word) then
    --     current_word = current_word:lower()
    -- end

    if M.interesting_words[current_word] == nil then
        color_word(current_word)
    else
        uncolor_word(current_word)
    end
end

M.uncolor_all_words = function()
    for word, _ in pairs(M.interesting_words) do
        uncolor_word(word)
    end
end

M.setup = function(opts)
    local defaults = {
        colors = {
            "#aeee00",
            "#ff0000",
            "#0000ff",
            "#b88823",
            "#ffa724",
            "#ff2c4b",
        },
        random = false,
        default_keybindings = true,
    }
    M.opts = vim.tbl_extend("force", defaults, (opts or {}))
    for idx, color in ipairs(M.opts.colors) do
        cmd("highlight InterestingWord" .. idx .. " guibg=" .. color)
    end
    if M.opts.random then
        math.randomseed(os.time())
    end
    if M.opts.default_keybindings then
        vim.api.nvim_set_keymap(
            "n",
            "<leader>k",
            "<cmd>lua require('interesting-words').add_interesting_word('n')<CR>",
            {}
        )
        vim.api.nvim_set_keymap("n", "<leader>K", "<cmd>lua require('interesting-words').uncolor_all_words()<CR>", {})
    end
end

return M
