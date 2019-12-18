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