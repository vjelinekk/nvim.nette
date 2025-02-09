local M = {}

M.setup = function ()
    -- Nette 
    print("Setting up Nette")
end

require('lspconfig').intelephense.setup {
    settings = {
        intelephense = {
            files = {
                associations = {
                    "*.php", "*.latte"
                }
            }
        }
    }
}

local cmp = require("cmp")

-- Define Latte keywords for completion
local latte_keywords = {
    "if", "elseif", "else", "ifset", "elseifset", "ifchanged",
    "switch", "case", "default", "foreach", "for", "while",
    "continueIf", "skipIf", "breakIf", "exitIf", "first", "last",
    "sep", "iterateWhile", "include", "sandbox", "block", "define",
    "layout", "embed", "try", "rollback", "var", "default",
    "parameters", "capture", "varType", "varPrint", "templateType",
    "templatePrint", "translate", "contentType", "debugbreak",
    "do", "dump", "php", "spaceless", "syntax", "trace",
    "link", "plink", "control", "snippet", "snippetArea",
    "cache", "form", "label", "input", "inputError", "formContainer"
}

-- Function to extract variables from {var}, {varType}, and variables starting with $
local function parse_latte_vars()
    local latte_vars = {}
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        -- Match {var ...} and {varType ...}
        for var_name in line:gmatch("{var%s+([%w_]+)%s*=") do
            table.insert(latte_vars, var_name)
        end
        for var_name in line:gmatch("{varType%s+[%w_]+%s+([%w_]+)%s*}") do
            table.insert(latte_vars, var_name)
        end
        -- Match any variable starting with $
        for var_name in line:gmatch("%$[%w_]+") do
            -- Strip the leading '$' before adding the variable name
            table.insert(latte_vars, var_name:sub(2))
        end
    end
    return latte_vars
end

-- Define a properly structured Latte completion source
local latte_source = {}

function latte_source.new()
    return setmetatable({}, { __index = latte_source })
end

-- Trigger only on '$' and '{'
function latte_source.get_trigger_characters()
    return { "{", "$" }
end

-- Function to complete based on the current input
function latte_source.complete(_, params, cb)
    local latte_items = {}

    local input = string.sub(params.context.cursor_before_line, params.offset - 1)
    local prefix = string.sub(params.context.cursor_before_line, 1, params.offset - 1)

    -- If the current character is '$', suggest all variables in buffer starting with '$'
    if vim.startswith(input, "$") and (prefix == "$" or vim.endswith(prefix, "$")) then
        local latte_vars = parse_latte_vars()
        local seen_vars = {} -- Set to track unique variables

        for _, var_name in ipairs(latte_vars) do
            if not seen_vars[var_name] then
                seen_vars[var_name] = true -- Mark as seen
                table.insert(latte_items, {
                    label = var_name,
                    kind = cmp.lsp.CompletionItemKind.Variable,
                })
            end
        end

        cb({ items = latte_items, isIncomplete = false })
        return -- Ensure no further suggestions are added
    end

    -- Otherwise, suggest Latte keywords
    for _, keyword in ipairs(latte_keywords) do
        table.insert(latte_items, {
            label = keyword,
            kind = cmp.lsp.CompletionItemKind.Keyword,
        })
    end

    -- Return the completion suggestions
    cb({ items = latte_items, isIncomplete = false })
end

function latte_source.is_available()
    return vim.bo.filetype == "latte.html"
end

-- Register the source in cmp
cmp.register_source("custom_latte", latte_source.new())

-- Setup nvim-cmp for .latte files
cmp.setup.filetype({ "latte.html", "html" }, {
    sources = cmp.config.sources({
        { name = "custom_latte" },                -- Custom Latte completion
        { name = "nvim_lsp" },                    -- LSP completion (HTML, CSS, etc.)
        { name = "buffer", keyword_length = 2 },  -- Suggest words from buffer
        { name = "path" },                        -- File paths
        { name = "luasnip" },                     -- Snippet completion (optional)
        { name = "emmet_ls" },                    -- Emmet support for fast HTML completion
    }),
})

return M
