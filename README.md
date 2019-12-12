# OpenResty中lua常用类库以及组件整理

* **对常用组件的使用记录整理以及描述**

* **对常用类库以及自己编写类库的整理以及描述**

* **类库使用的demo以及官方文献的资源链接**

Table of Contents
=================

* [Components](#Components)
    * [lua-redis-parser](#lua-redis-parser)
    * [redis2-nginx-module](#redis2-nginx-module)
* [Lualib](#Lualib)
    * [dkjson](#dkjson)
    * [rsa](#rsa)
    * [common_uitl](#common_util)
    * [request_args](#request_args)

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

在OpenResty中常用的lua类库:针对lua和json之间的序列化以及反序列化类库、rsa加密类库、获取get请求以及post中的参数、字符串的分割返回table、数组去重等等

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

lua实现获取请求中的参数

```lua
```

[Back to TOC](#table-of-contents)