local response_result = require "response_result"
local common_util = require "common_util"

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

--设置header中的值
--入参:要设置参数名称以及对应值的table(table为对象,属性的值可以是数组,但不能是对象);如果请求头中存在相同的值参数,是否进行值替换(true-->替换 false-->保留原值)
--返回:boolean,true-->成功 false-->失败
function req_header.set_header(args, is_replace)
    if not is_replace or type(is_replace) ~= "boolean" then
        is_replace = false
    end
    if not args or type(args) ~= "table" then
        return false
    end
    if is_replace then
        for k, v in pairs(args) do
            if (type(v) == "table" and common_util.is_array(v)) or type(v) ~= "table" then
                ngx.req.set_header(k, v)
            end
        end
    else
        local request_header_source = req_header.get_header_all()
        local result_key = {}
        if request_header_source then
            local k_array = common_util.kv_separate(request_header_source)
            for k, v in pairs(args) do
                if not common_util.contain(k_array, k) then
                    table.insert( result_key, k )
                end
            end
        end
        for i, v in ipairs(result_key) do
            ngx.req.set_header(v, args[v])
        end
    end
    return true
end

--清除header中的值
--入参:table要设置参数名称以及对应值的table(table是数组，不能是对象)
--返回:boolean,true-->成功 false-->失败
function req_header.clear_header(data)
    if not data or type(data) ~= "table" or (type(data) == "table" and not common_util.is_array(data) or not next(data)) then
        return false
    end
    for i, v in ipairs(data) do
        ngx.req.clear_header(v)
    end
    return true
end

return req_header