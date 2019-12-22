local request_header = require "request_header"

function request_header_clear()
    local header = {"connection", "host"}
    local clear_result = request_header.clear_header(header)
    local result = ngx.location.capture("/common/request_header/demo/capture")
    ngx.say(clear_result)
    ngx.say(result.body)
end

request_header_clear()