local parser = require "redis.parser"
local common_util = require "common_util"

local _M = {}

--set指令
--入参:redis命令table，table为对象，对象的属性为key、value
--返回:无返回
function _M.set(set_command)
    if set_command and type(set_command) == "table" and next(set_command) and not common_util.is_array(set_command) and set_command.key and set_command.value then
        ngx.location.capture("/redis/set?key=" .. set_command.key .. "&value=" .. set_command.value)
    end
end

--get指令
--入参:key
--返回:查询结果(字符串)
function _M.get(key)
    local result = nil
    if key and type(key) == "string" then
        local res = ngx.location.capture("/redis/get?key=" .. key)
        if res.status == 200 and res.body then
            result = parser.parse_reply(res.body)
        end
    end
    return result
end

--del指令
--入参:redis命令table，table为数组
--返回:无
function _M.del(keys)
    if keys and type(keys) == "table" and next(keys) and common_util.is_array(keys) then
        local commands = "del"
        for i, v in ipairs(keys) do
            if not v then
                return
            end
            commands = commands .. " " .. v
        end
        ngx.location.capture("/redis/single?commands=" .. commands .. '\r\n')
    end
end

--mset指令
--入参:redis命令table，table为数组，数组中为对象，对象的属性为key、value
--返回:无返回
function _M.mset(mset_command)
    if mset_command and type(mset_command) == "table" and next(mset_command) and common_util.is_array(mset_command) then
        local commands = "mset"
        for i, v in ipairs(mset_command) do
            if not v.key or not v.value or type(v.key) ~= "string" or type(v.value) ~= "string" then
                return
            end
            commands = commands .. " " .. v.key .. " " .. v.value
        end
        local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    end
end

--mget指令
--入参:redis命令table，table为数组，数组中为key
--返回:查询结果（数组）
function _M.mget(keys)
    local result = nil
    if not keys or type(keys) ~= "table" or not next(keys) or not common_util.is_array(keys) then
        return result
    end
    local commands = "mget"
    for i, v in ipairs(keys) do
        if not v or type(v) ~= "string" then
            return
        end
        commands = commands .. " " .. v
    end
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--hset指令
--入参:redis命令table，table为对象，对象的属性为key、filed、value
--返回:无
function _M.hset(hset_command)
    if hset_command and type(hset_command) == "table" and next(hset_command) and not common_util.is_array(hset_command) and hset_command.key and hset_command.filed and hset_command.value then
        local commands = "hset " .. hset_command.key .. " " .. hset_command.filed .. " " .. hset_command.value .. "\r\n"
        ngx.location.capture("/redis/single?commands=" .. commands)
    end
end

--hget指令
--入参:redis命令table，table为对象，对象的属性为key、filed
--返回:查询结果（字符串）
function _M.hget(hget_command)
    local result = nil
    if not hget_command or not type(hget_command) == "table" or not next(hget_command) or common_util.is_array(hget_command) or not hget_command.key or not hget_command.filed then
        return result
    end
    local commands = "hget " .. hget_command.key .. " " .. hget_command.filed .. "\r\n"
    local res = ngx.location.capture("/redis/single?commands=" .. commands)
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--hmset指令
--入参:key和redis命令table，table为对象，key为hmset中key值，hmset_command为对象数组，对象的属性为filed、value
--返回:无
function _M.hmset(key, hmset_command)
    if not key or type(key) ~= "string" then
        return
    end
    if hmset_command and type(hmset_command) == "table" and next(hmset_command) and common_util.is_array(hmset_command) then
        local commands = "hmset " .. key
        for i, v in ipairs(hmset_command) do
            if not v.filed or not v.value then
                return
            end
            commands = commands .. " " .. v.filed .. " " .. v.value
        end
        ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    end
end

--hmget指令
--入参:key为hmget中key值，fileds为数组
--返回:查询结果（table）
function _M.hmget(key, fileds)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    if not fileds or type(fileds) ~= "table" or not next(fileds) or not common_util.is_array(fileds) then
        return result
    end
    local commands = "hmget " .. key
    for i, v in ipairs(fileds) do
        if not v then
            return result
        end
        commands = commands .. " " .. v
    end
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--hdel指令
--入参:key为hmset中key值，fileds为数组
--返回:无
function _M.hdel(key, fileds)
    if not key or type(key) ~= "string" then
        return
    end
    if not fileds or type(fileds) ~= "table" or not next(fileds) or not common_util.is_array(fileds) then
        return
    end
    local commands = "hdel " .. key
    for i, v in ipairs(fileds) do
        if not v then
            return
        end
        commands = commands .. " " .. v
    end
    ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n") 
end

