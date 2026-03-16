local utils = {}

---Formats translation entries that use such a format:
---```lua
---local params = {param1 = "Str1", paramNamed = "Str2", helloWorld="Str3",}
---local txt = formatTemplate("{param1} {paramNamed} {helloWorld}", params)
---```
---@param template string
---@param params table<string, string>
---@nodiscard
utils.formatTemplate = function(template, params)
    return template:gsub("{(%w+)}", params)
end

return utils