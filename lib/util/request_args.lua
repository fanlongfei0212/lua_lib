local common_util = require "common_util"
local dkjson = require "dkjson"
local request_args = {}

--获取请求url参数
--入参:参数名称table
--返回:返回参数名称以及对应的值table
function request_args.get_args_by_name(arg_names)
    local args, err = ngx.req.get_uri_args();
    local result = {}
    if arg_names then
        for i, filed in ipairs(arg_names) do
            for k, v in pairs(args) do
                if k == filed then
                    if type(v) == "table" then
                        result[filed] = table.concat( v, "," )
                    else
                        result[filed] = v
                    end
                end
            end
        end
    end
    if not next(result) then
        result = nil
    end
    return result
end

--获取请求body体参数（form表单格式）
--入参:参数名称table
--返回:返回参数名称以及对应的值table
function request_args.post_args_by_name(arg_names)
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()
    local result = {}
    if args and arg_names and type(arg_names) == "table" and common_util.is_array(arg_names) and next(arg_names) then
        for i, filed in ipairs(arg_names) do
            for k, v in pairs(args) do
                if k == filed then
                    if type(v) == "table" then
                        result[filed] = table.concat( v, "," )
                    else
                        result[filed] = v
                    end
                end
            end
        end
    end
    if not next(result) then
        result = nil
    end
    return result
end

--获取请求body体参数（json格式）
--入参:参数名称table
--返回:将json格式的参数序列化为table
function request_args.json_args_by_name()
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()
    local result = {}
    if args then
        for json, boolean in pairs(args) do
            result = dkjson.decode(json)
        end
    end
    if not result or not next(result) then
        result = nil
    end
    return result
end

return request_args