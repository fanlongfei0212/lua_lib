local response_result = require "response_result"

local function response_result_default_success()
    ngx.say(response_result.success())
end

response_result_default_success()

local function response_result_success()
    local data = {result_1="返回值1", result_2="返回值2"}
    ngx.say(response_result.success(data, nil, nil))
end

response_result_success()

local function response_result_default_error()
    ngx.say(response_result.error())
end

response_result_default_error()

local function response_result_error()
    ngx.say(response_result.error("sys_001", "查询出错"))
end

response_result_error()

local function response_result_success_jsonp()
    local data = {result_1="返回值1", result_2="返回值2"}
    ngx.say(response_result.jsonp_success(data, nil, nil, "callback"))
end

response_result_success_jsonp()

local function response_result_error_jsonp()
    ngx.say(response_result.jsonp_error("sys_001", "查询出错", "callback"))
end

response_result_error_jsonp()