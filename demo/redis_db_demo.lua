local redis_util = require "redis_db_util"
local dkjson = require "dkjson"

local function db()
    local result = redis_util.select_db("z")
    ngx.say(result)
end
db()

local function pipeline()
    local commands = {
        {"select", 2},
        {"zadd", "good_activity_0001", "1", "测试数据1"},
        {"zadd", "good_activity_0001", "2", "测试数据2"},
        {"zadd", "good_activity_0001", "3", "测试数据3"},
        {"ZRANGEBYSCORE", "good_activity_0001", "-inf", "+inf"}}
    ngx.say(dkjson.encode(redis_util.send_pipeline(commands)))
end
pipeline()

local function set()
    local value = {}
    value.v1 = "v1"
    value.v2 = "v2"
    local set_command = {key = "set_test_key", value = dkjson.encode(value)}
    redis_util.set(set_command, 2)
end
set()

local function get()
    local result_db = redis_util.get("set_test_key", 2)
    ngx.say(result_db)
end
get()

local function del()
    local del_command = {"set_test_key"}
    redis_util.del(del_command, 2)
end
del()

local function mset()
    local mset_command = {
        {key="mset_test_key_1", value="mset_test_value_1"},
        {key="mset_test_key_2", value="mset_test_value_2"},
        {key="mset_test_key_3", value="mset_test_value_3"}
    }
    redis_util.mset(mset_command, 2)
end
mset()

local function mget()
    local mget_command = {"mset_test_key_1", "mset_test_key_2", "mset_test_key_3"}
    local result = redis_util.mget(mget_command, 2)
    for i, v in ipairs(result) do
        ngx.say(v)
    end
end
mget()

local function hset()
    local hset_command = {}
    hset_command.key = "hset_key"
    hset_command.filed = "hset_filed"
    hset_command.value = "hset_value"
    redis_util.hset(hset_command, 2)
end
hset()

local function hget()
    local hget_command = {}
    hget_command.key = "hset_key"
    hget_command.filed = "hset_filed"
    ngx.say(redis_util.hget(hget_command, 2))
end
hget()

local function hmset()
    local hmset_command = {
        {filed = "hmset_test_filed_1", value = "hmset_test_value_1"},
        {filed = "hmset_test_filed_2", value = "hmset_test_value_2"},
        {filed = "hmset_test_filed_3", value = "hmset_test_value_3"}
    }
    redis_util.hmset("hmset_test", hmset_command, 2)
end
hmset()

local function hmget()
    local hmget_command = {"hmset_test_filed_1", "hmset_test_filed_2", "hmset_test_filed_3"}
    local result_db = redis_util.hmget("hmset_test", hmget_command, 2)
    for i, v in ipairs(result_db) do
        ngx.say(v)
    end
end
hmget()

local function hdel()
    local hdel_command = {"hmset_test_filed_1", "hmset_test_filed_2"}
    redis_util.hdel("hmset_test", hdel_command, 2)
end
hdel()

local function lpush()
    local lpush_command = {"lpush_test_value_1", "lpush_test_value_2", "lpush_test_value_3"}
    redis_util.lpush("lpush_test", lpush_command, 2)
end
lpush()

local function lrange()
    local result_2 = redis_util.lrange("lpush_test", 0, -1, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
lrange()

local function lindex()
    ngx.say(redis_util.lindex("lpush_test", 0, 2))
end
lindex()

local function llen()
    ngx.say(redis_util.llen("lpush_test", 2))
end
llen()

local function lrem()
    redis_util.lrem("lpush_test", 0, "lpush_test_value_1", 2)
end
lrem()

local function sadd()
    local sadd_command = {"sadd_test_value_1", "sadd_test_value_2", "sadd_test_value_3"}
    local sadd_command_2 = {"sadd_test_value_1", "sadd_test_value_2", "sadd_test_value_3", "sdiff_1", "sdiff_2"}
    redis_util.sadd("sadd_test_key", sadd_command, 2)
    redis_util.sadd("sadd_test_key_2", sadd_command_2, 2)
end
sadd()

local function smembers()
    local result_2 = redis_util.smembers("sadd_test_key_2", 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
smembers()

local function scard()
    ngx.say(redis_util.scard("sadd_test_key_2", 2))
end
scard()

local function sdiff()
    local target_sdiff_keys = {"sadd_test_key"}
    local result_2 = redis_util.sdiff("sadd_test_key_2", target_sdiff_keys, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
sdiff()

local function sinter()
    local target_sinter_keys = {"sadd_test_key"}
    local result_2 = redis_util.sinter("sadd_test_key_2", target_sinter_keys, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
sinter()

local function sunion()
    local target_sunion_keys = {"sadd_test_key"}
    local result_2 = redis_util.sunion("sadd_test_key_2", target_sunion_keys, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
sunion()

local function sismember()
    ngx.say(redis_util.sismember("sadd_test_key", "sadd_test_value_1", 2))
    ngx.say(redis_util.sismember("sadd_test_key", "no_value", 2))
end
sismember()

local function srandmember()
    local result_2 = redis_util.srandmember("sadd_test_key", 1, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
srandmember()

local function spop()
    local result_2 = redis_util.spop("sadd_test_key", 1, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
spop()

local function srem()
    local srem_command = {"sadd_test_value_1", "sadd_test_value_2"}
    redis_util.srem("sadd_test_key_2", srem_command, 2)
end
srem()

local function zadd()
    local zadd_command = {
        {score=001, value="test_zadd_value1"},
        {score=002, value="test_zadd_value2"},
        {score=003, value="test_zadd_value3"}
    }
    redis_util.zadd("zadd_test_key", zadd_command, 2)
end
zadd()

local function zcard()
    ngx.say(redis_util.zcard("zadd_test_key", 2))
end
zcard()

local function zrange()
    local result_2 = redis_util.zrange("zadd_test_key", 0, -1, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
zrange()

local function zrevrange()
    local result_2 = redis_util.zrevrange("zadd_test_key", 0, -1, 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
zrevrange()

local function zrangebyscore()
    local result_2 = redis_util.zrangebyscore("zadd_test_key", "0", "2", 2)
    for i, v in ipairs(result_2) do
        ngx.say(v)
    end
end
zrangebyscore()

local function zrem()
    local zrem_command = {"test_zadd_value1", "test_zadd_value2"}
    redis_util.zrem("zadd_test_key", zrem_command, 2)
end
zrem()