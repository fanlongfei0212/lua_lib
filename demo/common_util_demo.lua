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

local function common_uitl_is_array()
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
end

common_uitl_is_array()

local function common_uitl_kv_separate()
    local object = {filed_1="属性1", filed_2="属性2", filed_3="属性3"}
    local k_array, v_array = common_uitl.kv_separate(object)
    for i, v in ipairs(k_array) do
        ngx.say("分离出的k:" .. v)
    end
    for i, v in ipairs(v_array) do
        ngx.say("分离出的v:" .. v)
    end
end

common_uitl_kv_separate()