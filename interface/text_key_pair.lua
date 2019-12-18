local response_result = require "response_result"
local rsa = require "rsa"

local isPKCS8 = true;
local rsa_public_key, rsa_priv_key, err = rsa:generate_rsa_keys(2048, isPKCS8)
if not rsa_public_key then
    ngx.log(ngx.ERR, '秘钥对签发失败:' , err)
    ngx.say(response_result.err(nil, "秘钥对签发失败"))
    ngx.exit(ngx.OK)
end

ngx.header.content_type = "text/html; charset=utf-8"
ngx.say(rsa_public_key)
ngx.say(rsa_priv_key)
ngx.exit(ngx.OK)