local request_header = require "request_header"

local function get_header_all()
    local result = request_header.get_header_all()
    if result then
        for k, v in pairs(result) do
            if type(v) == "table" then
                ngx.say("key:" .. k .. " value:" .. table.concat( v, "," ))
            else
                ngx.say("key:" .. k .. " value:" .. v)
            end
        end
    end
end

get_header_all()

local function get_header()
    local args = {"text1", "text2"}
    local result = request_header.get_header(args)
    if result then
        for k, v in pairs(result) do
            if type(v) == "table" then
                ngx.say("key:" .. k .. " value:" .. table.concat( v, "," ))
            else
                ngx.say("key:" .. k .. " value:" .. v)
            end
        end
    end
end

get_header()