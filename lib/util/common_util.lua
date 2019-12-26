local common_util = {}

--判断数组中是否包含某个值(非对象，只限string、或number)
function common_util.contain(array, arg)
    local result = false;
    if (not array or not arg) or type(array) ~= "table" or not next(array) or not common_util.is_array(array) or (type(arg) ~= "number" and type(arg) ~= "string") then
        return result;
    end
    for i,v in ipairs(array) do
        if v == arg then
            result = true
        end
    end
    return result
end

--判断数组中是否包含其他数组中所有值(非对象，只限string、或number)
function common_util.contains(array, args)
    local result = false
    if (not array or not args) or type(array) ~= "table" or type(args) ~= "table" or not next(array) or not next(args) or not common_util.is_array(array) or not common_util.is_array(array) then
        return result
    end
    for i,v in ipairs(args) do
        if not common_util.contain(array, v) then
            return result
        end
    end
    result = true
    return result
end

--按照指定字符分割字符串，并且返回table数组
function common_util.split(source, str)
    local result = {}
    if not source or not str then
        result = nil
        return result
    end
    string.gsub(source,'[^'..str..']+',function ( w )
        table.insert(result, w)
    end)
    return result
end

--数组去重(非对象，只限string、或number)
function common_util.distinct(array)
    local result = nil
    if not array or type(array) ~= "table" or not common_util.is_array(array) or not next(array) then
        return result
    end
    result = {}
    for i, v in ipairs(array) do
        if not common_util.contain(result, v) then
            table.insert( result, v )
        end
    end
    return result
end

--判断table是否是数组
--入参:要验证的table
--返回:数组->true 非数组->false
function common_util.is_array(data)
    if not data or type(data) ~= "table" or not next(data) then
        return false
    end
    local data_length = #data
    for i, v in pairs(data) do
        if type(i) ~= "number" or i > data_length then
            return false
        end
    end
    return true
end

--将对象的属性和值分离成两个单独的数组
--入参:table(对象,对象的属性值只能输number或string,否则返回nil)
--返回:k_array v_array
function common_util.kv_separate(data)
    local k_array, v_array = nil, nil
    if not data or type(data) ~= "table" or common_util.is_array(data) or not next(data) then
        return nil
    end
    k_array, v_array = {}, {}
    for k, v in pairs(data) do
        if type(v) ~= "string" and type(v) ~= "number" then
            return nil
        end
        table.insert( k_array, k )
        table.insert( v_array, v )
    end
    return k_array, v_array
end

return common_util