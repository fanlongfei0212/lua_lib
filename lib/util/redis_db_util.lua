local parser = require "redis.parser"
local common_util = require "common_util"

local _M = {}
local db_number = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}

--内部函数，校验db是否合法
local function check_db(db)
    if common_util.contain(db_number, db) then
        return true
    end
    return false
end

--根据redisKey的第一个字母进行数据库的计算，分库时使用
--入参:设置的key，必须是字符串
--返回:db
function _M.select_db(key)
    if not key or type(key) ~= "string" then
        return 0
    end
    return string.byte(string.sub(key, 1, 1)) % 16
end

--发送使用pipeline发送redis命令
--入参:redis命令table，table为数组，数组中的每条命令也是一个table的数组
--返回:解析后的redis返回结果
function _M.send_pipeline(commands)
    local result, error = nil, nil
    if not commands or type(commands) ~= "table" or not next(commands) or not common_util.is_array(commands) then
        error = "命令格式不正确"
        return error
    end
    local result_command = {}
    for i, v in ipairs(commands) do
        if not common_util.is_array(v) then
            error = "命令格式不正确"
            return error
        end
        table.insert( result_command, parser.build_query(v) )
    end
    local res = ngx.location.capture("/redis/pipeline/body?" .. #commands,
     { body = table.concat(result_command, "") })
     if res.status ~= 200 or not res.body then
        ngx.log(ngx.ERR, "redisPipeline执行错误，请排查:", "系统异常") 
        error = "redisPipeline执行错误"
        return error
     end
     result = parser.parse_replies(res.body, #commands)
     return result
end

--内部函数，redis命令执行前是否进行分库，给开放至外部的函数进行分库支持
--入参:
    --key为redis命令key值，依赖key值进行分库的索引计算
    --commands为分库以后要执行的redis命令
    --is_return为是否需要返回值，非查询命令则不需要返回，值类型为布尔
    --db为指定的数据库索引，值为number，如果db为nil则根据key值进行数据库索引的自动计算
local function switch_db_exec_command(key, commands, is_return, db)
    if db ~= nil and (type(db) ~= "number" or not check_db(db)) then
        ngx.log(ngx.ERR, "非法的数据库值，无法进行数据库切换:", "请选择有效的数据库")
        return nil
    end
    if not db then
        db = _M.select_db(key)
    end
    table.insert(commands, 1, {"select", db} )
    local result = _M.send_pipeline(commands)
    if is_return then
        return result[2][1]
    end
end

--set指令
--入参:redis命令table，table为对象，对象的属性为key、value
--返回:无返回
function _M.set(set_command, db)
    if set_command and type(set_command) == "table" and next(set_command) and not common_util.is_array(set_command) and set_command.key and set_command.value then
        local pipeline_commands = {{"set", set_command.key, set_command.value}}
        switch_db_exec_command(set_command.key, pipeline_commands, false, db)
    end
end

--get指令
--入参:key
--返回:查询结果(字符串)
function _M.get(key, db)
    local result = nil
    if key and type(key) == "string" then
        local pipeline_commands = {{"get", key}}
        result = switch_db_exec_command(key, pipeline_commands, true, db)
    end
    return result
end

--del指令
--入参:redis命令table，table为数组
--返回:无
function _M.del(keys, db)
    if keys and type(keys) == "table" and next(keys) and common_util.is_array(keys) then
        local pipeline_commands = {}
        local temp = {"del"}
        for i, v in ipairs(keys) do
            table.insert(temp, v)
        end
        table.insert(pipeline_commands, temp)
        switch_db_exec_command(key, pipeline_commands, false, db)
    end
end

--mset指令 (mset分库具有局限性，如果key的开头不一致的话，这代表着在进行select之后，无法使用mset指令将所有的key-value用这一个命令进行写入，所以，mset分库只支持手动指定数据库，并不能进行自动计算，如果db不传，则默认为0)
--入参:redis命令table，table为数组，数组中为对象，对象的属性为key、value
--返回:无返回
function _M.mset(mset_command, db)
    if mset_command and type(mset_command) == "table" and next(mset_command) and common_util.is_array(mset_command) then
        local pipeline_commands = {}
        local temp = {"mset"}
        for i, v in ipairs(mset_command) do
            if not v.key or not v.value or type(v.key) ~= "string" or type(v.value) ~= "string" then
                return
            end
            table.insert(temp, v.key)
            table.insert(temp, v.value)
        end
        table.insert(pipeline_commands, temp)
        if not db or type(db) ~= "number" or not check_db(db) then
            db = 0
        end
        switch_db_exec_command(nil, pipeline_commands, false, db)
    end
end

--mget指令 (mget分库具有局限性，如果key的开头不一致的话，这代表着在进行select之后，无法使用mget指令将所有的key-value用这一个命令进行读取，所以，mget分库只支持手动指定数据库，并不能进行自动计算，如果db不传，则默认为0)
--入参:redis命令table，table为数组，数组中为key
--返回:查询结果（数组）
function _M.mget(keys, db)
    local result = nil
    if not keys or type(keys) ~= "table" or not next(keys) or not common_util.is_array(keys) then
        return result
    end
    local pipeline_commands = {}
    local temp = {"mget"}
    for i, v in ipairs(keys) do
        if not v or type(v) ~= "string" then
            return
        end
        table.insert(temp, v)
    end
    table.insert(pipeline_commands, temp)
    if not db or type(db) ~= "number" or not check_db(db) then
        db = 0
    end
    result = switch_db_exec_command(nil, pipeline_commands, true, db)
    return result
end

--hset指令
--入参:redis命令table，table为对象，对象的属性为key、filed、value
--返回:无
function _M.hset(hset_command, db)
    if hset_command and type(hset_command) == "table" and next(hset_command) and not common_util.is_array(hset_command) and hset_command.key and hset_command.filed and hset_command.value then
        local pipeline_commands = {{"hset", hset_command.key, hset_command.filed, hset_command.value}}
        switch_db_exec_command(hset_command.key, pipeline_commands, false, db)
    end
end

--hget指令
--入参:redis命令table，table为对象，对象的属性为key、filed
--返回:查询结果（字符串）
function _M.hget(hget_command, db)
    local result = nil
    if not hget_command or not type(hget_command) == "table" or not next(hget_command) or common_util.is_array(hget_command) or not hget_command.key or not hget_command.filed then
        return result
    end
    local pipeline_commands = {{"hget", hget_command.key, hget_command.filed}}
    result = switch_db_exec_command(hget_command.key, pipeline_commands, true, db)
    return result
end

--hmset指令
--入参:key和redis命令table，table为对象，key为hmset中key值，hmset_command为对象数组，对象的属性为filed、value
--返回:无
function _M.hmset(key, hmset_command, db)
    if not key or type(key) ~= "string" then
        return
    end
    if hmset_command and type(hmset_command) == "table" and next(hmset_command) and common_util.is_array(hmset_command) then
        local pipeline_commands = {}
        local temp = {"hmset", key}
        for i, v in ipairs(hmset_command) do
            if not v.filed or not v.value then
                return
            end
            table.insert(temp, v.filed)
            table.insert(temp, v.value)
        end
        table.insert(pipeline_commands, temp)
        switch_db_exec_command(key, pipeline_commands, false, db)
    end
end

--hmget指令
--入参:key为hmget中key值，fileds为数组
--返回:查询结果（table）
function _M.hmget(key, fileds, db)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    if not fileds or type(fileds) ~= "table" or not next(fileds) or not common_util.is_array(fileds) then
        return result
    end
    local pipeline_commands = {}
    local temp = {"hmget", key}
    for i, v in ipairs(fileds) do
        if not v then
            return result
        end
        table.insert(temp, v)
    end
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    return result
end

--hdel指令
--入参:key为hmset中key值，fileds为数组
--返回:无
function _M.hdel(key, fileds, db)
    if not key or type(key) ~= "string" then
        return
    end
    if not fileds or type(fileds) ~= "table" or not next(fileds) or not common_util.is_array(fileds) then
        return
    end
    local pipeline_commands = {}
    local temp = {"hdel", key}
    for i, v in ipairs(fileds) do
        if not v then
            return
        end
        table.insert(temp, v)
    end
    table.insert(pipeline_commands, temp)
    switch_db_exec_command(key, pipeline_commands, false, db)
end

--lpush指令
--入参:key为lpush中key值，values为值数组
--返回:无
function _M.lpush(key, values, db)
    if not key or type(key) ~= "string" then
        return
    end
    if not values or type(values) ~= "table" or not next(values) or not common_util.is_array(values) then
        return
    end
    local pipeline_commands = {}
    local temp = {"lpush", key}
    for i, v in ipairs(values) do
        if not v then
            return
        end
        table.insert(temp, v)
    end
    table.insert(pipeline_commands, temp)
    switch_db_exec_command(key, pipeline_commands, false, db)
end

--lrange指令
--入参:key为lrange的key，start为开始位置，en为结束位置，start和en只能是数字
--返回:查询结果（table）
function _M.lrange(key, start, en, db)
    local result = nil
    if not key or type(key) ~= "string" or not start or not en or type(start) ~= "number" or type(en) ~= "number" then
        return result
    end
    local pipeline_commands = {}
    local temp = {"lrange", key, start, en}
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    return result
end

--lindex指令
--入参:key为lindex的key，index为索引
--返回:查询结果（字符串）
function _M.lindex(key, index, db)
    local result = nil
    if not key or type(key) ~= "string" or not index or type(index) ~= "number" then
        return result
    end
    local pipeline_commands = {}
    local temp = {"lindex", key, index}
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    return result
end

--llen指令
--入参:key为llen的key
--返回:查询结果（数字）
function _M.llen(key, db)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    local pipeline_commands = {}
    local temp = {"llen", key}
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    return result
end

--lrem指令
--入参:key为lrem的key，count为删除数量以及方向，value为要删除的值
--                   count > 0 : 从表头开始向表尾搜索，移除与 VALUE 相等的元素，数量为 COUNT
--                   count < 0 : 从表尾开始向表头搜索，移除与 VALUE 相等的元素，数量为 COUNT 的绝对值
--                   count = 0 : 移除表中所有与 VALUE 相等的值
--返回:无
function _M.lrem(key, count, value, db)
    if key and type(key) == "string" and count and type(count) == "number" and value and type(value) == "string" then
        local pipeline_commands = {}
        local temp = {"lrem", key, count, value}
        table.insert(pipeline_commands, temp)
        switch_db_exec_command(key, pipeline_commands, false, db)
    end
end

--sadd指令
--入参:key为sadd的key，values为table数组
--返回:无
function _M.sadd(key, values, db)
    if not key or type(key) ~= "string" then
        return
    end
    if not values or type(values) ~= "table" or not next(values) or not common_util.is_array(values) then
        return
    end
    local pipeline_commands = {}
    local temp = {"sadd", key}
    for i, v in ipairs(values) do
        if not v then
            return
        end
        table.insert(temp, v)
    end
    table.insert(pipeline_commands, temp)
    switch_db_exec_command(key, pipeline_commands, false, db)
end

--smembers指令
--入参:key为smembers的key
--返回:查询结果（table）
function _M.smembers(key, db)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    local pipeline_commands = {}
    local temp = {"smembers", key}
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    return result
end

--scard指令
--入参:key为scard的key
--返回:查询结果（数字）
function _M.scard(key, db)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    local pipeline_commands = {}
    local temp = {"scard", key}
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    return result
end

--内部函数，在set集合中取交集、并集、差集使用
local function internal_set(redis_command, key, keys, db)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    if not keys or type(keys) ~="table" or not next(keys) or not common_util.is_array(keys) then
        return result
    end
    local pipeline_commands = {}
    local temp = {redis_command, key}
    for i, v in ipairs(keys) do
        if not v then
            return result
        end
        table.insert(temp, v)
    end
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    return result
end

--sdiff指令
--入参:key为要获取差集的set集合的key，keys为对比哪些set集合，keys为数组
--返回:查询结果（table）
function _M.sdiff(key, keys, db)
    return internal_set("sdiff", key, keys, db)
end

--sinter指令
--入参:key为要获取交集的set集合的key，keys为对比哪些set集合，keys为数组
--返回:查询结果（table）
function _M.sinter(key, keys, db)
    return internal_set("sinter", key, keys, db)
end

--sunion指令
--入参:key为要获取并集的set集合的key，keys为对比哪些set集合，keys为数组
--返回:查询结果（table）
function _M.sunion(key, keys, db)
    return internal_set("sunion", key, keys, db)
end

--sismember指令
--入参:key指定的set集合，value为要检测是否存在的元素
--返回:查询结果（布尔）
function _M.sismember(key, value, db)
    local result = nil
    if not key or type(key) ~= "string" or not value or type(value) ~= "string" then
        return result
    end
    local pipeline_commands = {}
    local temp = {"sismember", key, value}
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    if result == 1 then
        return true
    else
        return false
    end
end

--内部函数，在set集合中随机返回元素时使用
local function internal_random(redis_command, key, count, count_is_negative, db)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    local pipeline_commands = {}
    local temp = {redis_command, key}
    if count and type(count) == "number" then
        if count_is_negative then
            table.insert(temp, count)
        else
            if count > 0 then
                table.insert(temp, count)
            end
        end
    end
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    return result
end

--srandmember指令
--入参:key指定的set集合，count为要返回的参数条件（可选），count为数字
--                    如果 count 为正数，且小于集合基数，那么命令返回一个包含 count 个元素的数组，数组中的元素各不相同。如果 count 大于等于集合基数，那么返回整个集合
--                    如果 count 为负数，那么命令返回一个数组，数组中的元素可能会重复出现多次，而数组的长度为 count 的绝对值
--返回:查询结果（table）
function _M.srandmember(key, count, db)
    return internal_random("srandmember", key, count, true, db)
end

--spop指令
--入参:key指定的set集合，count为要返回以及删除的参数条件（可选），count为数字但不能是负数并且必须大于0
--                    如果 count 为正数，且小于集合基数，那么命令返回一个包含 count 个元素的数组并且将返回元素删除，数组中的元素各不相同。如果 count 大于等于集合基数，那么返回整个集合，并且将元素删除
--返回:查询结果（table）
function _M.spop(key, count, db)
    return internal_random("spop", key, count, false, db)
end

--srem指令
--入参:key指定的set集合，values为要及删除的值，values为table数组
--返回:无
function _M.srem(key, values, db)
    if not key or type(key) ~= "string" then
        return
    end
    if not values or type(values) ~= "table" or not next(values) or not common_util.is_array(values) then
        return
    end
    local pipeline_commands = {}
    local temp = {"srem", key}
    for i, v in ipairs(values) do
        if not v then
            return
        end
        table.insert(temp, v)
    end
    table.insert(pipeline_commands, temp)
    switch_db_exec_command(key, pipeline_commands, false, db)
end

--zadd指令
--入参:key指定的zset集合，zset_command为table数组，数组中是对象，对象属性为score、value
--返回:无
function _M.zadd(key, zset_command, db)
    if not key or type(key) ~= "string" then
        return
    end
    if not zset_command or type(zset_command) ~= "table" or not next(zset_command) or not common_util.is_array(zset_command) then
        return
    end
    local pipeline_commands = {}
    local temp = {"zadd", key}
    for i, v in ipairs(zset_command) do
        if not v.score or not v.value then
            return
        end
        table.insert(temp, v.score)
        table.insert(temp, v.value)
    end
    table.insert(pipeline_commands, temp)
    switch_db_exec_command(key, pipeline_commands, false, db)
end

--zcard指令
--入参:key为指定的zset集合
--返回:查询结果（数字）
function _M.zcard(key, db)
    local result = nil
    if not key or type(key) ~= "string" then
        return result
    end
    local pipeline_commands = {}
    local temp = {"zcard", key}
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    return result
end

--内部接口，zset通过zrange以及zrevrange时使用
local function internal_range(redis_command, key, start, stop, db)
    local result = nil
    if not key or type(key) ~= "string" or not start or type(start) ~= "number" or not stop or type(stop) ~= "number" then
        return result
    end
    local pipeline_commands = {}
    local temp = {redis_command, key, start, stop}
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    return result
end

--zrange指令
--入参:key为指定的zset集合，start为开始下标参数，stop为结束下标参数，start和stop都为数字
--返回:查询结果（table）
function _M.zrange(key, start, stop, db)
    return internal_range("zrange", key, start, stop, db)
end

--zrevrange指令
--入参:key为指定的zset集合，start为开始下标参数，stop为结束下标参数，start和stop都为数字
--返回:查询结果（table）
function _M.zrevrange(key, start, stop, db)
    return internal_range("zrevrange", key, start, stop, db)
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
function _M.zrangebyscore(key, min, max, db)
    local result = nil
    if not key or type(key) ~= "string" or not min or type(min) ~= "string" or not max or type(max) ~= "string" then
        return result
    end
    if not check_parameter(min) or not check_parameter(max) then
        return result
    end
    local pipeline_commands = {}
    local temp = {"zrangebyscore", key, min, max}
    table.insert(pipeline_commands, temp)
    result = switch_db_exec_command(key, pipeline_commands, true, db)
    return result
end

--zrem指令
--入参:key为指定的zset集合，values为要删除的值，values为数组table，数组中的值为字符串
--返回:无
function _M.zrem(key, values, db)
    if not key or type(key) ~= "string" or not values or not next(values) or not common_util.is_array(values) then
        return
    end
    local pipeline_commands = {}
    local temp = {"zrem", key}
    for i, v in ipairs(values) do
        if not v or type(v) ~= "string" then
            return
        end
        table.insert(temp, v)
    end
    table.insert(pipeline_commands, temp)
    switch_db_exec_command(key, pipeline_commands, false, db)
end

return _M