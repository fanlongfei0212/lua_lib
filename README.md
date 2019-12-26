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
content_by_lua_file json_key_pair.lua;
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
content_by_lua_file text_key_pair.lua;
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

**request_args用于获取url、body中的请求参数**

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
lua_package_path "/path/to/lua_lib/lib/json/?.lua;;";
```

此类库依赖第三方的**dkjson**（在本项目中的lib/json中），如果只需要使用**request_args.lua**类库，也需要把**dkjson.lua**和**request_args.lua**同时加入到lua_package_path中才能使用

---

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

```text
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

```text
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

```text
post请求中参数-->parameter1的值:参数1的值
post请求中参数-->parameter2的值:参数2的值
```

[Back to TOC](#table-of-contents)

request_header
--------------

### 概要

**request_header用于针对请求头的获取、修改、清除**

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
```

此类库依赖本项目中**common_util.lua**类库，如果只需要使用**request_header.lua**类库，也需要把**common_util.lua**和**request_header.lua**同时加入到lua_package_path中才能使用

---

**获取请求头中所有的值**

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

**request_cookie用于对cookie的读写操作**

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
lua_package_path "/path/to/lua_lib/lib/cookie/?.lua;;";
```

此类库依赖本项目中**common_util.lua**类库以及第三方的**lua-resty-cookie**（在本项目中的**lib/cookie**中），如果只需要使用**request_cookie.lua**类库，也需要把**common_util.lua**以及**cookie.lua**和**request_cookie.lua**同时加入到lua_package_path中才能使用

---

**获取全部cookie**

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

**response_result用于对响应体的格式封装**

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
lua_package_path "/path/to/lua_lib/lib/json/?.lua;;";
```

此类库依赖第三方的**dkjson**（在本项目中的lib/json中）如果只需要使用**response_result.lua**类库，也需要把**response_result.lua**和**dkjson.lua**加入到lua_package_path中才能使用

---

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

common_util
-----------

### 概要

**common_util用于一些常用的基础操作，比如字符串分割、数组去重等等...**

lua_package_path:

```text
lua_package_path "/path/to/lua_lib/lib/util/?.lua;;";
```

如果只需要使用**common_util.lua**类库，需要把**common_util.lua**加入到lua_package_path中才能使用

---

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