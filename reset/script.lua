p_http_port = property.getNumber("HTTP Port")

g_btn = false

function onTick()
    local btn = input.getBool(1)
    if not g_btn and btn then
        async.httpGet(p_http_port, "/stop")
    end
    g_btn = btn
end
