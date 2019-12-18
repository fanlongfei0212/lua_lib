local dkjson = require "dkjson"

local response_result = {}

local default_data = "ok"
local default_code = 0
local default_message = "success"
local error_info_500 = "系统异常"

local function init()
    local result = {}
    result.data = default_data
    result.code = default_code
    result.message = default_message
    return result
end

--请求返回信息成功
function response_result.success(data, code, message)
    local result = init()
    if data then
        result.data = data
    end
    if code then
        result.code = code
    end
    if message then
        result.message = message
    end
    return dkjson.encode(result)
end

--请求返回信息异常
function response_result.error(code, message)
    local result = init()
    if code then
        result.code = code
    else
        result.code = 500
    end
    if message then
        result.message = message
    else
        result.message = error_info_500
    end
    result.data = nil
    return dkjson.encode(result)
end

--请求返回信息成功JSONP
function response_result.jsonp_success(data, code, message, callback)
    if callback and type(callback) == "string" then
        local success_info = response_result.success(data, code, message)
        local result = callback .. "(" .. success_info .. ")"
        return result
    end
    return response_result.success(data, code, message)
end

--请求返回信息异常JSONP
function response_result.jsonp_error(code, message, callback)
    if callback and type(callback) == "string" then
        local error_info = response_result.error(code, message)
        local result = callback .. "(" .. error_info .. ")"
        return result
    end
    return response_result.error(code, message)
end

return response_result