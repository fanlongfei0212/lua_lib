local request_header = require "request_header"

local function set_header()
    local edit_header_table = {
        cookie="cookie_test", 
        test1="test1", 
        test_2="test_2", 
        test3={"test3_1", "test3_2"}
    }
    local set_result = request_header.set_header(edit_header_table, false)
    local result = ngx.location.capture("/common/request_header/demo/capture")
    ngx.say(set_result)
    ngx.say(result.body)
end

set_header()

local function set_header_replace()
    local edit_header_table = {
        cookie="cookie_test", 
        test1="test1", 
        test_2="test_2", 
        test3={"test3_1", "test3_2"}
    }
    local set_result = request_header.set_header(edit_header_table, true)
    local result = ngx.location.capture("/common/request_header/demo/capture")
    ngx.say(set_result)
    ngx.say(result.body)
end

set_header_replace()