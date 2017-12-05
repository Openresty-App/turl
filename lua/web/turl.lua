-- turl app
local ngx = require "ngx"
local cjson = require "cjson.safe"


ngx.update_time()
local request_st = ngx.now()

if ngx.var.uri == "/" then
    ngx.log(ngx.INFO, string.format("[null] not found"))
    ngx.exit(ngx.HTTP_NOT_FOUND)
    return
end

local turl = ngx.var.uri
ngx.log(ngx.INFO, string.format("[REQ] [uri] %s", turl))

if string.sub(turl, 1, 1) == "/" then
    turl = string.sub(turl, 2)
end

local res = ngx.location.capture("/short_url", {
                                   method = ngx.HTTP_GET,
                                   args = {tinyurl=turl},
                                   body = nil
                               })

if res.status == 200 then
    ngx.log(ngx.INFO, string.format("short_url response:%s", res.body))
    local body_json = cjson.decode(res.body)
    if body_json and body_json.status == 200 then
        ngx.header.location = body_json.longurl
        --性能统计
        ngx.update_time()
        local response_st = ngx.now()
        ngx.log(ngx.NOTICE, string.format("[turl] response time:%s", response_st-request_st))
        --性能统计 END
        ngx.exit(ngx.HTTP_MOVED_TEMPORARILY)
        return
    end
end

ngx.log(ngx.INFO, string.format("[%s] not found", turl))

--性能统计
ngx.update_time()
local response_st = ngx.now()
ngx.log(ngx.NOTICE, string.format("[turl] response time:%s", response_st-request_st))
--性能统计 END

ngx.exit(ngx.HTTP_NOT_FOUND)
