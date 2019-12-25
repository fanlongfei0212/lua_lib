local request_cookie = require "request_cookie"

local function request_cookie_set()
    local cookie = {
        key = "Name",
        value = "Bob",
        path = "/",
        domain = "localhost",
        secure = true, httponly = true,
        expires = "Wed, 09 Jun 2021 10:18:14 GMT",
        max_age = 50,
        samesite = "Strict",
        extension = "a4334aebaec"
    }
    local set_result = request_cookie.set_cookie(cookie)
    ngx.say(set_result)
end

request_cookie_set()