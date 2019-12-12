local common_uitl = require "common_util"

local function common_uitl_contain_demo()
    local source = {"source", "source2", "source3"}
    local target_true = "source"
    local target_false = "target"

    ngx.say(common_uitl.contain(source, target_true))
    ngx.say(common_uitl.contain(source, target_false))
end

common_uitl_contain_demo()

local function common_uitl_contains_demo()
    local source = {"source", "source2", "source3"}
    local target_true = {"source2", "source3"}
    local target_false = {"source2", "tatget"} 

    ngx.say(common_uitl.contains(source, target_true))
    ngx.say(common_uitl.contains(source, target_false))
end

common_uitl_contains_demo()

local function common_uitl_split_demo()
    local source = "1,2,3,4,5,6,7"
    local result = common_uitl.split(source, ",")
    for i, v in ipairs(result) do
        ngx.say("下标" .. i .. "的值:" .. v)
    end
end

common_uitl_split_demo()

local function common_uitl_distinct_demo()
    local source = {"1", "2", "3", "4", "4", "5", "5"}
    local result = common_uitl.distinct(source)
    for i, v in ipairs(result) do
        ngx.say("下标" .. i .. "的值:" .. v)
    end
end

common_uitl_distinct_demo()