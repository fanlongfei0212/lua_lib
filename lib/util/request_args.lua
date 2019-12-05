local request_args = {}

--获取请求中指定参数的值
--入参:参数名称table
--返回:返回参数名称已经对应的值table
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

--获取post请求参数
--入参:参数名称table
--返回:返回参数名称已经对应的值table
function request_args.post_args_by_name(arg_names)
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()
    local result = {}
    if args then
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

return request_args