--lpush指令
--入参:key为lpush中key值，values为值数组
--返回:无
function _M.lpush(key, values)
    if not key or type(key) ~= "string" then
        return
    end
    if not values or type(values) ~= "table" or not next(values) or not common_util.is_array(values) then
        return
    end
    local commands = "lpush " .. key
    for i, v in ipairs(values) do
        if not v then
            return
        end
        commands = commands .. " " .. v
    end
    ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
end

--lrange指令
--入参:key为lrange的key，start为开始位置，en为结束位置，start和en只能是数字
--返回:查询结果（table）
function _M.lrange(key, start, en)
    local result = nil
    if not key or type(key) ~= "string" or not start or not en or type(start) ~= "number" or type(en) ~= "number" then
        return result
    end
    local commands = "lrange " .. key .. " " .. start .. " " .. en
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--lindex指令
--入参:key为lindex的key，index为索引
--返回:查询结果（字符串）
function _M.lindex(key, index)
    local result = nil
    if not key or type(key) ~= "string" or not index or type(index) ~= "number" then
        return result
    end
    local commands = "lindex " .. key .. " " .. index
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--llen指令
--入参:key为llen的key
--返回:查询结果（数字）
function _M.llen(key)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    local commands = "llen " .. key
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--lrem指令
--入参:key为lrem的key，count为删除数量以及方向，value为要删除的值
--                   count > 0 : 从表头开始向表尾搜索，移除与 VALUE 相等的元素，数量为 COUNT
--                   count < 0 : 从表尾开始向表头搜索，移除与 VALUE 相等的元素，数量为 COUNT 的绝对值
--                   count = 0 : 移除表中所有与 VALUE 相等的值
--返回:无
function _M.lrem(key, count, value)
    if key and type(key) == "string" and count and type(count) == "number" and value and type(value) == "string" then
        local commands = "lrem " .. key .. " " .. count .. " " .. value
        ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    end
end

--sadd指令
--入参:key为sadd的key，values为table数组
--返回:无
function _M.sadd(key, values)
    if not key or type(key) ~= "string" then
        return
    end
    if not values or type(values) ~= "table" or not next(values) or not common_util.is_array(values) then
        return
    end
    local commands = "sadd " .. key
    for i, v in ipairs(values) do
        if not v then
            return
        end
        commands = commands.. " " .. v
    end
    ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
end

--smembers指令
--入参:key为smembers的key
--返回:查询结果（table）
function _M.smembers(key)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    local commands = "smembers " .. key
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--scard指令
--入参:key为scard的key
--返回:查询结果（数字）
function _M.scard(key)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    local commands = "scard " .. key
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--内部函数，在set集合中取交集、并集、差集使用
local function internal_set(redis_command, key, keys)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    if not keys or type(keys) ~="table" or not next(keys) or not common_util.is_array(keys) then
        return result
    end
    local commands = redis_command .. " " .. key
    for i, v in ipairs(keys) do
        if not v then
            return result
        end
        commands = commands .. " " .. v
    end
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--sdiff指令
--入参:key为要获取差集的set集合的key，keys为对比哪些set集合，keys为数组
--返回:查询结果（table）
function _M.sdiff(key, keys)
    return internal_set("sdiff", key, keys)
end

--sinter指令
--入参:key为要获取交集的set集合的key，keys为对比哪些set集合，keys为数组
--返回:查询结果（table）
function _M.sinter(key, keys)
    return internal_set("sinter", key, keys)
end

--sunion指令
--入参:key为要获取并集的set集合的key，keys为对比哪些set集合，keys为数组
--返回:查询结果（table）
function _M.sunion(key, keys)
    return internal_set("sunion", key, keys)
end

--sismember指令
--入参:key指定的set集合，value为要检测是否存在的元素
--返回:查询结果（布尔）
function _M.sismember(key, value)
    local result = nil
    if not key or type(key) ~= "string" or not value or type(value) ~= "string" then
        return result
    end
    local commands = "sismember " .. key .. " " .. value
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    if result == 1 then
        return true
    else
        return false
    end
end

--内部函数，在set集合中随机返回元素时使用
local function internal_random(redis_command, key, count, count_is_negative)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    local commands = redis_command .. " " .. key
    if count and type(count) == "number" then
        if count_is_negative then
            commands = commands .. " " .. count
        else
            if count > 0 then
                commands = commands .. " " .. count
            end
        end
    end
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        local temp_result = parser.parse_reply(res.body)
        if type(temp_result) == "string" then
            result = {}
            table.insert(result, temp_result)
        end
        if type(temp_result) == "table" then
            result = temp_result
        end
    end
    return result
end

