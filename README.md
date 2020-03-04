# OpenResty中lua常用类库以及组件整理

* **MyLuaInterface**编写的常用lua接口

* **MyLualib**编写的常用lua类库

* **Components**是对常用组件的使用记录整理以及描述

* **Lualib**是已有的第三方类库资源整理

Table of Contents
=================

* [MyLuaInterface](#MyLuaInterface)
    * [基于rsa的秘钥对签发接口](#基于rsa的秘钥对签发接口)
* [MyLualib](#MyLualib)
    * [request_args](#request_args)
    * [request_header](#request_header)
    * [request_cookie](#request_cookie)
    * [response_result](#response_result)
    * [common_uitl](#common_util)
    * [redis_util](#redis_util)
    * [redis_db_util](#redis_db_util)
* [Components](#Components)
    * [lua-redis-parser](#lua-redis-parser)
    * [redis2-nginx-module](#redis2-nginx-module)
* [Lualib](#Lualib)
    * [dkjson](#dkjson)
    * [rsa](#rsa)
    * [lua-resty-cookie](#lua-resty-cookie)

MyLuaInterface
========

**常用lua接口**

基于rsa的秘钥对签发接口
-------------------

### 概要

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/rsa/?.lua;;";
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
lua_package_path "/path/to/lua_lib/lib/json/?.lua;;";
```

此lua接口依赖本项目中**response_result.lua**类库以及第三方的**lua-resty-rsa**（在本项目中的lib/rsa中）、**dkjson**（在本项目中的lib/json中），需要把**response_result.lua**和**rsa.lua**、**dkjson.lua**同时加入到lua_package_path中才能使用

---

**json_key_pair.lua接口:rsa秘钥对签发（返回值为json格式）,秘钥对签发使用PKCS8格式**

该接口引用了rsa.lua以及response_result.lua，进行随机rsa秘钥对的签发，可以直接作为接口在OpenResty中进行location配置调用

* location配置

```conf
location /rsa/json/keyPair {
    content_by_lua_file /path/to/lua_lib/interface/json_key_pair.lua;
}
```

* 接口源码

```lua
local response_result = require "response_result"
local rsa = require "rsa"

local isPKCS8 = true;
local rsa_public_key, rsa_priv_key, err = rsa:generate_rsa_keys(2048, isPKCS8)
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
        "publicKey": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvkpv8os9IcBlLS2riI+k\nM6BW7LoCijd6nSWFIdeWYNDIP2DcqcgPBrqWESwe1pUMlsHJR9L2yV3DxPzLymM3\nlVT24Qgrzw70sB2uLAiJcoHpyytt+soDt2/rjLwxQS9C1X7Imd7fRqI+46znFfbR\n9mTXngDR1dB66nBxMI907fmSeTpT+gWXx7So/TIwN/6p/PgD+UrJsbVlwQ/4o0/W\nGgitfTiHBk/rACUBzg/E8qiKbmMNypNtNx3flqzgs3l5QVEXq17FDphDQsWNKmiK\nM9GgqBqeVUF+AHfcMTHwZI94oibhtsNqkoMVEDkDHGeNcd1Y/bqBiZvLKQloOdMR\nZwIDAQAB\n-----END PUBLIC KEY-----\n",
        "privateKey": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC+Sm/yiz0hwGUt\nLauIj6QzoFbsugKKN3qdJYUh15Zg0Mg/YNypyA8GupYRLB7WlQyWwclH0vbJXcPE\n/MvKYzeVVPbhCCvPDvSwHa4sCIlygenLK236ygO3b+uMvDFBL0LVfsiZ3t9Goj7j\nrOcV9tH2ZNeeANHV0HrqcHEwj3Tt+ZJ5OlP6BZfHtKj9MjA3/qn8+AP5SsmxtWXB\nD/ijT9YaCK19OIcGT+sAJQHOD8TyqIpuYw3Kk203Hd+WrOCzeXlBURerXsUOmENC\nxY0qaIoz0aCoGp5VQX4Ad9wxMfBkj3iiJuG2w2qSgxUQOQMcZ41x3Vj9uoGJm8sp\nCWg50xFnAgMBAAECggEADLY4SEGY8dpCaAQ3A0ZlN7WsWOAML2OJY1oQTLR0LT+F\nQQaddxIQPujUAY2q+ba3QpLreUrUhZsn6s7gZkK+gdFNNLcxBgH/wowZCIQBeo7H\nKXVbQXehS+3EFIC14Z7gnhZ8HBtRWwyXmun//e2hFQ6jgMCZQ+lLbMHaLd5Hd2Yp\nLabV//OSDkFfPRWifpYDAGToHPMRAEJmCQ+GpBO+flpyamTr5Ll9D3FGxIzl+WQU\nml+tMPjL/7HJSRH21aF4gSK9RDjbXA2viQRymDtmU5W/VhKuYDSCii751V2FUkBi\nji5paK2bKsyHXGh7Uy288USpJTPVFouczwk9bbqzIQKBgQDh4howKe1xJzRUPPQd\nRgYTYdxB3vuTdEJmwAW2RTPgJ7OjrcjbsbX2JhlJm664Q8wbt22wtPES86NmrsxW\npasyrrUIWPodqH7vQbgf7QkAmvV4h0IcxFLgN1E0eMJ60AR69JpyVyO83cNZfQ03\nwRqJvtctQGZ/o70tVEOjzKKAGQKBgQDXqXxQyr1mBe3TB0vIFdg3vK2QLJnx3VpN\ngg9OM95LqgDKYAXuXNLsQpPzu9AerRqITMDDJHzBYiGmsw9w7wfObmZbZiZ2Oi6j\nBSWKb+UtRGs/aVpK5kCrqXx+iOAKWhX+0HWncezfnovqTKkPypLTVz4qOiv+e/2H\nVtD3l95NfwKBgQCwVmyPUQv2G970LCl+eN3hX7ItEkBfmpED2cAbzOZ0hUnt64s0\nRwWARbnUBt9dJkA/GvFc08SnQOA9FxSaR/bgOBdHjv6jDJkberic49T1TgN3tk/c\nWT9Bnq2cQvHAIoh83Ft+C5zwokcQo1kgP3XSNtOQlgfueQsEShYL14K8cQKBgQCP\nvZ5nNwoP0wnVqro+zRiE5dQFEUU2KOQEXxiWdgnHArNuL5wkaGgJIsL8JAUuPRA/\nInEkX9BrEF3/fr9e9WKNm5XLe4VNLbBh5Y9E+xmUF1MoO6771wXppJieudoh7DNW\n2Fhi15Ma5NC6xIe2R72e8To06Prjrn6n0xyKugVoPwKBgQCPe8P6Ame36vxL5mWF\nPif9znvI9r09KX0zlmb0EDSw9DKC1r9CJnb40JjF0qg3PRDkMUJ0ulD792Le/2Dw\nmsqLiJMIhjjGXGKw8A+rhD1gkgUsqgGQApXqA/cirWOdDLT/QLifzV0wReAgAWNF\nC6n1ywtsqjqmYWUFTZ8UA+RCeQ==\n-----END PRIVATE KEY-----\n"
    },
    "code": 0
}

```

**text_key_pair.lua接口:rsa秘钥对签发（返回值为text/html格式）,秘钥对签发使用PKCS8格式**

该接口引用了rsa.lua以及response_result.lua，进行随机rsa秘钥对的签发，可以直接作为接口在OpenResty中进行location配置调用

* location配置

```conf
location /rsa/text/keyPair {
    content_by_lua_file /path/to/lua_lib/interface/text_key_pair.lua;
}
```

* 接口源码

```lua
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
```

* 响应结果

```text
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA26+HZF10FkQfkYAClmzE
foZeMDYJJRgvEHe2DoUnoVX+LjrTtjqkb9yGEnCW6N9IoC5AZm5hbEifaXMuJs0z
38S8oaKvWvVGGC5rCxWrWKlJFBIwlgShW+7fdOwqVc7/CzD68oVcyIzXYgOT2Lka
WYQ2cnIi0KMd3kFbAjzDgn6DpxbPsshpy8LJaY5a3mkVIgwSvweCNPaKbkEEFGqp
PI1zNq/zP7CEm6rkNvwn50WaaK+rmmQx38cjJ6zNhgT9oqGXBEQkeFpztMbebOkD
x+HXKoBGCbAy3qpXSyy8svnAzFxvqwHRRHn6Cit6HCsULqIKOi6XyUqVpXFCFOex
6QIDAQAB
-----END PUBLIC KEY-----

-----BEGIN PRIVATE KEY-----
MIIEwAIBADANBgkqhkiG9w0BAQEFAASCBKowggSmAgEAAoIBAQDbr4dkXXQWRB+R
gAKWbMR+hl4wNgklGC8Qd7YOhSehVf4uOtO2OqRv3IYScJbo30igLkBmbmFsSJ9p
cy4mzTPfxLyhoq9a9UYYLmsLFatYqUkUEjCWBKFb7t907CpVzv8LMPryhVzIjNdi
A5PYuRpZhDZyciLQox3eQVsCPMOCfoOnFs+yyGnLwslpjlreaRUiDBK/B4I09opu
QQQUaqk8jXM2r/M/sISbquQ2/CfnRZpor6uaZDHfxyMnrM2GBP2ioZcERCR4WnO0
xt5s6QPH4dcqgEYJsDLeqldLLLyy+cDMXG+rAdFEefoKK3ocKxQuogo6LpfJSpWl
cUIU57HpAgMBAAECggEBANKFY/aPA9buk13oURJ7ytUAyLPkpGDSyw852NITUgXu
lTUSFJ31lmzH5Ac5s7QXfM5bZEWEk4GkGnd/9AMk9AgEzUsLzoUYtIIpwVSPAHNn
TmuYfszURRkHUUYHpw4x3gCIgIL1wBNDvIblrMGrqI+N/msv6yMKnW3GLYN4XVbn
RZeDWgZv/W8gcz5L00ioWkf4al6K+bpjogBid65mhrZt9N6Mtdec+ms91I/U2aDd
4JNV80opvhkd2PAjluLCSQSNnoquikrd7rz4jCaoWMp/AHLU3KZjpB7R5Hsk43Vk
prr/T78YK9FkPh4iSP5ULqisoCLGrSfNbLFcz2c9m7ECgYEA7YZRk7wdd+iHFHq9
95+mi0oS1HsIEUOAGwTMWQFx6Dsdy3w1imdurlRQLQ6yHh5IvAzul4PIRaC6/YVd
7jdCwBoGJPnD+W6/LNYGFOA63ntZP4ORDuU/SAMtbp8j9rKwfM0TuTy6IAlvNNdC
J9U0z3LwimIszCSyJAhSXm8ip+0CgYEA7MX+Kz9sqh/+fg0qWARo+LU2clHA84te
IY5DIzrcZSO9Mj2zv5cBZ18dHbu0ZtawpSwIE2pPd8Sx/yeFgH87kQHq5Ba/2e5S
yFT0ZWQ1ltCPSB8MNS00LODaKfDKbt3FsTm7qNW6J0fAZKfccresX96JL6iQfyiV
9qN6QD00um0CgYEA7KEl4DJGgVDMUeC+JFWOy7Ft9PTk4p4Gn+Q12G4SFrPeSPxj
MpE8uLwSa/D6DftJpt6TS6rj+EnaP/t/ynSPMWY7vNZ/IJ3uIzLNODrzKvZjwVzH
RLmqQ4m21z//yiPWo16DScVv/76mZVQV+izzwb/WV2bbDj14o2EO/jllozkCgYEA
u9hQz8rf0RDU/PhA8dd92GMcMRI/PHkDUyfkh9y44dy6y1M8efG5gWNqXB6A/12w
gzotpgmfxmtctAuM1OccQOz+h7qstp9nOdx8kLwx79bC9fr72mxkin5RVxjb4Z08
rGAbS9VUfLlmH/U05iZmMSECQbc//EIcx7Hm2XQ1kvkCgYEAnnSCl+nY5HVkKU+5
6MSfoPkMJwPK+Hb0UtGDWFdfSX5wm5TSohBzuNthong4SMUImmKYJOaMuj1du6sw
ZQlW7CFvd1G3k0Pw3lis6KHOov/cIaES2oBPu/+hR1KrjSQ10Ixa/3qjAnyaftcy
drNLRsBmwYGgBK0pKVgl/fE/998=
-----END PRIVATE KEY-----
```

**java加密，lua解密**

项目中将数据在Java中进行加密，在OpenResty中使用lua进行解密；在此提供Java中需要的工具类

* Java和lua使用的同一秘钥对

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA26+HZF10FkQfkYAClmzE
foZeMDYJJRgvEHe2DoUnoVX+LjrTtjqkb9yGEnCW6N9IoC5AZm5hbEifaXMuJs0z
38S8oaKvWvVGGC5rCxWrWKlJFBIwlgShW+7fdOwqVc7/CzD68oVcyIzXYgOT2Lka
WYQ2cnIi0KMd3kFbAjzDgn6DpxbPsshpy8LJaY5a3mkVIgwSvweCNPaKbkEEFGqp
PI1zNq/zP7CEm6rkNvwn50WaaK+rmmQx38cjJ6zNhgT9oqGXBEQkeFpztMbebOkD
x+HXKoBGCbAy3qpXSyy8svnAzFxvqwHRRHn6Cit6HCsULqIKOi6XyUqVpXFCFOex
6QIDAQAB
-----END PUBLIC KEY-----

-----BEGIN PRIVATE KEY-----
MIIEwAIBADANBgkqhkiG9w0BAQEFAASCBKowggSmAgEAAoIBAQDbr4dkXXQWRB+R
gAKWbMR+hl4wNgklGC8Qd7YOhSehVf4uOtO2OqRv3IYScJbo30igLkBmbmFsSJ9p
cy4mzTPfxLyhoq9a9UYYLmsLFatYqUkUEjCWBKFb7t907CpVzv8LMPryhVzIjNdi
A5PYuRpZhDZyciLQox3eQVsCPMOCfoOnFs+yyGnLwslpjlreaRUiDBK/B4I09opu
QQQUaqk8jXM2r/M/sISbquQ2/CfnRZpor6uaZDHfxyMnrM2GBP2ioZcERCR4WnO0
xt5s6QPH4dcqgEYJsDLeqldLLLyy+cDMXG+rAdFEefoKK3ocKxQuogo6LpfJSpWl
cUIU57HpAgMBAAECggEBANKFY/aPA9buk13oURJ7ytUAyLPkpGDSyw852NITUgXu
lTUSFJ31lmzH5Ac5s7QXfM5bZEWEk4GkGnd/9AMk9AgEzUsLzoUYtIIpwVSPAHNn
TmuYfszURRkHUUYHpw4x3gCIgIL1wBNDvIblrMGrqI+N/msv6yMKnW3GLYN4XVbn
RZeDWgZv/W8gcz5L00ioWkf4al6K+bpjogBid65mhrZt9N6Mtdec+ms91I/U2aDd
4JNV80opvhkd2PAjluLCSQSNnoquikrd7rz4jCaoWMp/AHLU3KZjpB7R5Hsk43Vk
prr/T78YK9FkPh4iSP5ULqisoCLGrSfNbLFcz2c9m7ECgYEA7YZRk7wdd+iHFHq9
95+mi0oS1HsIEUOAGwTMWQFx6Dsdy3w1imdurlRQLQ6yHh5IvAzul4PIRaC6/YVd
7jdCwBoGJPnD+W6/LNYGFOA63ntZP4ORDuU/SAMtbp8j9rKwfM0TuTy6IAlvNNdC
J9U0z3LwimIszCSyJAhSXm8ip+0CgYEA7MX+Kz9sqh/+fg0qWARo+LU2clHA84te
IY5DIzrcZSO9Mj2zv5cBZ18dHbu0ZtawpSwIE2pPd8Sx/yeFgH87kQHq5Ba/2e5S
yFT0ZWQ1ltCPSB8MNS00LODaKfDKbt3FsTm7qNW6J0fAZKfccresX96JL6iQfyiV
9qN6QD00um0CgYEA7KEl4DJGgVDMUeC+JFWOy7Ft9PTk4p4Gn+Q12G4SFrPeSPxj
MpE8uLwSa/D6DftJpt6TS6rj+EnaP/t/ynSPMWY7vNZ/IJ3uIzLNODrzKvZjwVzH
RLmqQ4m21z//yiPWo16DScVv/76mZVQV+izzwb/WV2bbDj14o2EO/jllozkCgYEA
u9hQz8rf0RDU/PhA8dd92GMcMRI/PHkDUyfkh9y44dy6y1M8efG5gWNqXB6A/12w
gzotpgmfxmtctAuM1OccQOz+h7qstp9nOdx8kLwx79bC9fr72mxkin5RVxjb4Z08
rGAbS9VUfLlmH/U05iZmMSECQbc//EIcx7Hm2XQ1kvkCgYEAnnSCl+nY5HVkKU+5
6MSfoPkMJwPK+Hb0UtGDWFdfSX5wm5TSohBzuNthong4SMUImmKYJOaMuj1du6sw
ZQlW7CFvd1G3k0Pw3lis6KHOov/cIaES2oBPu/+hR1KrjSQ10Ixa/3qjAnyaftcy
drNLRsBmwYGgBK0pKVgl/fE/998=
-----END PRIVATE KEY-----
```

* Java公钥加密

**示例代码假设是调用lua的rsa秘钥签发接口后，存储至数据库，然后从数据库中查出公钥**

**项目提供RsaUtil的Java工具类以及Base64Util的Java工具类**

**秘钥格式PKCS8**

**Java的RsaUtil和Base64Util的源码可在项目中自行查看**

```java
public static void main(String[] args) throws Exception {
    Map<String, String> map = new HashMap<>();
    map.put("public",
            "-----BEGIN PUBLIC KEY-----\n" +
            "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA26+HZF10FkQfkYAClmzE\n" +
            "foZeMDYJJRgvEHe2DoUnoVX+LjrTtjqkb9yGEnCW6N9IoC5AZm5hbEifaXMuJs0z\n" +
            "38S8oaKvWvVGGC5rCxWrWKlJFBIwlgShW+7fdOwqVc7/CzD68oVcyIzXYgOT2Lka\n" +
            "WYQ2cnIi0KMd3kFbAjzDgn6DpxbPsshpy8LJaY5a3mkVIgwSvweCNPaKbkEEFGqp\n" +
            "PI1zNq/zP7CEm6rkNvwn50WaaK+rmmQx38cjJ6zNhgT9oqGXBEQkeFpztMbebOkD\n" +
            "x+HXKoBGCbAy3qpXSyy8svnAzFxvqwHRRHn6Cit6HCsULqIKOi6XyUqVpXFCFOex\n" +
            "6QIDAQAB\n" +
            "-----END PUBLIC KEY-----"
    );
    String uid = "测试数据";
    String eUid = RsaUtil.publicEncrypt(uid, map.get("public"));
    System.out.println(eUid);
}
```

```text
mIB22N5eLokGQRtLSNzZ/wuXnKZhmBmRhIitcluBAn+yCayyEio/IBADzlT4muBkpW11ljdjsXUZfSHp/YAKbmJXV0Da9zCN593KK3Bob5o2Q7T5EK/N7jPIR5mXj1ZAtLosWq7+JFiQ/6LonVMuKbJDZYmfUDlxmYHXCrd1miFAwpsj3VVnCcd7xh0yswWfVN2XK7PdiaDOB3s5XqQ97lJPLDlUjNL4Dw3vWg9JJI48gvo3bO0JHt4WhvFGrr+Ho79/m5cNq5h+pB0WhDnzSOagMVtaAls1abgaOOxPE9Cjp7WLDiWdFFnnU93XHS03vKb2uC0RFQ+sRFElrtXGVQ==
```

* lua私钥解密

**示例代码假设是调用lua的rsa秘钥签发接口后，存储至数据库，然后从数据库中查出私钥**

```lua
local rsa = require "rsa"

local private_key = [[-----BEGIN PRIVATE KEY-----
MIIEwAIBADANBgkqhkiG9w0BAQEFAASCBKowggSmAgEAAoIBAQDbr4dkXXQWRB+R
gAKWbMR+hl4wNgklGC8Qd7YOhSehVf4uOtO2OqRv3IYScJbo30igLkBmbmFsSJ9p
cy4mzTPfxLyhoq9a9UYYLmsLFatYqUkUEjCWBKFb7t907CpVzv8LMPryhVzIjNdi
A5PYuRpZhDZyciLQox3eQVsCPMOCfoOnFs+yyGnLwslpjlreaRUiDBK/B4I09opu
QQQUaqk8jXM2r/M/sISbquQ2/CfnRZpor6uaZDHfxyMnrM2GBP2ioZcERCR4WnO0
xt5s6QPH4dcqgEYJsDLeqldLLLyy+cDMXG+rAdFEefoKK3ocKxQuogo6LpfJSpWl
cUIU57HpAgMBAAECggEBANKFY/aPA9buk13oURJ7ytUAyLPkpGDSyw852NITUgXu
lTUSFJ31lmzH5Ac5s7QXfM5bZEWEk4GkGnd/9AMk9AgEzUsLzoUYtIIpwVSPAHNn
TmuYfszURRkHUUYHpw4x3gCIgIL1wBNDvIblrMGrqI+N/msv6yMKnW3GLYN4XVbn
RZeDWgZv/W8gcz5L00ioWkf4al6K+bpjogBid65mhrZt9N6Mtdec+ms91I/U2aDd
4JNV80opvhkd2PAjluLCSQSNnoquikrd7rz4jCaoWMp/AHLU3KZjpB7R5Hsk43Vk
prr/T78YK9FkPh4iSP5ULqisoCLGrSfNbLFcz2c9m7ECgYEA7YZRk7wdd+iHFHq9
95+mi0oS1HsIEUOAGwTMWQFx6Dsdy3w1imdurlRQLQ6yHh5IvAzul4PIRaC6/YVd
7jdCwBoGJPnD+W6/LNYGFOA63ntZP4ORDuU/SAMtbp8j9rKwfM0TuTy6IAlvNNdC
J9U0z3LwimIszCSyJAhSXm8ip+0CgYEA7MX+Kz9sqh/+fg0qWARo+LU2clHA84te
IY5DIzrcZSO9Mj2zv5cBZ18dHbu0ZtawpSwIE2pPd8Sx/yeFgH87kQHq5Ba/2e5S
yFT0ZWQ1ltCPSB8MNS00LODaKfDKbt3FsTm7qNW6J0fAZKfccresX96JL6iQfyiV
9qN6QD00um0CgYEA7KEl4DJGgVDMUeC+JFWOy7Ft9PTk4p4Gn+Q12G4SFrPeSPxj
MpE8uLwSa/D6DftJpt6TS6rj+EnaP/t/ynSPMWY7vNZ/IJ3uIzLNODrzKvZjwVzH
RLmqQ4m21z//yiPWo16DScVv/76mZVQV+izzwb/WV2bbDj14o2EO/jllozkCgYEA
u9hQz8rf0RDU/PhA8dd92GMcMRI/PHkDUyfkh9y44dy6y1M8efG5gWNqXB6A/12w
gzotpgmfxmtctAuM1OccQOz+h7qstp9nOdx8kLwx79bC9fr72mxkin5RVxjb4Z08
rGAbS9VUfLlmH/U05iZmMSECQbc//EIcx7Hm2XQ1kvkCgYEAnnSCl+nY5HVkKU+5
6MSfoPkMJwPK+Hb0UtGDWFdfSX5wm5TSohBzuNthong4SMUImmKYJOaMuj1du6sw
ZQlW7CFvd1G3k0Pw3lis6KHOov/cIaES2oBPu/+hR1KrjSQ10Ixa/3qjAnyaftcy
drNLRsBmwYGgBK0pKVgl/fE/998=
-----END PRIVATE KEY-----]]

local uid = "mIB22N5eLokGQRtLSNzZ/wuXnKZhmBmRhIitcluBAn+yCayyEio/IBADzlT4muBkpW11ljdjsXUZfSHp/YAKbmJXV0Da9zCN593KK3Bob5o2Q7T5EK/N7jPIR5mXj1ZAtLosWq7+JFiQ/6LonVMuKbJDZYmfUDlxmYHXCrd1miFAwpsj3VVnCcd7xh0yswWfVN2XK7PdiaDOB3s5XqQ97lJPLDlUjNL4Dw3vWg9JJI48gvo3bO0JHt4WhvFGrr+Ho79/m5cNq5h+pB0WhDnzSOagMVtaAls1abgaOOxPE9Cjp7WLDiWdFFnnU93XHS03vKb2uC0RFQ+sRFElrtXGVQ=="

local priv, err = rsa:new({ private_key = private_key, key_type = rsa.KEY_TYPE.PKCS8 })

if not priv then
    ngx.log(ngx.ERR, "解密失败：", "秘钥错误")
    ngx.log(ngx.ERR, "err", err)
    ngx.say("解密失败，伪造的密文")
    ngx.exit(ngx.OK)
end

local data = priv:decrypt(ngx.decode_base64(uid))
ngx.say(data)
ngx.exit(ngx.OK)
```

```text
测试数据
```

[Back to TOC](#table-of-contents)

MyLualib
========

**编写的常用类库**

request_args
------------

### 概要

request_args用于获取url、body中的请求参数

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
lua_package_path "/path/to/lua_lib/lib/json/?.lua;;";
```

此类库依赖本项目中**common_util.lua**以及第三方的**dkjson**（在本项目中的lib/json中），如果只需要使用**request_args.lua**类库，也需要把**dkjson.lua**和**common_util.lua**、**request_args.lua**同时加入到lua_package_path中才能使用

---

**获取请求中url参数值**

调用函数:get_args_by_name(arg_names)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| arg_names | table | 是 | 要获取的参数名称的数组table | 必须是数组table，不可以是对象table |

示例:

* 假设请求url:http://localhost:8888/request/args/demo?parameter1=参数1的值&parameter2=参数2的值

```lua
local request_args = require "request_args"

local args_names = {"parameter1", "parameter2"}
local args_values = request_args.get_args_by_name(args_names)

for k, v in pairs(args_values) do
    ngx.say("get请求中参数-->" .. k .. "的值:" .. v);
end
```

```text
get请求中参数-->parameter1的值:参数1的值
get请求中参数-->parameter2的值:参数2的值
```

**获取请求中body参数值(form表单)**

调用函数:post_args_by_name(arg_names)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| arg_names | table | 是 | 要获取的参数名称的数组table | 必须是数组table，不可以是对象table |

示例:

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

```text
post请求中参数-->parameter1的值:参数1的值
post请求中参数-->parameter2的值:参数2的值
```

**获取请求中body参数值(json格式)**

调用函数:json_args_by_name()

参数列表:无

示例:

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

```text
post请求中参数-->parameter1的值:参数1的值
post请求中参数-->parameter2的值:参数2的值
```

[Back to TOC](#table-of-contents)

request_header
--------------

### 概要

request_header用于针对请求头的获取、修改、清除

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
```

此类库依赖本项目中**common_util.lua**类库，如果只需要使用**request_header.lua**类库，也需要把**common_util.lua**和**request_header.lua**同时加入到lua_package_path中才能使用

---

**获取请求头中所有的值**

调用函数:get_header_all()

参数列表:无

示例:

* 假设请求url:http://localhost:8888/common/request_header/demo

```lua
local request_header = require "request_header"

local result = request_header.get_header_all()
if result then
    for k, v in pairs(result) do
        if type(v) == "table" then
            ngx.say(k .. ":" .. table.concat( v, "," ))
        else
            ngx.say(k .. ":" .. v)
        end
    end
end
```

```text
host:localhost:8888
connection:keep-alive
sec-fetch-site:cross-site
sec-fetch-mode:cors
accept-encoding:gzip, deflate, br
user-agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36
accept:*/*
cookie:_ga=GA1.1.515272813.1557485115; JSESSIONID=B3A27B8FB81DA40A0773EAAD67ABC35E
accept-language:zh-CN,zh;q=0.9
```

**获取请求头中指定的值**

调用函数:get_header(arg_table)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| arg_table | table | 是 | 要获取的请求头名称的数组table | 必须是字符串数组table，不可以是对象table |

示例:

* 假设请求url:http://localhost:8888/common/request_header/demo

* 添加请求头:

```text
text1:1
text2:2
```

```lua
local request_header = require "request_header"

local args = {"text1", "text2"}
local result = request_header.get_header(args)
if result then
    for k, v in pairs(result) do
        if type(v) == "table" then
            ngx.say(k .. ":" .. table.concat( v, "," ))
        else
            ngx.say(k .. ":" .. v)
        end
    end
end
```

```text
text1:1
text2:2
```

**添加请求头**

调用函数:set_header(args, is_replace)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| args | table | 是 | 要添加的请求头名称以及所对应值的对象table | 必须是对象table，属性的值可以是数组，但不能是对象 |
| is_replace | boolean | 否 | 如果请求头中存在相同的值参数,是否进行值替换(true-->替换 false-->保留原值) | 不传或传nil以及非boolean参数则默认为false |

示例:

在nginx接收到请求之后，需要进行调用子请求并且需要添加请求头让子请求可以获取到时使用，可以同时设置多个；并且在设置请求头时如果设置的请求头中包含原请求头中已经存在的值，可以选择进行替换或者不替换，替换则将相同的请求头内容进行更新，不替换则保留相同请求头中之前的内容；成功返回ture，失败返回false

* 假设请求url:http://localhost:8888/common/request_header/demo

* 假设子请求url:/common/request_header/demo/capture

* 原始请求头中数据:

```text
true
host:localhost:8888
connection:keep-alive
sec-fetch-site:cross-site
accept:*/*
accept-language:zh-CN,zh;q=0.9
test_2:test_2
accept-encoding:gzip, deflate, br
user-agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36
test1:test1
cookie:_ga=GA1.1.515272813.1557485115; JSESSIONID=B3A27B8FB81DA40A0773EAAD67ABC35E
test3:test3_1,test3_2
sec-fetch-mode:cors
```

* 设置请求头与原请求头中出现相同时不替换相同的内容

调用的子请求(**ngx.location.capture("/common/request_header/demo/capture")**)中的操作就是获取所有的请求头内容，以此验证设置请求头是否成功

```lua
local request_header = require "request_header"

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
```

```text
true
host:localhost:8888
connection:keep-alive
sec-fetch-site:cross-site
accept:*/*
accept-language:zh-CN,zh;q=0.9
test_2:test_2
accept-encoding:gzip, deflate, br
user-agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36
test1:test1
cookie:cookie_test
test3:test3_1,test3_2
sec-fetch-mode:cors
```

* 设置请求头与原请求头中出现相同时替换相同的内容

调用的子请求(**ngx.location.capture("/common/request_header/demo/capture")**)中的操作就是获取所有的请求头内容，以此验证设置请求头是否成功

```lua
local request_header = require "request_header"

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
```

```text
true
key:host value:localhost:8888
key:connection value:keep-alive
key:sec-fetch-site value:cross-site
key:accept value:*/*
key:accept-language value:zh-CN,zh;q=0.9
key:test_2 value:test_2
key:accept-encoding value:gzip, deflate, br
key:user-agent value:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36
key:test1 value:test1
key:cookie value:cookie_test
key:test3 value:test3_1,test3_2
key:sec-fetch-mode value:cors
```

**清除请求头中的值**

调用函数:clear_header(data)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| data | table | 是 | 要清除的多个cookie的名称数组 | 数组table，不能是对象 |

示例:

* 假设原请求头

```text
host:localhost:8888
connection:keep-alive
sec-fetch-site:cross-site
sec-fetch-mode:cors
accept-encoding:gzip, deflate, br
user-agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36
accept:*/*
cookie:_ga=GA1.1.515272813.1557485115; JSESSIONID=B3A27B8FB81DA40A0773EAAD67ABC35E
accept-language:zh-CN,zh;q=0.9
```

调用的子请求(**ngx.location.capture("/common/request_header/demo/capture")**)中的操作就是获取所有的请求头内容，以此验证清除请求头是否成功

```lua
local request_header = require "request_header"

local header = {"connection", "host"}
local clear_result = request_header.clear_header(header)
local result = ngx.location.capture("/common/request_header/demo/capture")
ngx.say(clear_result)
ngx.say(result.body)
```

```text
true
sec-fetch-mode:cors
accept-encoding:gzip, deflate, br
user-agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36
accept:*/*
accept-language:zh-CN,zh;q=0.9
sec-fetch-site:cross-site
cookie:_ga=GA1.1.515272813.1557485115; JSESSIONID=B3A27B8FB81DA40A0773EAAD67ABC35E
```

[Back to TOC](#table-of-contents)

request_cookie
---------------

### 概要

request_cookie用于对cookie的读写操作

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
lua_package_path "/path/to/lua_lib/lib/cookie/?.lua;;";
```

此类库依赖本项目中**common_util.lua**类库以及第三方的**lua-resty-cookie**（在本项目中的**lib/cookie**中），如果只需要使用**request_cookie.lua**类库，也需要把**common_util.lua**以及**cookie.lua**和**request_cookie.lua**同时加入到lua_package_path中才能使用

---

**获取全部cookie**

调用函数:get_all()

参数列表:无

示例:

* 假设请求url:http://localhost:8888/common/request_cookie/demo

* 全部cookie:

```text
_ga:GA1.1.515272813.1557485115
JSESSIONID:B3A27B8FB81DA40A0773EAAD67ABC35E
```

```lua
local request_cookie = require "request_cookie"

local result = request_cookie.get_all()
if result then
    for k, v in pairs(result) do
        ngx.say(k .. ":" .. v)
    end
end
```

```text
_ga:GA1.1.515272813.1557485115
JSESSIONID:B3A27B8FB81DA40A0773EAAD67ABC35E
```

**获取指定的多个cookie**

调用函数:get_cookies(cookie_names)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| cookie_names | table | 是 | 要获取的多个cookie的名称数组 | 数组table，不能是对象 |

示例:

* 假设请求url:http://localhost:8888/common/request_cookie/demo

* 全部cookie:

```text
_ga:GA1.1.515272813.1557485115
JSESSIONID:B3A27B8FB81DA40A0773EAAD67ABC35E
```

```lua
local request_cookie = require "request_cookie"

local names = {"_ga", "JSESSIONID"}
local result = request_cookie.get_cookies(names)
if result then
    for k, v in pairs(result) do
        ngx.say(k .. ":" .. v)
    end
end
```

```text
_ga:GA1.1.515272813.1557485115
JSESSIONID:B3A27B8FB81DA40A0773EAAD67ABC35E
```

**获取单个cookie**

调用函数:get_cookie(cookie_name)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| cookie_name | string | 是 | 要获取的cookie名称 | 无 |

示例:

* 假设请求url:http://localhost:8888/common/request_cookie/demo

* 全部cookie:

```text
_ga:GA1.1.515272813.1557485115
JSESSIONID:B3A27B8FB81DA40A0773EAAD67ABC35E
```

```lua
local request_cookie = require "request_cookie"

local cookie = request_cookie.get_cookie("_ga")
ngx.say(cookie)
```

```text
_ga:GA1.1.515272813.1557485115
```

**设置cookie**

调用函数:set_cookie(cookie_data)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| cookie_data | table | 是 | 对象table | 由于依赖于第三方类库**lua-resty-cookie**，参数与**lua-resty-cookie**中设置cookie的参数一致，详情请查阅**lua-resty-cookie**官方文献，本文提供官方地址，在目录**Lualib**中查找 |

示例:

* 假设请求url:http://localhost:8888/common/request_cookie_edit/demo

```lua
local request_cookie = require "request_cookie"

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
```

```text
true
```

* 设置cookie成功后会在Response Headers中添加Set-Cookie响应头信息

```text
Set-Cookie: Name=Bob; Expires=Wed, 09 Jun 2021 10:18:14 GMT; Max-Age=50; Domain=localhost; Path=/; Secure; HttpOnly; a4334aebaec
```

[Back to TOC](#table-of-contents)

response_result
---------------

### 概要

response_result用于对响应体的格式封装

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
lua_package_path "/path/to/lua_lib/lib/json/?.lua;;";
```

此类库依赖第三方的**dkjson**（在本项目中的lib/json中）如果只需要使用**response_result.lua**类库，也需要把**response_result.lua**和**dkjson.lua**加入到lua_package_path中才能使用

---

**将返回数据封装指定的json格式，并且支持jsonp**

调用函数:success(data, code, message)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| data | object | 否 | 请求成功的响应数据 | 如果不传或传入nil默认为 ok |
| code | string 或 number | 否 | 请求成功的响应code码 | 如果不传或传入nil默认为 0 |
| message | string | 否 | 请求成功后响应的描述 | 如果不传或传入nil默认为 success |

示例:

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

调用函数:error(code, message)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| code | string 或 number | 否 | 请求失败的响应code码 | 如果不传或传入nil默认为 500 |
| message | string | 否 | 请求失败后响应的描述 | 如果不传或传入nil默认为 系统异常 |

示例:

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

函数调用:jsonp_success(data, code, message, callback)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| data | object | 否 | 请求成功的响应数据 | 如果不传或传入nil默认为 ok |
| code | string 或 number | 否 | 请求成功的响应code码 | 如果不传或传入nil默认为 0 |
| message | string | 否 | 请求成功后响应的描述 | 如果不传或传入nil默认为 success |
| callback | string | 否 | 回调函数名称 | 如果不传或传入nil默认为 非jsonp，按照非jsonp请求成功的响应格式进行返回 |

函数调用:jsonp_error(code, message, callback)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| code | string 或 number | 否 | 请求失败的响应code码 | 如果不传或传入nil默认为 500 |
| message | string | 否 | 请求失败后响应的描述 | 如果不传或传入nil默认为 系统异常 |
| callback | string | 否 | 回调函数名称 | 如果不传或传入nil默认为 非jsonp，按照非jsonp请求失败的响应格式进行返回 |

示例:

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

common_util
-----------

### 概要

common_util用于一些常用的基础操作，比如字符串分割、数组去重等等...

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
```

如果只需要使用**common_util.lua**类库，需要把**common_util.lua**加入到lua_package_path中才能使用

---

**判断数组中是否包含某个值**

函数调用:contain(array, arg)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| array | table | 是 | 源数组table，不能是对象table； | 只限string数组、或number数组 |
| arg | string or number | 是 | 是否包含在数组中的目标值 | 无 |

示例:

```lua
local common_uitl = require "common_util"

local source = {"source", "source2", "source3"}
local target_true = "source"
local target_false = "target"

ngx.say(common_uitl.contain(source, target_true))
ngx.say(common_uitl.contain(source, target_false))
```

```text
true
false
```

**判断数组中是否包含其他数组所有值**

函数调用:contains(array, args)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| array | table | 是 | 源数组table，不能是对象table | 只限string数组、或number数组 |
| args | table | 是 | 目标数组table，不能是对象table | 只限string数组、或number数组 |

示例:

```lua
local common_uitl = require "common_util"

local source = {"source", "source2", "source3"}
local target_true = {"source2", "source3"}
local target_false = {"source2", "tatget"}

ngx.say(common_uitl.contains(source, target_true))
ngx.say(common_uitl.contains(source, target_false))
```

```text
true
false
```

**按照指定字符分割字符串，并且返回table数组**

函数调用:split(source, str)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| source | string | 是 | 需要被分割的字符串 | 无 |
| str | string | 是 | 分隔符字符串 | 无 |

示例:

```lua
local common_uitl = require "common_util"

local source = "1,2,3,4,5,6,7"
local result = common_uitl.split(source, ",")
for i, v in ipairs(result) do
    ngx.say("下标" .. i .. "的值:" .. v)
end
```

```text
下标1的值:1
下标2的值:2
下标3的值:3
下标4的值:4
下标5的值:5
下标6的值:6
下标7的值:7
```

**数组去重**

函数调用:distinct(array)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| array | table | 是 | 要去重的数组 | 数组table，不能是对象table，只限string数组、或number数组 |

示例:

```lua
local common_uitl = require "common_util"

local source = {"1", "2", "3", "4", "4", "5", "5"}
local result = common_uitl.distinct(source)
for i, v in ipairs(result) do
    ngx.say("下标" .. i .. "的值:" .. v)
end
```

```text
下标1的值:1
下标2的值:2
下标3的值:3
下标4的值:4
下标5的值:5
```

**判断table是否是数组**

函数调用:is_array(data)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| data | table | 是 | 要检测的table | 无 |

示例:

```lua
local common_uitl = require "common_util"

local source_array = {"1", "2", "3", "4", "4", "5", "5"}
local source_not_array = {"1", filed_1="属性1", filed_2="属性2"}
local source_yet_array = {
    "1", 
    "2", 
    {filed_1="属性1", filed_2="属性2", filed_3="属性3"}
}
local source_object = {filed_1="属性1", filed_2="属性2", filed_3="属性3"}
local source_object_array = {
    {filed_1="属性1", filed_2="属性2", filed_3="属性3"},
    {filed_1="属性1", filed_2="属性2", filed_3="属性3"},
    {filed_1="属性1", filed_2="属性2", filed_3="属性3"}
}
ngx.say(common_uitl.is_array(source_array))
ngx.say(common_uitl.is_array(source_not_array))
ngx.say(common_uitl.is_array(source_yet_array))
ngx.say(common_uitl.is_array(source_object))
ngx.say(common_uitl.is_array(source_object_array))
```

```text
true
false
true
false
true
```

**table为对象时，将对象的属性和值分离成两个单独的数组**

函数调用:kv_separate(data)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| data | table | 是 | 要做键值分离的对象table | 对象的属性值只能输number或string |

示例:

```lua
local common_uitl = require "common_util"

local object = {filed_1="属性1", filed_2="属性2", filed_3="属性3"}
local k_array, v_array = common_uitl.kv_separate(object)
for i, v in ipairs(k_array) do
    ngx.say("分离出的k:" .. v)
end
for i, v in ipairs(v_array) do
    ngx.say("分离出的v:" .. v)
end
```

```text
分离出的k:filed_3
分离出的k:filed_1
分离出的k:filed_2
分离出的v:属性3
分离出的v:属性1
分离出的v:属性2
```

[Back to TOC](#table-of-contents)

redis_util
----------

### 概要

针对redis中5种数据结构的常用操作，但不支持分库操作（如需要支持分库，则请使用[redis_db_util](#redis_db_util)）注意**redis_util不能同时与redis_db_util同时使用，否则可能会造成对部分redis请求的数据库切分错乱问题！！！**

| 数据结构 | 支持操作 | 备注 |
| :------: | :------: | :------: |
| key-value | set、get、del、mset、mget | 暂无 |
| hash | hset、hget、hmset、hmget、hdel | 暂无 |
| list | lpush、lrange、lindex、llen、lrem | 暂无 |
| set | sadd、smembers、scard、sdiff、sinter、sunion、sismember、srandmember、spop、srem | 暂无 |
| zset | zadd、zcard、zrange、zrevrange、zrangebyscore、zrem | 暂无 |

nginx的conf配置:

upstream.conf

```conf
upstream redis_nodes {
    server localhost:6379;
    keepalive 1024;
}
```

redis.conf

```conf
location /redis/set {
    internal;
    set_unescape_uri $key $arg_key;
    set_unescape_uri $value $arg_value;
    redis2_query set $key $value;
    redis2_pass redis_nodes;
}

location /redis/get {
    internal;
    set_unescape_uri $key $arg_key;
    redis2_query get $key;
    redis2_pass redis_nodes;
}

location /redis/single {
    internal;
    set_unescape_uri $commands $arg_commands;
    redis2_raw_query $commands;
    redis2_pass redis_nodes;
}
```

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
```

在OpenResty中对redis操作首先依赖于**redis2-nginx-module**组件，其次此类库依赖**common_util**类库，也需要把**common_util.lua**加入到lua_package_path中才能使用

---

**操作key-value数据结构**

| redis命令 | 对应lua函数 | 参数说明 | 返回值 |
| :------: | :------: | :------: | :------: |
| set | redis_util.set(set_command) | 入参:redis命令table，table为对象，对象的属性为key、value | 无 |
| get | redis_util.get(key) | 入参:key | 查询结果(字符串) |
| del | redis_util.del(keys) | 入参:redis命令table，table为数组 | 无 |
| mset | redis_util.mset(mset_command) | 入参:redis命令table，table为数组，数组中为对象，对象的属性为key、value | 无 |
| mget | redis_util.mget(keys) | redis命令table，table为数组，数组中为key | 查询结果（数组） |

实例:

```lua
local redis_util = require "redis_util"
local dkjson = require "dkjson"

local function set()
    local value = {}
    value.v1 = "v1"
    value.v2 = "v2"
    local set_command = {key = "set_test_key", value = dkjson.encode(value)}
    redis_util.set(set_command)
end
set()

local function get()
    local result = redis_util.get("set_test_key")
    ngx.say(result)
end
get()

local function del()
    local del_command = {"set_test_key"}
    redis_util.del(del_command)
end
del()

local function mset()
    local mset_command = {
        {key="mset_test_key_1", value="mset_test_value_1"},
        {key="mset_test_key_2", value="mset_test_value_2"},
        {key="mset_test_key_3", value="mset_test_value_3"}
    }
    redis_util.mset(mset_command)
end
mset()

local function mget()
    local mget_command = {"mset_test_key_1", "mset_test_key_2", "mset_test_key_3"}
    local result = redis_util.mget(mget_command)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
mget()
```

**操作hash数据结构**

| redis命令 | 对应lua函数 | 参数说明 | 返回值 |
| :------: | :------: | :------: | :------: |
| hset | redis_util.hset(hset_command) | 入参:redis命令table，table为对象，对象的属性为key、filed、value | 无 |
| hget | redis_util.hget(hget_command) | 入参:redis命令table，table为对象，对象的属性为key、filed | 查询结果（字符串） |
| hmset | redis_util.hmset(key, hmset_command) | 入参:key和redis命令table，table为对象，key为hmset中key值，hmset_command为对象数组，对象的属性为filed、value | 无 |
| hmget | redis_util.hmget(key, fileds) | 入参:key为hmget中key值，fileds为数组 | 查询结果（table） |
| hdel | redis_util.hdel(key, fileds) | 入参:key为hmset中key值，fileds为数组 | 无 |

实例:

```lua
local redis_util = require "redis_util"

local function hset()
    local hset_command = {}
    hset_command.key = "hset_key"
    hset_command.filed = "hset_filed"
    hset_command.value = "hset_value"
    redis_util.hset(hset_command)
end
hset()

local function hget()
    local hget_command = {}
    hget_command.key = "hset_key"
    hget_command.filed = "hset_filed"
    ngx.say(redis_util.hget(hget_command))
end
hget()

local function hmset()
    local hmset_command = {
        {filed = "hmset_test_filed_1", value = "hmset_test_value_1"},
        {filed = "hmset_test_filed_2", value = "hmset_test_value_2"},
        {filed = "hmset_test_filed_3", value = "hmset_test_value_3"}
    }
    redis_util.hmset("hmset_test", hmset_command)
end
hmset()

local function hmget()
    local hmget_command = {"hmset_test_filed_1", "hmset_test_filed_2", "hmset_test_filed_3"}
    local result = redis_util.hmget("hmset_test", hmget_command)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
hmget()

local function hdel()
    local hdel_command = {"hmset_test_filed_1", "hmset_test_filed_2"}
    redis_util.hdel("hmset_test", hdel_command)
end
hdel()
```

**操作list数据结构**

| redis命令 | 对应lua函数 | 参数说明 | 返回值 |
| :------: | :------: | :------: | :------: |
| lpush | redis_util.lpush(key, values) | 入参:key为lpush中key值，values为值数组 | 无 |
| lrange | redis_util.lrange(key, start, en) | 入参:key为lrange的key，start为开始位置，en为结束位置，start和en只能是数字 | 查询结果（table） |
| lindex | redis_util.lindex(key, index) | 入参:key为lindex的key，index为索引 | 查询结果（字符串） |
| llen | redis_util.llen(key) | 入参:key为llen的key | 查询结果（数字） |
| lrem | redis_util.lrem(key, count, value) | 入参:key为lrem的key，count为删除数量以及方向，value为要删除的值;count > 0 : 从表头开始向表尾搜索，移除与 VALUE 相等的元素，数量为 COUNT;count < 0 : 从表尾开始向表头搜索，移除与 VALUE 相等的元素，数量为 COUNT 的绝对值;count = 0 : 移除表中所有与 VALUE 相等的值 | 无 |

实例:

```lua
local redis_util = require "redis_util"

local function lpush()
    local lpush_command = {"lpush_test_value_1", "lpush_test_value_2", "lpush_test_value_3"}
    redis_util.lpush("lpush_test", lpush_command)
end
lpush()

local function lrange()
    local result = redis_util.lrange("lpush_test", 0, -1)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
lrange()

local function lindex()
    ngx.say(redis_util.lindex("lpush_test", 0))
end
lindex()

local function llen()
    ngx.say(redis_util.llen("lpush_test"))
end
llen()

local function lrem()
    redis_util.lrem("lpush_test", 0, "lpush_test_value_1")
end
lrem()
```

**操作set数据结构**

| redis命令 | 对应lua函数 | 参数说明 | 返回值 |
| :------: | :------: | :------: | :------: |
| sadd | redis_util.sadd(key, values) | 入参:key为sadd的key，values为table数组 | 无 |
| smembers | redis_util.smembers(key) | 入参:key为smembers的key | 查询结果（table） |
| scard | redis_util.scard(key) | 入参:key为scard的key | 查询结果（数字） |
| sdiff | redis_util.sdiff(key, keys) | 入参:key为要获取差集的set集合的key，keys为对比哪些set集合，keys为数组 | 查询结果（table） |
| sinter | redis_util.sinter(key, keys) | 入参:key为要获取交集的set集合的key，keys为对比哪些set集合，keys为数组 | 查询结果（table） |
| sunion | redis_util.sunion(key, keys) | 入参:key为要获取并集的set集合的key，keys为对比哪些set集合，keys为数组 | 查询结果（table） |
| sismember | redis_util.sismember(key, value) | 入参:key指定的set集合，value为要检测是否存在的元素 | 查询结果（布尔） |
| srandmember | redis_util.srandmember(key, count) | 入参:key指定的set集合，count为要返回的参数条件（可选），count为数字;如果 count 为正数，且小于集合基数，那么命令返回一个包含 count 个元素的数组，数组中的元素各不相同。如果 count 大于等于集合基数，那么返回整个集合;如果 count 为负数，那么命令返回一个数组，数组中的元素可能会重复出现多次，而数组的长度为 count 的绝对值 | 查询结果（table） |
| spop | redis_util.spop(key, count) | 入参:key指定的set集合，count为要返回以及删除的参数条件（可选），count为数字但不能是负数并且必须大于0;如果 count 为正数，且小于集合基数，那么命令返回一个包含 count 个元素的数组并且将返回元素删除，数组中的元素各不相同。如果 count 大于等于集合基数，那么返回整个集合，并且将元素删除 | 查询结果（table） |
| srem | redis_util.srem(key, values) | 入参:key指定的set集合，values为要及删除的值，values为table数组 | 无 |

实例:

```lua
local redis_util = require "redis_util"

local function sadd()
    local sadd_command = {"sadd_test_value_1", "sadd_test_value_2", "sadd_test_value_3"}
    local sadd_command_2 = {"sadd_test_value_1", "sadd_test_value_2", "sadd_test_value_3", "sdiff_1", "sdiff_2"}
    redis_util.sadd("sadd_test_key", sadd_command)
    redis_util.sadd("sadd_test_key_2", sadd_command_2)
end
sadd()

local function smembers()
    local result = redis_util.smembers("sadd_test_key")
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
smembers()

local function scard()
    ngx.say(redis_util.scard("sadd_test_key"))
end
scard()

local function sdiff()
    local target_sdiff_keys = {"sadd_test_key"}
    local result = redis_util.sdiff("sadd_test_key_2", target_sdiff_keys)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
sdiff()

local function sinter()
    local target_sinter_keys = {"sadd_test_key"}
    local result = redis_util.sinter("sadd_test_key_2", target_sinter_keys)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
sinter()

local function sunion()
    local target_sunion_keys = {"sadd_test_key"}
    local result = redis_util.sunion("sadd_test_key_2", target_sunion_keys)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
sunion()

local function sismember()
    ngx.say(redis_util.sismember("sadd_test_key", "sadd_test_value_1"))
    ngx.say(redis_util.sismember("sadd_test_key", "no_value"))
end
sismember()

local function srandmember()
    local result = redis_util.srandmember("sadd_test_key", 1)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
srandmember()

local function spop()
    local result = redis_util.spop("sadd_test_key", 1)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
spop()

local function srem()
    local srem_command = {"sadd_test_value_1", "sadd_test_value_2"}
    redis_util.srem("sadd_test_key_2", srem_command)
end
srem()
```

**操作zset数据结构**

| redis命令 | 对应lua函数 | 参数说明 | 返回值 |
| :------: | :------: | :------: | :------: |
| zadd | redis_util.zadd(key, zset_command) | 入参:key指定的zset集合，zset_command为table数组，数组中是对象，对象属性为score、value | 无 |
| zcard | redis_util.zcard(key) | 入参:key为指定的zset集合 | 查询结果（数字） |
| zrange | redis_util.zrange(key, start, stop) | 入参:key为指定的zset集合，start为开始下标参数，stop为结束下标参数，start和stop都为数字 | 查询结果（table） |
| zrevrange | redis_util.zrevrange(key, start, stop) | 入参:key为指定的zset集合，start为开始下标参数，stop为结束下标参数，start和stop都为数字 | 查询结果（table） |
| zrangebyscore | redis_util.zrangebyscore(key, min, max) | 入参:key为指定的zset集合，min、max为最大以及最小区间，min、max为字符串，但是只能是数字类型的字符串或'('加数字类型的字符串 | 查询结果（table） |
| zrem | redis_util.zrem(key, values) | 入参:key为指定的zset集合，values为要删除的值，values为数组table，数组中的值为字符串 | 无 |

实例:

```lua
local redis_util = require "redis_util"

local function zadd()
    local zadd_command = {
        {score=001, value="test_zadd_value1"},
        {score=002, value="test_zadd_value2"},
        {score=003, value="test_zadd_value3"}
    }
    redis_util.zadd("zadd_test_key", zadd_command)
end
zadd()

local function zcard()
    ngx.say(redis_util.zcard("zadd_test_key"))
end
zcard()

local function zrange()
    local result = redis_util.zrange("zadd_test_key", 0, -1)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
zrange()

local function zrevrange()
    local result = redis_util.zrevrange("zadd_test_key", 0, -1)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
zrevrange()

local function zrangebyscore()
    local result = redis_util.zrangebyscore("zadd_test_key", "0", "2")
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
zrangebyscore()

local function zrem()
    local zrem_command = {"test_zadd_value1", "test_zadd_value2"}
    redis_util.zrem("zadd_test_key", zrem_command)
end
zrem()
```

[Back to TOC](#table-of-contents)

redis_db_util
-------------

### 概要

针对redis中5种数据结构的常用操作以及pipeline操作，并且支持分库操作，对于分库的策略有两种，一种是手动指定数据库，另外一种是，如果不手动指定，函数根据key值自动计算数据库索引;注意**redis_util不能同时与redis_db_util同时使用，否则可能会造成对部分redis请求的数据库切分错乱问题！！！**

| 数据结构 | 支持操作 | 备注 |
| :------: | :------: | :------: |
| key-value | set、get、del、mset、mget | 暂无 |
| hash | hset、hget、hmset、hmget、hdel | 暂无 |
| list | lpush、lrange、lindex、llen、lrem | 暂无 |
| set | sadd、smembers、scard、sdiff、sinter、sunion、sismember、srandmember、spop、srem | 暂无 |
| zset | zadd、zcard、zrange、zrevrange、zrangebyscore、zrem | 暂无 |

nginx的conf配置:

upstream.conf

```conf
upstream redis_nodes {
    server localhost:6379;
    keepalive 1024;
}
```

redis.conf

```conf
location /redis/pipeline/body {
    internal;
    redis2_raw_queries $args $echo_request_body;
    redis2_pass redis_nodes;
}
```

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
```

在OpenResty中对redis操作首先依赖于**redis2-nginx-module**组件，其次此类库依赖**common_util**类库，也需要把**common_util.lua**加入到lua_package_path中才能使用

---

**根据key值自动计算数据库索引**

函数调用:select_db(key)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| key | string | 是 | 通过key值获取数据库索引 | 如果不传默认为数据库0 |

实例:

```lua
local redis_db_util = require "redis_db_util"

local function db()
    local result = redis_db_util.select_db("z")
    ngx.say(result)
end
db()
```

**使用redis的pipeline**

函数调用:send_pipeline(commands)

参数列表:

| 参数 | 参数类型 | 是否必传 | 描述 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| commands | table | 是 | redis命令table，table为数组，数组中的每条命令也是一个table的数组 | 无 |

实例:

```lua
local redis_db_util = require "redis_db_util"

local function pipeline()
    local commands = {
        {"select", 2},
        {"zadd", "good_activity_0001", "1", "测试数据1"},
        {"zadd", "good_activity_0001", "2", "测试数据2"},
        {"zadd", "good_activity_0001", "3", "测试数据3"},
        {"ZRANGEBYSCORE", "good_activity_0001", "-inf", "+inf"}}
    ngx.say(dkjson.encode(redis_db_util.send_pipeline(commands)))
end
pipeline()
```

**以下操作五种数据类型对应函数的通用参数描述**

| 参数名称 | 是否必传 | 参数类型 | 参数说明 | 备注 |
| :------: | :------: | :------: | :------: | :------: |
| db | 否 | number | db为指定的数据库索引，值为number，如果db为nil则根据key值进行数据库索引的自动计算 | 在mset和mget的函数调用中，如果不传，则为0，因为mset和mget中，多个key的开头肯定是不一样的，无法计算出统一的数据库索引 |

**操作key-value数据结构**

| redis命令 | 对应lua函数 | 参数说明 | 返回值 |
| :------: | :------: | :------: | :------: |
| set | redis_db_util.set(set_command, db) | 入参:redis命令table，table为对象，对象的属性为key、value | 无 |
| get | redis_db_util.get(key, db) | 入参:key | 查询结果(字符串) |
| del | redis_db_util.del(keys, db) | 入参:redis命令table，table为数组 | 无 |
| mset | redis_db_util.mset(mset_command, db) | 入参:redis命令table，table为数组，数组中为对象，对象的属性为key、value;mset分库具有局限性，如果key的开头不一致的话，这代表着在进行select之后，无法使用mset指令将所有的key-value用这一个命令进行写入，所以，mset分库只支持手动指定数据库，并不能进行自动计算，如果db不传，则默认为0 | 无 |
| mget | redis_db_util.mget(keys, db) | redis命令table，table为数组，数组中为key;mget分库具有局限性，如果key的开头不一致的话，这代表着在进行select之后，无法使用mget指令将所有的key-value用这一个命令进行读取，所以，mget分库只支持手动指定数据库，并不能进行自动计算，如果db不传，则默认为0 | 查询结果（数组） |

实例:

```lua
local redis_db_util = require "redis_db_util"
local dkjson = require "dkjson"

local function set()
    local value = {}
    value.v1 = "v1"
    value.v2 = "v2"
    local set_command = {key = "set_test_key", value = dkjson.encode(value)}
    redis_db_util.set(set_command, 2)
end
set()

local function get()
    local result_db = redis_db_util.get("set_test_key", 2)
    ngx.say(result_db)
end
get()

local function del()
    local del_command = {"set_test_key"}
    redis_db_util.del(del_command, 2)
end
del()

local function mset()
    local mset_command = {
        {key="mset_test_key_1", value="mset_test_value_1"},
        {key="mset_test_key_2", value="mset_test_value_2"},
        {key="mset_test_key_3", value="mset_test_value_3"}
    }
    redis_db_util.mset(mset_command, 2)
end
mset()

local function mget()
    local mget_command = {"mset_test_key_1", "mset_test_key_2", "mset_test_key_3"}
    local result = redis_db_util.mget(mget_command, 2)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
mget()
```

**操作hash数据结构**

| redis命令 | 对应lua函数 | 参数说明 | 返回值 |
| :------: | :------: | :------: | :------: |
| hset | redis_db_util.hset(hset_command, db) | 入参:redis命令table，table为对象，对象的属性为key、filed、value | 无 |
| hget | redis_db_util.hget(hget_command, db) | 入参:redis命令table，table为对象，对象的属性为key、filed | 查询结果（字符串） |
| hmset | redis_db_util.hmset(key, hmset_command, db) | 入参:key和redis命令table，table为对象，key为hmset中key值，hmset_command为对象数组，对象的属性为filed、value | 无 |
| hmget | redis_db_util.hmget(key, fileds, db) | 入参:key为hmget中key值，fileds为数组 | 查询结果（table） |
| hdel | redis_db_util.hdel(key, fileds, db) | 入参:key为hmset中key值，fileds为数组 | 无 |

实例:

```lua
local redis_db_util = require "redis_db_util"

local function hset()
    local hset_command = {}
    hset_command.key = "hset_key"
    hset_command.filed = "hset_filed"
    hset_command.value = "hset_value"
    redis_db_util.hset(hset_command, 2)
end
hset()

local function hget()
    local hget_command = {}
    hget_command.key = "hset_key"
    hget_command.filed = "hset_filed"
    ngx.say(redis_db_util.hget(hget_command, 2))
end
hget()

local function hmset()
    local hmset_command = {
        {filed = "hmset_test_filed_1", value = "hmset_test_value_1"},
        {filed = "hmset_test_filed_2", value = "hmset_test_value_2"},
        {filed = "hmset_test_filed_3", value = "hmset_test_value_3"}
    }
    redis_db_util.hmset("hmset_test", hmset_command, 2)
end
hmset()

local function hmget()
    local hmget_command = {"hmset_test_filed_1", "hmset_test_filed_2", "hmset_test_filed_3"}
    local result_db = redis_db_util.hmget("hmset_test", hmget_command, 2)
    for i, v in ipairs(result_db) do
        ngx.say(v)
    end
end
hmget()

local function hdel()
    local hdel_command = {"hmset_test_filed_1", "hmset_test_filed_2"}
    redis_db_util.hdel("hmset_test", hdel_command, 2)
end
hdel()
```

**操作list数据结构**

| redis命令 | 对应lua函数 | 参数说明 | 返回值 |
| :------: | :------: | :------: | :------: |
| lpush | redis_db_util.lpush(key, values, db) | 入参:key为lpush中key值，values为值数组 | 无 |
| lrange | redis_db_util.lrange(key, start, en, db) | 入参:key为lrange的key，start为开始位置，en为结束位置，start和en只能是数字 | 查询结果（table） |
| lindex | redis_db_util.lindex(key, index, db) | 入参:key为lindex的key，index为索引 | 查询结果（字符串） |
| llen | redis_db_util.llen(key, db) | 入参:key为llen的key | 查询结果（数字） |
| lrem | redis_db_util.lrem(key, count, value, db) | 入参:key为lrem的key，count为删除数量以及方向，value为要删除的值;count > 0 : 从表头开始向表尾搜索，移除与 VALUE 相等的元素，数量为 COUNT;count < 0 : 从表尾开始向表头搜索，移除与 VALUE 相等的元素，数量为 COUNT 的绝对值;count = 0 : 移除表中所有与 VALUE 相等的值 | 无 |

实例:

```lua
local redis_db_util = require "redis_db_util"

local function lpush()
    local lpush_command = {"lpush_test_value_1", "lpush_test_value_2", "lpush_test_value_3"}
    redis_db_util.lpush("lpush_test", lpush_command, 2)
end
lpush()

local function lrange()
    local result_2 = redis_db_util.lrange("lpush_test", 0, -1, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
lrange()

local function lindex()
    ngx.say(redis_db_util.lindex("lpush_test", 0, 2))
end
lindex()

local function llen()
    ngx.say(redis_db_util.llen("lpush_test", 2))
end
llen()

local function lrem()
    redis_db_util.lrem("lpush_test", 0, "lpush_test_value_1", 2)
end
lrem()
```

**操作set数据结构**

| redis命令 | 对应lua函数 | 参数说明 | 返回值 |
| :------: | :------: | :------: | :------: |
| sadd | redis_db_util.sadd(key, values, db) | 入参:key为sadd的key，values为table数组 | 无 |
| smembers | redis_db_util.smembers(key, db) | 入参:key为smembers的key | 查询结果（table） |
| scard | redis_db_util.scard(key, db) | 入参:key为scard的key | 查询结果（数字） |
| sdiff | redis_db_util.sdiff(key, keys, db) | 入参:key为要获取差集的set集合的key，keys为对比哪些set集合，keys为数组 | 查询结果（table） |
| sinter | redis_db_util.sinter(key, keys, db) | 入参:key为要获取交集的set集合的key，keys为对比哪些set集合，keys为数组 | 查询结果（table） |
| sunion | redis_db_util.sunion(key, keys, db) | 入参:key为要获取并集的set集合的key，keys为对比哪些set集合，keys为数组 | 查询结果（table） |
| sismember | redis_db_util.sismember(key, value, db) | 入参:key指定的set集合，value为要检测是否存在的元素 | 查询结果（布尔） |
| srandmember | redis_db_util.srandmember(key, count, db) | 入参:key指定的set集合，count为要返回的参数条件（可选），count为数字;如果 count 为正数，且小于集合基数，那么命令返回一个包含 count 个元素的数组，数组中的元素各不相同。如果 count 大于等于集合基数，那么返回整个集合;如果 count 为负数，那么命令返回一个数组，数组中的元素可能会重复出现多次，而数组的长度为 count 的绝对值 | 查询结果（table） |
| spop | redis_db_util.spop(key, count, db) | 入参:key指定的set集合，count为要返回以及删除的参数条件（可选），count为数字但不能是负数并且必须大于0;如果 count 为正数，且小于集合基数，那么命令返回一个包含 count 个元素的数组并且将返回元素删除，数组中的元素各不相同。如果 count 大于等于集合基数，那么返回整个集合，并且将元素删除 | 查询结果（table） |
| srem | redis_db_util.srem(key, values, db) | 入参:key指定的set集合，values为要及删除的值，values为table数组 | 无 |

实例:

```lua
local redis_db_util = require "redis_db_util"

local function sadd()
    local sadd_command = {"sadd_test_value_1", "sadd_test_value_2", "sadd_test_value_3"}
    local sadd_command_2 = {"sadd_test_value_1", "sadd_test_value_2", "sadd_test_value_3", "sdiff_1", "sdiff_2"}
    redis_db_util.sadd("sadd_test_key", sadd_command, 2)
    redis_db_util.sadd("sadd_test_key_2", sadd_command_2, 2)
end
sadd()

local function smembers()
    local result_2 = redis_db_util.smembers("sadd_test_key_2", 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
smembers()

local function scard()
    ngx.say(redis_db_util.scard("sadd_test_key_2", 2))
end
scard()

local function sdiff()
    local target_sdiff_keys = {"sadd_test_key"}
    local result_2 = redis_db_util.sdiff("sadd_test_key_2", target_sdiff_keys, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
sdiff()

local function sinter()
    local target_sinter_keys = {"sadd_test_key"}
    local result_2 = redis_db_util.sinter("sadd_test_key_2", target_sinter_keys, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
sinter()

local function sunion()
    local target_sunion_keys = {"sadd_test_key"}
    local result_2 = redis_db_util.sunion("sadd_test_key_2", target_sunion_keys, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
sunion()

local function sismember()
    ngx.say(redis_db_util.sismember("sadd_test_key", "sadd_test_value_1", 2))
    ngx.say(redis_db_util.sismember("sadd_test_key", "no_value", 2))
end
sismember()

local function srandmember()
    local result_2 = redis_db_util.srandmember("sadd_test_key", 1, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
srandmember()

local function spop()
    local result_2 = redis_db_util.spop("sadd_test_key", 1, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
spop()

local function srem()
    local srem_command = {"sadd_test_value_1", "sadd_test_value_2"}
    redis_db_util.srem("sadd_test_key_2", srem_command, 2)
end
srem()
```

**操作zset数据结构**

| redis命令 | 对应lua函数 | 参数说明 | 返回值 |
| :------: | :------: | :------: | :------: |
| zadd | redis_db_util.zadd(key, zset_command, db) | 入参:key指定的zset集合，zset_command为table数组，数组中是对象，对象属性为score、value | 无 |
| zcard | redis_db_util.zcard(key, db) | 入参:key为指定的zset集合 | 查询结果（数字） |
| zrange | redis_db_util.zrange(key, start, stop, db) | 入参:key为指定的zset集合，start为开始下标参数，stop为结束下标参数，start和stop都为数字 | 查询结果（table） |
| zrevrange | redis_db_util.zrevrange(key, start, stop, db) | 入参:key为指定的zset集合，start为开始下标参数，stop为结束下标参数，start和stop都为数字 | 查询结果（table） |
| zrangebyscore | redis_db_util.zrangebyscore(key, min, max, db) | 入参:key为指定的zset集合，min、max为最大以及最小区间，min、max为字符串，但是只能是数字类型的字符串或'('加数字类型的字符串 | 查询结果（table） |
| zrem | redis_db_util.zrem(key, values, db) | 入参:key为指定的zset集合，values为要删除的值，values为数组table，数组中的值为字符串 | 无 |

实例:

```lua
local redis_db_util = require "redis_db_util"

local function zadd()
    local zadd_command = {
        {score=001, value="test_zadd_value1"},
        {score=002, value="test_zadd_value2"},
        {score=003, value="test_zadd_value3"}
    }
    redis_db_util.zadd("zadd_test_key", zadd_command, 2)
end
zadd()

local function zcard()
    ngx.say(redis_db_util.zcard("zadd_test_key", 2))
end
zcard()

local function zrange()
    local result_2 = redis_db_util.zrange("zadd_test_key", 0, -1, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
zrange()

local function zrevrange()
    local result_2 = redis_db_util.zrevrange("zadd_test_key", 0, -1, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
zrevrange()

local function zrangebyscore()
    local result_2 = redis_db_util.zrangebyscore("zadd_test_key", "0", "2", 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
zrangebyscore()

local function zrem()
    local zrem_command = {"test_zadd_value1", "test_zadd_value2"}
    redis_db_util.zrem("zadd_test_key", zrem_command, 2)
end
zrem()
```

[Back to TOC](#table-of-contents)

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

lua-resty-cookie
----------------

**[官方文献](https://github.com/cloudflare/lua-resty-cookie)**

主要作用:对Cookie的操作，获取、设置等

[Back to TOC](#table-of-contents)