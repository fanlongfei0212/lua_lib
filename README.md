# OpenResty中lua常用类库以及组件整理

* **对常用组件的使用记录整理以及描述**

* **对常用类库以及自己编写类库的整理以及描述**

* **类库使用的demo以及官方文献的资源链接**

Table of Contents
=================

* [Components](#组件)
    * [lua-redis-parser](#lua-redis-parser)
    * [redis2-nginx-module](#redis2-nginx-module)
* [lualib](#类库)
    * [dkjson](#dkjson)
    * [rsa](#rsa)
    * [common_uitl](#common_util)
    * [request_args](#request_args)

Components
==========

常用组件

lua-redis-parser
----------------

1. [官方文献](https://github.com/openresty/lua-redis-parser#parse_reply) 

2. 主要作用
    * 将lua中的table格式的redis命令转化成redis的原生命令
    * 将redis返回的原生命令解析为lua中table
    * 以及其他，详细信息可查阅官方文献

redis2-nginx-module
-------------------

1. [官方文献](https://github.com/openresty/redis2-nginx-module) 

2. 主要作用
    * 支持在OpenResty中lua对redis的各种操作
    * 详细信息可查阅官方文献

[Back to TOC](#table-of-contents)

lualib
======

常用类库

dkjson
------

1. [官方文献](http://dkolf.de/src/dkjson-lua.fsl/home) 

2. 主要作用
    * 可以将lua的table转换为json格式(encode函数)
    * 可以将json格式的数据解析为lua中的table格式(decode函数)
    * 详细信息可查阅官方文献

[Back to TOC](#table-of-contents)

rsa
---

1. [官方文献](https://github.com/spacewander/lua-resty-rsa) 

2. 主要作用
    * 生成rea公钥、私钥对
    * 用于对数据的rsa加密以及解密
    * 详细信息可查阅官方文献

[Back to TOC](#table-of-contents)

common_util
-----------

1. lua实现的一些常用工具类

2. demo

[Back to TOC](#table-of-contents)

request_args
------------

1. lua实现获取请求中的参数

2. demo

[Back to TOC](#table-of-contents)