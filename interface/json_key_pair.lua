local response_result = require "response_result"
local rsa = require "rsa"

local rsa_public_key, rsa_priv_key, err = rsa:generate_rsa_keys(2048)
if not rsa_public_key then
    ngx.log(ngx.ERR, '秘钥对签发失败:' , err)
    ngx.say(response_result.err(nil, "秘钥对签发失败"))
    ngx.exit(ngx.OK)
end

local key_pair_table = {publicKey=rsa_public_key,privateKey=rsa_priv_key}
ngx.header.content_type = "application/json; charset=utf-8"
ngx.say(response_result.success(key_pair_table))
ngx.exit(ngx.OK)