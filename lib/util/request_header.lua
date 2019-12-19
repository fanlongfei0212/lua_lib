local response_result = require "response_result"
local req_header = {}

--获取全部的header的值
--返回:所有请求头中的所有参数以及对应值的table
function req_header.get_header_all()
    local result = nil
    local h, err = ngx.req.get_headers()
    if err then
        ngx.log(ngx.ERR, "获取请求头数据失败:", err)
        ngx.say(response_result.error(nil, "获取请求头数据失败"))
        ngx.exit(ngx.OK)
    end
    result = {}
    for k, v in pairs(h) do
        result[k] = v
    end
    if not next(result) then
        return nil
    end
    return result
end

--获取指定的header的值
--入参:需要获取的参数名称table(只支持字符串数组)
--返回:参数名称以及对应的值table
function req_header.get_header(arg_table)
    local result = nil
    if not arg_table or type(arg_table) ~= "table" or not next(arg_table) then
        return result
    end
    local h, err = ngx.req.get_headers()
    if err then
        ngx.log(ngx.ERR, "获取请求头数据失败:", err)
        ngx.say(response_result.error(nil, "获取请求头数据失败"))
        ngx.exit(ngx.OK)
    end
    result = {}
    for k, v in pairs(h) do
        for i, v_2 in ipairs(arg_table) do
            if type(v_2) ~= "string" then
                return nil
            end
            if k == v_2 then
                result[k] = v
            end
        end
    end
    if not next(result) then
        return nil
    end
    return result
end

return req_header