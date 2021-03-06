local request_args = require "request_args"

--执行demo时，测试其中一个函数时，需要把其他函数调用注释掉

-- 获取请求url参数
local function request_get_args()
    local args_names = {"parameter1", "parameter2"}
    local args_values = request_args.get_args_by_name(args_names)

    for k, v in pairs(args_values) do
        ngx.say("get请求中参数-->" .. k .. "的值:" .. v);
    end
end

request_get_args()

--获取请求body参数(form表单格式)
local function request_post_args()
    local args_names = {"parameter1", "parameter2"}
    local args_values = request_args.post_args_by_name(args_names)

    for k, v in pairs(args_values) do
        ngx.say("post请求中参数-->" .. k .. "的值:" .. v);
    end
end

request_post_args()

--获取请求body参数(json格式)
local function request_json_args()
    local args_table = request_args.json_args_by_name()

    ngx.say("post请求body体中的json参数-->parameter1的值:" .. args_table.parameter1)
    ngx.say("post请求body体中的json参数-->parameter2的值:" .. args_table.parameter2)
end

request_json_args()