local common_util = {}

--判断数组中是否包含某个值(非对象数组，只限string、或number)
function common_util.contain(array, arg)
    local result = false;
    if (not array or not arg) or type(array) ~= "table" or (type(arg) ~= "number" and type(arg) ~= "string") then
        return result;
    end
    for i,v in ipairs(array) do
        if v == arg then
            result = true
        end
    end
    return result
end

--判断数组中是否包含其他数组中所有值(非对象数组，只限string、或number)
function common_util.contains(array, args)
    local result = false
    if (not array or not args) or type(array) ~= "table" or type(args) ~= "table" then
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

--按照指定字符分割字符串，并且返回table数组(非对象数组，只限string、或number)
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

--数组去重(非对象数组，只限string、或number)
function common_util.distinct(array)
    local result = nil
    if not array or type(array) ~= "table" then
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

return common_util