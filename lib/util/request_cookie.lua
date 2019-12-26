local common_util = require "common_util"
local ck = require "cookie"
local request_cookie = {}

local function init_cookie_obj()
    local cookie, err = ck:new()
    if not cookie then
        ngx.log(ngx.ERR, err)
        return nil
    end
    return cookie
end

--获取所有的cookie
--返回:cookie名称以及对应值的table对象，如果某些cookie不存在
function request_cookie.get_all()
    local cookie = init_cookie_obj()
    if not cookie then
        return nil
    end
    local fields, err = cookie:get_all()
    local result = {}
    if not next(fields) then
        return nil
    end
    for k, v in pairs(fields) do
        result[k] = v
    end
    if not next(result) then
        return nil
    end
    return result
end

--批量获取指定的cookie
--入参:要获取的cookie名称table数组
--返回:cookie名称以及对应值的table对象
function request_cookie.get_cookies(cookie_names)
    local result = nil
    if not cookie_names or type(cookie_names) ~= "table" or not common_util.is_array(cookie_names) or not next(cookie_names) then
        return result
    end
    result = {}
    local all_cookie = request_cookie.get_all()
    if not all_cookie then
        return nil
    end
    for i, v in ipairs(cookie_names) do
        for k_2, v_2 in pairs(all_cookie) do
            if v == k_2 then
                result[v] = v_2
            end
        end
    end
    return result
end

--单个获取指定的cookie
--入参:要获取的cookie名称
--返回:cookie名称以及对应值的table对象，如果某些cookie不存在，则对应的值为nil
function request_cookie.get_cookie(cookie_name)
    if not cookie_name then
        return nil
    end
    local cookie = init_cookie_obj()
    if not cookie then
        return nil
    end
    local fields, err = cookie:get(cookie_name)
    if not fields then
        return nil
    end
    return fields
end

--设置cookie
--入参:要设置的cookie名称以及对应值的table对象
--返回:true-->成功 false-->失败
function request_cookie.set_cookie(cookie_data)
    if not cookie_data or type(cookie_data) ~= "table" or not next(cookie_data) or common_util.is_array(cookie_data) then
        return false
    end
    local cookie = init_cookie_obj()
    if not cookie then
        return false
    end
    local ok, err = cookie:set(cookie_data)
    if not ok then
        ngx.log(ngx.ERR, err)
    end
    return ok 
end

return request_cookie