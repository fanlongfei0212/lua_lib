local request_cookie = require "request_cookie"

local function request_cookie_get_all()
    local result = request_cookie.get_all()
    if result then
        for k, v in pairs(result) do
            ngx.say(k .. ":" .. v)
        end
    end
end

request_cookie_get_all()

local function request_cookie_get_names()
    local names = {"_ga", "JSESSIONID"}
    local result = request_cookie.get_cookies(names)
    if result then
        for k, v in pairs(result) do
            ngx.say(k .. ":" .. v)
        end
    end
end

request_cookie_get_names()

local function request_cookie_get_name()
    local cookie = request_cookie.get_cookie("_ga")
    ngx.say(cookie)
end

request_cookie_get_name()