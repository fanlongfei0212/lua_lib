# OpenResty中lua常用类库以及组件整理

* **Components**是对常用组件的使用记录整理以及描述

* **Lualib**是已有的第三方类库资源整理

* **MyLualib**是项目中自己编写的lua类库

* **MyLuaInterface**项目中用到的lua接口

Table of Contents
=================

* [Components](#Components)
    * [lua-redis-parser](#lua-redis-parser)
    * [redis2-nginx-module](#redis2-nginx-module)
* [Lualib](#Lualib)
    * [dkjson](#dkjson)
    * [rsa](#rsa)
* [MyLualib](#MyLualib)
    * [common_uitl](#common_util)
    * [request_args](#request_args)
    * [response_result](#response_result)
* [MyLuaInterface](#MyLuaInterface)
    * [rsa](#rsa)

Components
==========

在OpenResty中经常用到的组件:针对redis操作、对redis原生命令的解析以及转换等等

lua-redis-parser
----------------

**[官方文献](https://github.com/openresty/lua-redis-parser#parse_reply)**

主要作用:将lua中的table格式的redis命令转化成redis的原生命令,将redis返回的原生命令解析为lua中table,以及其他，详细信息可查阅官方文献

[Back to TOC](#table-of-contents)

redis2-nginx-module
-------------------

**[官方文献](https://github.com/openresty/redis2-nginx-module)**

主要作用:支持在OpenResty中lua对redis的各种操作,详细信息可查阅官方文献

[Back to TOC](#table-of-contents)

Lualib
======

**在OpenResty开发中已有的第三方类库**

dkjson
------

**[官方文献](http://dkolf.de/src/dkjson-lua.fsl/home)** 

主要作用:可以将lua的table转换为json格式(encode函数),可以将json格式的数据解析为lua中的table格式(decode函数),详细信息可查阅官方文献

[Back to TOC](#table-of-contents)

rsa
---

**[官方文献](https://github.com/spacewander/lua-resty-rsa)**

主要作用:生成rea公钥、私钥对,用于对数据的rsa加密以及解密,详细信息可查阅官方文献

[Back to TOC](#table-of-contents)

MyLualib
========

**在项目中自己编写的类库**

common_util
-----------

**判断数组中是否包含某个值**

```lua
local common_uitl = require "common_util"

local source = {"source", "source2", "source3"}
local target_true = "source"
local target_false = "target"

ngx.say(common_uitl.contain(source, target_true))
ngx.say(common_uitl.contain(source, target_false))
```

```json
true
false
```

**判断数组中是否包含其他数组所有值**

```lua
local common_uitl = require "common_util"

local source = {"source", "source2", "source3"}
local target_true = {"source2", "source3"}
local target_false = {"source2", "tatget"}

ngx.say(common_uitl.contains(source, target_true))
ngx.say(common_uitl.contains(source, target_false))
```

```json
true
false
```

**按照指定字符分割字符串，并且返回table数组**

```lua
local common_uitl = require "common_util"

local source = "1,2,3,4,5,6,7"
local result = common_uitl.split(source, ",")
for i, v in ipairs(result) do
    ngx.say("下标" .. i .. "的值:" .. v)
end
```

```json
下标1的值:1
下标2的值:2
下标3的值:3
下标4的值:4
下标5的值:5
下标6的值:6
下标7的值:7
```

**数组去重**

```lua
local common_uitl = require "common_util"

local source = {"1", "2", "3", "4", "4", "5", "5"}
local result = common_uitl.distinct(source)
for i, v in ipairs(result) do
    ngx.say("下标" .. i .. "的值:" .. v)
end
```

```json
下标1的值:1
下标2的值:2
下标3的值:3
下标4的值:4
下标5的值:5
```

[Back to TOC](#table-of-contents)

request_args
------------

**获取请求中url参数值**

* 假设请求url:http://localhost:8888/request/args/demo?parameter1=参数1的值&parameter2=参数2的值

```lua
local request_args = require "request_args"

local args_names = {"parameter1", "parameter2"}
local args_values = request_args.get_args_by_name(args_names)

for k, v in pairs(args_values) do
    ngx.say("get请求中参数-->" .. k .. "的值:" .. v);
end
```

```json
get请求中参数-->parameter1的值:参数1的值
get请求中参数-->parameter2的值:参数2的值
```

**获取请求中body参数值(form表单)**

* 假设请求url:http://localhost:8888/request/args/demo

* 参数传递方式:parameter1=参数1的值&parameter2=参数2的值(form表单)

```lua
local request_args = require "request_args"

local args_names = {"parameter1", "parameter2"}
local args_values = request_args.post_args_by_name(args_names)

for k, v in pairs(args_values) do
    ngx.say("post请求中参数-->" .. k .. "的值:" .. v);
end
```

```json
post请求中参数-->parameter1的值:参数1的值
post请求中参数-->parameter2的值:参数2的值
```

**获取请求中body参数值(json格式)**

* 假设请求url:http://localhost:8888/request/args/demo

* 参数传递方式:

```json
{
  "parameter1":"参数1的值",
  "parameter2":"参数2的值"
}
```

```lua
local request_args = require "request_args"

local args_table = request_args.json_args_by_name()

ngx.say("post请求body体中的json参数-->parameter1的值:" .. args_table.parameter1)
ngx.say("post请求body体中的json参数-->parameter2的值:" .. args_table.parameter2)
```

```json
post请求中参数-->parameter1的值:参数1的值
post请求中参数-->parameter2的值:参数2的值
```

[Back to TOC](#table-of-contents)

response_result
---------------

**将返回数据封装指定的json格式，并且支持jsonp**

* 请求成功无返回数据

```lua
local response_result = require "response_result"

ngx.say(response_result.success())
```

```json
{"message":"success","data":"ok","code":0}
```

* 请求成功返回数据

```lua
local response_result = require "response_result"

local data = {result_1="返回值1", result_2="返回值2"}
ngx.say(response_result.success(data, nil, nil))
```

```json
{"message":"success","data":{"result_1":"返回值1","result_2":"返回值2"},"code":0}
```

* 请求失败默认格式

```lua
local response_result = require "response_result"

ngx.say(response_result.error())
```

```json
{"message":"系统异常","code":500}
```

* 请求失败指定编码以及描述

```lua
local response_result = require "response_result"

ngx.say(response_result.error("sys_001", "查询出错"))
```

```json
{"message":"查询出错","code":"sys_001"}
```

* jsonp

```lua
local response_result = require "response_result"

local data = {result_1="返回值1", result_2="返回值2"}
ngx.say(response_result.jsonp_success(data, nil, nil, "callback"))
ngx.say(response_result.jsonp_error("sys_001", "查询出错", "callback"))
```

```json
callback({"message":"success","data":{"result_1":"返回值1","result_2":"返回值2"},"code":0})
callback({"message":"查询出错","code":"sys_001"})
```

[Back to TOC](#table-of-contents)

MyLuaInterface
========

**常用lua接口**

rsa
---

**json_key_pair.lua接口:rsa秘钥对签发（返回值为json格式）**

该接口引用了rsa.lua以及response_result.lua，进行随机rsa秘钥对的签发，可以直接作为接口在openresty中进行location配置调用

* location配置

```conf
content_by_lua_file json_key_pair.lua;
```

* 接口源码

```lua
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
```

* 响应结果

**注意：序列化后会带换行符**

```json
{
    "message": "success",
    "data": {
        "publicKey": "-----BEGIN RSA PUBLIC KEY-----\nMIIBCgKCAQEA1Vkj/Hx5Ow4137JeWJoREFutx8jnQidLD53i8bMlBwMoyYIu+YS6\npFLKniyYDvJJbiBcJeZMhkaMSplgA6NHQ1PGVlFM4cP77Hal+xCoxMvzlQltsGOb\ncqK6v8qMQzseVC9qTaoekAcjMCIiXVuaILFaEX5HaX4mVrgC+1zzQ+b3ls1/umgl\nY4WSq2ojrhin1tJBgUtYhecm67OvD7x4en67VLu3rDwteNww7iFrRwZdpQ6HiWWV\nrhZaxp/uBptqWErasyAr9AdCGOg/zqh7Mrw6phJy9Ugo3ndiGceE7/cZ41yiZkLE\nsiu3OOjFHr2lf1pU8rRrN5pqsqTv/n+iFQIDAQAB\n-----END RSA PUBLIC KEY-----\n",
        "privateKey": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA1Vkj/Hx5Ow4137JeWJoREFutx8jnQidLD53i8bMlBwMoyYIu\n+YS6pFLKniyYDvJJbiBcJeZMhkaMSplgA6NHQ1PGVlFM4cP77Hal+xCoxMvzlQlt\nsGObcqK6v8qMQzseVC9qTaoekAcjMCIiXVuaILFaEX5HaX4mVrgC+1zzQ+b3ls1/\numglY4WSq2ojrhin1tJBgUtYhecm67OvD7x4en67VLu3rDwteNww7iFrRwZdpQ6H\niWWVrhZaxp/uBptqWErasyAr9AdCGOg/zqh7Mrw6phJy9Ugo3ndiGceE7/cZ41yi\nZkLEsiu3OOjFHr2lf1pU8rRrN5pqsqTv/n+iFQIDAQABAoIBAQCKGmzQCOcU0ksP\nZc/qvLhlBWOFmsgQK41MK6D3YkaKtoHVhx7PSBrlOe6M20MHEdF0px/fLKfGl65C\nr+vWDwCXVYhi4bfJwOq3k8o3rf4BfiBMDlFhx+idGTeX5Q5Mit1EE3lVktS72NLv\nWnkyQ5SOqx8pibvCTvWUVwMfIXkbLx2cNoV/lbRLTvMVADF/8MCmC1cJ5h4oJOhU\nopwTkb8P1/eOHOHLWju5qjOUIVJdF/MOAPrBIyUNOW+7dzW0L3zQMgUQ1vc5aWBZ\n6uK/m0/h4VFOJwimwVN4XP8MG0Bi2zJjo2ausPv3JtJBxWcrcOkGNzeo6+VCz4+t\n+vpZ0QNVAoGBAPTS5ptS5NQjkvMqqhky3GTiDJay5ruNs+ek+xzjCUFE4bBWrdxA\nHFlnRAIRM9bZGWG30wYAMQ5P0XtgH9+ZL99zktDxR4Fu6yaZK+H2vHMMcfuPTEpd\nGN86Is5acPt2zGl2jt8HhT7MinjEcduCoPJpaEjDsXWWSeCvjBhP78WzAoGBAN8W\nZ4Aa2yAltVvc6bASf+86rOhFlbQDeOA/kID/2+oPsVWdNFPO9/nxDp0rxNaSFRN/\nYYGn69SZ4Ws/6QG3advj0JKaACe9Itr6CnXn6be6JSz1ZsRYYF7hClCHZx3iXK1a\nvm8GnXOyPFI217Yyd17eNbHVt11buGCO4BepFiUXAoGAY0KawsDCDAx8SOC0ZFEN\nsE1CA1t3VvVlynZGZXjbSL4vrroF9XV8yPaoSRpGZUZSFx9bjGRJf173NMlNQu+t\nzC/kh5g7gIvDBTw24X+S+iZClFaN/Nxv+BlvATED+8A3sk6iMGSxLjvprHshGnmE\n3aPE5zOIYH9VZqZl63mFYicCgYEAnixheCgSg8mYvCh3HJsRUIqWvB1SVo87riwD\nhiNjRqKXxq8uwdl2YyXyiafV6ZksDmX7uZVZFaWBeayXxdrI2Nq/MKK2R3bH9uDg\nd9bWFKmL4EOi+MX8lmkTCiPnDf5IXbWAXnIfQz/1mwk9ivZfQslk4tE4MJ5urS/A\nXaZKiEMCgYAomb+JfhnqEIWxJNKXkNUV/mdj2K3mLM3J7CY/j7JMOdfgqPip15+S\ndy14x7Cw2E6lTXNbAlchrByf5gT41Iv4RGUynlxzgQRZqxEX3xjJHZAiSAQi3HZO\nYsenTMXg+2vbat7ahMszC5oxDdMkmOA+ptw5Ic1F2tunY6Cv1kaFsA==\n-----END RSA PRIVATE KEY-----\n"
    },
    "code": 0
}
```

**text_key_pair.lua接口:rsa秘钥对签发（返回值为text/html格式）**

该接口引用了rsa.lua以及response_result.lua，进行随机rsa秘钥对的签发，可以直接作为接口在openresty中进行location配置调用

* location配置

```conf
content_by_lua_file text_key_pair.lua;
```

* 接口源码

```lua
local response_result = require "response_result"
local rsa = require "rsa"

local rsa_public_key, rsa_priv_key, err = rsa:generate_rsa_keys(2048)
if not rsa_public_key then
    ngx.log(ngx.ERR, '秘钥对签发失败:' , err)
    ngx.say(response_result.err(nil, "秘钥对签发失败"))
    ngx.exit(ngx.OK)
end

ngx.header.content_type = "text/html; charset=utf-8"
ngx.say(rsa_public_key)
ngx.say(rsa_priv_key)
ngx.exit(ngx.OK)
```

* 响应结果

**注意：序列化后会带换行符**

```text
-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEA7TcyWx1/JtI5Kf1IDq9E1bSh9KkXYvRWoVahsQ2O14dUukOyPXdb
TReMW217IBU11SL7cONffTXlkWXg/rfTlHeTAPun2zc5xVUqjh3EDFNMnI1bhDn5
/VrjB77nEKoRojlRJDO6b2myhhwEMUaF54dkXdRt599WsOxtuB5BUHA0WbqImFEC
b8aXzQvkn5K+g4W6D4jKJtv5Irij+V3K2GpovCLNYle+47uaA75g8eBdTx03MsMd
ocIZS2VrrUWD7c7Ybn2I5x/o2QoIuxjrrWNc5trz2/NI8va9Wqrisg7CjZeIz3OY
zTPTFONkM7t/TEEkEtRu72Auu1GGxYwQMwIDAQAB
-----END RSA PUBLIC KEY-----

-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA7TcyWx1/JtI5Kf1IDq9E1bSh9KkXYvRWoVahsQ2O14dUukOy
PXdbTReMW217IBU11SL7cONffTXlkWXg/rfTlHeTAPun2zc5xVUqjh3EDFNMnI1b
hDn5/VrjB77nEKoRojlRJDO6b2myhhwEMUaF54dkXdRt599WsOxtuB5BUHA0WbqI
mFECb8aXzQvkn5K+g4W6D4jKJtv5Irij+V3K2GpovCLNYle+47uaA75g8eBdTx03
MsMdocIZS2VrrUWD7c7Ybn2I5x/o2QoIuxjrrWNc5trz2/NI8va9Wqrisg7CjZeI
z3OYzTPTFONkM7t/TEEkEtRu72Auu1GGxYwQMwIDAQABAoIBAETb0PJCDbbnL1DR
BSm+Fu0yEhFDRFalNsB+tVD/7ocB8cZgAE13aDlorIWdsjAN+CJ2lSaf2ggurQUX
3cgS9IgUbcfLRV6NGWf+4OuAGHi7dXG8VuR7L+Yri9ujvs9HjvbYTIWFvoi41em4
GD91iUk8NBZIo967Jh8VgoP/xFXkrTLGiYWqtqdV6je4Ycy2slHp87wiGJSQtTXr
vSqRPrJU0+msxEZktcrtkNidVY5ooK7xPI28VJiMHJR5tYBYHRke/D69QuDz12zk
IpLg0lroCDGSq14BwF7F1VWFfQ1vJ8FFVQKHoPI1CNmjBOXcwMO00xo+gGLFQJSL
yJi22oECgYEA/A+P9lUDsDLIylXyjB+Hacnf2/xhbJW2XVDHz+8HxDTy+Tzzluwd
ko3EDOGk03de/VrCYdYBa0jjvLLxc5PmsevA4l0p8wAVQRafaEySxpYE+QBIDyc9
HXnkDEoUlIR17O/H3i7wnvD3x5HyWP4/K22HGMWi1JpXtEnjmx5b3Z0CgYEA8Ow9
/7Ce+Nu4BbEyaJRiU/ahRR/+ZMw7OR7K5Ii+HB8BXQAk59UOhGa3Ozu+7trFo6yh
uuS2CelUfwlnj/h15IH/5N+tj+Xf6WsPxjs8OWM7eAKiAYxFzSlTcZybOQnoNn+1
GWeAIVgrv4aoSiyix0S1AB48OaRn0G8cJG8AJA8CgYEA9mVAFUyFjngWT7Q0pUUs
2fy9GA5eLgcrfYy5xkmjDem0mm86rw2g2uI6A12QAiduc7uEyJ6qRHW8KXnDDXhG
yyXqJ11q5F/wZu/2Y752vClqMv5TcnypAWdlxZ2lAIl7vWGnv0mjbbugezXv8Y6X
sZwfs9d+lNVLZrHUDI5gvwECgYEAz8SMOyNQFYE2lAIaXMIKgiphLcHHm5ndQQdj
Je8fNBUxEcj8CspceKY0Qmrl4ArfAqXv28M9khKdAelUXH6C/Qt3aSPVBBHUJfJk
ainPaBZBxN9QY1FbKPEIuyO5YVk/3zAHN99gSmFFaShxnXYc8wg3p+BrQ7KarNAF
Tw5C6tUCgYAgGngW1UBrQ/TREp7MCCDMCBE09f+jhytlsnT9RC052qzfUk72HFXJ
K+4/FQrR8RM1FH/DP09KQkzhOtxmhvYiwMEFGK8AsOff3WJTP5ju1q9ueKPKsFro
XTg8J93svQt767HY1lEvXsmf5EVrFTJuX9CUhUPiuaBR7OuSLjQGCw==
-----END RSA PRIVATE KEY-----
```