--srandmember指令
--入参:key指定的set集合，count为要返回的参数条件（可选），count为数字
--                    如果 count 为正数，且小于集合基数，那么命令返回一个包含 count 个元素的数组，数组中的元素各不相同。如果 count 大于等于集合基数，那么返回整个集合
--                    如果 count 为负数，那么命令返回一个数组，数组中的元素可能会重复出现多次，而数组的长度为 count 的绝对值
--返回:查询结果（table）
function _M.srandmember(key, count)
    return internal_random("srandmember", key, count, true)
end

--spop指令
--入参:key指定的set集合，count为要返回以及删除的参数条件（可选），count为数字但不能是负数并且必须大于0
--                    如果 count 为正数，且小于集合基数，那么命令返回一个包含 count 个元素的数组并且将返回元素删除，数组中的元素各不相同。如果 count 大于等于集合基数，那么返回整个集合，并且将元素删除
--返回:查询结果（table）
function _M.spop(key, count)
    return internal_random("spop", key, count, false)
end

--srem指令
--入参:key指定的set集合，values为要及删除的值，values为table数组
--返回:无
function _M.srem(key, values)
    if not key or type(key) ~= "string" then
        return
    end
    if not values or type(values) ~= "table" or not next(values) or not common_util.is_array(values) then
        return
    end
    local commands = "srem " .. key
    for i, v in ipairs(values) do
        if not v then
            return
        end
        commands = commands .. " " .. v
    end
    ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
end

--zadd指令
--入参:key指定的zset集合，zset_command为table数组，数组中是对象，对象属性为score、value
--返回:无
function _M.zadd(key, zset_command)
    if not key or type(key) ~= "string" then
        return
    end
    if not zset_command or type(zset_command) ~= "table" or not next(zset_command) or not common_util.is_array(zset_command) then
        return
    end
    local commands = "zadd " .. key
    for i, v in ipairs(zset_command) do
        if not v.score or not v.value then
            return
        end
        commands = commands .. " " .. v.score .. " " .. v.value
    end
    ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
end

--zcard指令
--入参:key为指定的zset集合
--返回:查询结果（数字）
function _M.zcard(key)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    local commands = "zcard " .. key
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--内部接口，zset通过zrange以及zrevrange时使用
local function internal_range(redis_command, key, start, stop)
    local result = nil
    if not key or type(key) ~= "string" or not start or type(start) ~= "number" or not stop or type(stop) ~= "number" then
        return result
    end
    local commands = redis_command .. " " .. key .. " " .. start .. " " .. stop
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--zrange指令
--入参:key为指定的zset集合，start为开始下标参数，stop为结束下标参数，start和stop都为数字
--返回:查询结果（table）
function _M.zrange(key, start, stop)
    return internal_range("zrange", key, start, stop)
end

--zrevrange指令
--入参:key为指定的zset集合，start为开始下标参数，stop为结束下标参数，start和stop都为数字
--返回:查询结果（table）
function _M.zrevrange(key, start, stop)
    return internal_range("zrevrange", key, start, stop)
end

---内部函数，校验zrangebyscore使用
local function check_parameter(data)
    if #data == 1 then
        if string.find(data, "%d") then
            return true
        else
            return false
        end
    else
        if string.find(data, "%d") == 1 then
            if tonumber(string.sub(data, 1)) then
                return true
            else
                return false
            end
        else
            local temp = string.sub(data, 1, 1)
            if temp == "(" then
                if tonumber(string.sub(data, 2)) then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
    end
end

--zrangebyscore指令
--入参:key为指定的zset集合，min、max为最大以及最小区间，min、max为字符串，但是只能是数字类型的字符串或'('加数字类型的字符串
--返回:查询结果（table）
function _M.zrangebyscore(key, min, max)
    local result = nil
    if not key or type(key) ~= "string" or not min or type(min) ~= "string" or not max or type(max) ~= "string" then
        return result
    end
    if not check_parameter(min) or not check_parameter(max) then
        return result
    end
    local commands = "zrangebyscore " .. key .. " " .. min .. " " .. max
    local res = ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
    if res.status == 200 and res.body then
        result = parser.parse_reply(res.body)
    end
    return result
end

--zrem指令
--入参:key为指定的zset集合，values为要删除的值，values为数组table，数组中的值为字符串
--返回:无
function _M.zrem(key, values)
    if not key or type(key) ~= "string" or not values or not next(values) or not common_util.is_array(values) then
        return
    end
    local commands = "zrem " .. key
    for i, v in ipairs(values) do
        if not v or type(v) ~= "string" then
            return
        end
        commands = commands .. " " .. v
    end
    ngx.location.capture("/redis/single?commands=" .. commands .. "\r\n")
end

return _M