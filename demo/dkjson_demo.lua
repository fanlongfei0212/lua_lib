local dkjson = require "dkjson"

local array = {"hello", "word"}
local hash = {filed_1="属性1", filed_2="属性2", filed_3="属性3"}
local obj_array = {
    {filed_1="属性1", filed_2="属性2", filed_3="属性3"},
    {filed_1="属性1", filed_2="属性2", filed_3="属性3"},
    {filed_1="属性1", filed_2="属性2", filed_3="属性3"}
}

local array_encode_result = nil
local hash_encode_result = nil
local obj_array_encode_result = nil

local function dkjson_encode_demo()
    array_encode_result = dkjson.encode(array)
    hash_encode_result = dkjson.encode(hash)
    obj_array_encode_result = dkjson.encode(obj_array)

    ngx.say(array_encode_result)
    ngx.say(hash_encode_result)
    ngx.say(obj_array_encode_result)
end
dkjson_encode_demo()

local function dkjson_decode_demo()
    array = dkjson.decode(array_encode_result)
    hash = dkjson.decode(hash_encode_result)
    obj_array = dkjson.decode(obj_array_encode_result)
end
dkjson_decode_demo()

for i, v in ipairs(array) do
    ngx.say("array--下标" .. i .. "的值:" .. v)
end

for k, v in pairs(hash) do
    ngx.say("hash--key:" .. k .. "的值:" .. v)
end

for i, v in ipairs(obj_array) do
    ngx.say("obj_array--下标:" .. i .. "对象数据:")
    if type(v) == "table" then
        for k_2, v_2 in pairs(v) do
            ngx.say("key:" .. k_2 .. "的值" .. v_2)
        end
    end
end