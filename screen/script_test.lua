local test_decl = {}

local function assertEqual(name, want, got)
    if type(want) ~= type(got) then
        error(string.format("type(%s): expected %s, got %s", name, type(want), type(got)))
    end

    if type(want) ~= "table" then
        if want ~= got then
            error(string.format("%s: expected %q, got %q", name, want, got))
        end
        return
    end

    for key in pairs(want) do
        local child = string.format("%s[%q]", name, key)
        assertEqual(child, want[key], got[key])
    end
    for key in pairs(got) do
        local child = string.format("%s[%q]", name, key)
        assertEqual(child, want[key], got[key])
    end
end

function test_decl.testOnTick(t)
    local tt = {
        {
            in_input_bool_tbl = {[1] = false},
            in_active = true,
            want_active = false,
            want_http = false,
            want_draw_screen = nil,
            want_draw_error = nil,
            want_draw_cursor_blink_time = 120,
        },
        {
            in_input_bool_tbl = {[1] = true},
            in_active = false,
            want_active = true,
            want_http = true,
            want_draw_screen = {},
            want_draw_error = "dummy error",
            want_draw_cursor_blink_time = 119,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.env.property._number_tbl = {["HTTP Port"] = 52149}
        t.fn()

        t.env.input._bool_tbl = tc.in_input_bool_tbl
        t.env.g_active = tc.in_active
        t.env.g_http = false
        t.env.g_draw_screen = {}
        t.env.g_draw_error = "dummy error"
        t.env.g_draw_cursor_blink = t.env.blinkNew(60, 30, 30)
        t.env.onTick()
        assertEqual("g_active", tc.want_active, t.env.g_active)
        assertEqual("g_http", tc.want_http, t.env.g_http)
        assertEqual("g_draw_screen", tc.want_draw_screen, t.env.g_draw_screen)
        assertEqual("g_draw_error", tc.want_draw_error, t.env.g_draw_error)
        assertEqual("g_draw_cursor_blink.time", tc.want_draw_cursor_blink_time, t.env.g_draw_cursor_blink.time)
    end
end

function test_decl.testHttpReply(t)
    local tt = {
        {
            in_active = false,
            in_resp = "error message",
            want_http = false,
            want_draw_screen = nil,
            want_draw_error = nil,
            want_async_log = {},
        },
        {
            in_active = true,
            in_resp = "error message",
            want_http = true,
            want_draw_screen = nil,
            want_draw_error = "error message",
            want_async_log = {{52149, "/screen"}},
        },
        {
            in_active = false,
            in_resp = table.concat({
                "%SWTSCRN", -- signature
                "\x01", -- cursor.visible
                "\x01", -- cursor.blink
                "\x01", -- cursor.shape
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cursor.row
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cursor.col
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- rows
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cols
            }),
            want_http = false,
            want_draw_screen = nil,
            want_draw_error = nil,
            want_async_log = {},
        },
        {
            in_active = true,
            in_resp = table.concat({
                "%SWTSCRN", -- signature
                "\x01", -- cursor.visible
                "\x01", -- cursor.blink
                "\x01", -- cursor.shape
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cursor.row
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cursor.col
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- rows
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cols
            }),
            want_http = true,
            want_draw_screen = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
            want_draw_error = nil,
            want_async_log = {{52149, "/screen"}},
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.env.property._number_tbl = {["HTTP Port"] = 52149}
        t.fn()

        t.env.g_active = tc.in_active
        t.env.g_http = true
        t.env.httpReply(52149, "/screen", tc.in_resp)

        assertEqual("g_http", tc.want_http, t.env.g_http)
        assertEqual("g_draw_screen", tc.want_draw_screen, t.env.g_draw_screen)
        assertEqual("g_draw_error", tc.want_draw_error, t.env.g_draw_error)
        assertEqual("async._log", tc.want_async_log, t.env.async._log)
    end
end

function test_decl.testHttpTrigger(t)
    local tt = {
        {
            in_property_number_tbl = {["HTTP Port"] = 52149},
            in_http = false,
            want_async_log = {{52149, "/screen"}},
        },
        {
            in_property_number_tbl = {["HTTP Port"] = 52149},
            in_http = true,
            want_async_log = {},
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.env.property._number_tbl = tc.in_property_number_tbl
        t.fn()

        t.env.g_http = tc.in_http
        t.env.httpTrigger()
        assertEqual("async._log", tc.want_async_log, t.env.async._log)
        assertEqual("g_http", true, t.env.g_http)
    end
end

function test_decl.testParseHTTPResponse(t)
    local tt = {
        {
            in_resp = "",
            want_scr = nil,
            want_err = "sw-term: invalid response",
        },
        {
            in_resp = "~~~ error string ~~~",
            want_scr = nil,
            want_err = "~~~ error string ~~~",
        },
        {
            in_resp = "~~~ error string ~~~\x01",
            want_scr = nil,
            want_err = "sw-term: invalid response",
        },
        {
            in_resp = table.concat({
                "%SWTSCRN", -- signature
                "\x01", -- cursor.visible
                "\x01", -- cursor.blink
                "\x01", -- cursor.shape
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cursor.row
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cursor.col
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- rows
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cols
            }),
            want_scr = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
            want_err = nil,
        },
        {
            in_resp = table.concat({
                "%SWTSCRN", -- signature
                "\x01", -- cursor.visible
                "\x01", -- cursor.blink
                "\x01", -- cursor.shape
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cursor.row
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cursor.col
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- rows
                "\x01\x01\x01\x01\x01\x01\x01\x00", -- cols -- !
            }),
            want_scr = nil,
            want_err = "sw-term: unescape failed",
        },
        {
            in_resp = table.concat({
                "%SWTSCRN", -- signature
                "\x01", -- cursor.visible
                "\x01", -- cursor.blink
                "\x01", -- cursor.shape
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cursor.row
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- cursor.col
                "\x01\x01\x01\x01\x01\x01\x01\x01", -- rows
                "\x01\x01\x01\x01\x01\x01\x01", -- cols -- !
            }),
            want_scr = nil,
            want_err = "sw-term: decode failed",
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        local got_scr, got_err = t.env.parseHTTPResponse(tc.in_resp)
        assertEqual("scr", tc.want_scr, got_scr)
        assertEqual("err", tc.want_err, got_err)
    end
end

function test_decl.testUnescapeZero(t)
    local tt = {
        {
            in_bin = "",
            want_ret = "",
        },
        {
            in_bin = "\x00",
            want_ret = nil,
        },
        {
            in_bin = "\x01",
            want_ret = "\x00",
        },
        {
            in_bin = "\xFE",
            want_ret = "\xFD",
        },
        {
            in_bin = "\xFF",
            want_ret = nil,
        },
        {
            in_bin = "\xFF\x00",
            want_ret = nil,
        },
        {
            in_bin = "\xFF\xFD",
            want_ret = nil,
        },
        {
            in_bin = "\xFF\xFE",
            want_ret = "\xFE",
        },
        {
            in_bin = "\xFF\xFF",
            want_ret = "\xFF",
        },
        {
            in_bin = "\x01\xFE\xFF\xFE\xFF\xFF",
            want_ret = "\x00\xFD\xFE\xFF",
        },
        {
            in_bin = "\x01\xFE\xFF\xFE\xFF\xFF\x00",
            want_ret = nil,
        },
        {
            in_bin = "\x01\xFE\xFF\xFE\xFF\xFF\xFF",
            want_ret = nil,
        },
        {
            in_bin = "\x01\xFE\xFF\xFE\xFF\xFF\xFF\xFD",
            want_ret = nil,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        local got_ret = t.env.unescapeZero(tc.in_bin)
        assertEqual("ret", tc.want_ret, got_ret)
    end
end

function test_decl.testDecodeDo(t)
    local tt = {
        {
            in_bin = "",
            want_ret = nil,
        },
        {
            in_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cols
            }),
            want_ret = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },
        {
            in_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cols
                "\x00", -- dummy
            }),
            want_ret = nil,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_dec_err = true
        t.env.g_dec_bin = nil
        t.env.g_dec_pos = nil
        local got_ret = t.env.decodeDo(tc.in_bin)

        assertEqual("g_dec_err", false, t.env.g_dec_err)
        assertEqual("g_dec_bin", "", t.env.g_dec_bin)
        assertEqual("g_dec_pos", 1, t.env.g_dec_pos)
        assertEqual("ret", tc.want_ret, got_ret)
    end
end

function test_decl.testDecodeScreen(t)
    local tt = {
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cols
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 36,
            want_ret = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x01", -- cursor.visible   -- !
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cols
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 36,
            want_ret = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = true,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x01", -- cursor.blink -- !
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cols
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 36,
            want_ret = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = true,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\xFF", -- cursor.shape -- !
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cols
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 36,
            want_ret = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0xFF,
                    row = 1,
                    col = 1,
                },
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x02\x00\x00\x00\x00\x00\x00\x00", -- cursor.row   -- !
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cols
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 36,
            want_ret = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 3,
                    col = 1,
                },
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x02\x00\x00\x00\x00\x00\x00\x00", -- cursor.col   -- !
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cols
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 36,
            want_ret = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 3,
                },
            },
        },
        {
            in_dec_err = true,  -- !
            in_dec_bin = table.concat({
                "\xFF", -- cursor.visible   -- !
                "\xFF", -- cursor.blink -- !
                "\xFF", -- cursor.shape -- !
                "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", -- cursor.row   -- !
                "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", -- cursor.col   -- !
                "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", -- rows -- !
                "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", -- cols -- !
            }),
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- rows -- !
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cols
            }),
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 36,
            want_ret = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- cols -- !
            }),
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 36,
            want_ret = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },

        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- cols
                "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", -- attrs
                "\x02\x00\x00\x00", -- fg
                "\x04\x00\x00\x00", -- bg
                "\x00", -- width
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- chars
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 65,
            want_ret = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- cols
                "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", -- attrs
                "\x00\x01\x02\x03", -- fg   -- !
                "\x04\x00\x00\x00", -- bg
                "\x00", -- width
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- chars
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 65,
            want_ret = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {rgb = {0x01, 0x02, 0x03}},
                            bg = {},
                            chars = "",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- cols
                "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", -- attrs
                "\x02\x00\x00\x00", -- fg
                "\x00\x01\x02\x03", -- bg   -- !
                "\x00", -- width
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- chars
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 65,
            want_ret = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {rgb = {0x01, 0x02, 0x03}},
                            chars = "",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- cols
                "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", -- attrs
                "\x02\x00\x00\x00", -- fg
                "\x04\x00\x00\x00", -- bg
                "\x00", -- width
                "\x03\x00\x00\x00\x00\x00\x00\x00abc",  -- chars    -- !
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 68,
            want_ret = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "abc",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },

        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x02\x00\x00\x00\x00\x00\x00\x00", -- rows
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- cols

                "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", -- attrs
                "\x02\x00\x00\x00", -- fg
                "\x04\x00\x00\x00", -- bg
                "\x00", -- width
                "\x01\x00\x00\x00\x00\x00\x00\x00A",    -- chars

                "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", -- attrs
                "\x02\x00\x00\x00", -- fg
                "\x04\x00\x00\x00", -- bg
                "\x00", -- width
                "\x01\x00\x00\x00\x00\x00\x00\x00B",    -- chars
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 96,
            want_ret = {
                rows = 2,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = table.concat({
                "\x00", -- cursor.visible
                "\x00", -- cursor.blink
                "\x00", -- cursor.shape
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.row
                "\x00\x00\x00\x00\x00\x00\x00\x00", -- cursor.col
                "\x01\x00\x00\x00\x00\x00\x00\x00", -- rows -- !
                "\x02\x00\x00\x00\x00\x00\x00\x00", -- cols -- !

                "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", -- attrs
                "\x02\x00\x00\x00", -- fg
                "\x04\x00\x00\x00", -- bg
                "\x00", -- width
                "\x01\x00\x00\x00\x00\x00\x00\x00A",    -- chars

                "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", -- attrs
                "\x02\x00\x00\x00", -- fg
                "\x04\x00\x00\x00", -- bg
                "\x00", -- width
                "\x01\x00\x00\x00\x00\x00\x00\x00B",    -- chars
            }),
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 96,
            want_ret = {
                rows = 1,
                cols = 2,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = 0,
                    row = 1,
                    col = 1,
                },
            },
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_dec_err = tc.in_dec_err
        t.env.g_dec_bin = tc.in_dec_bin
        t.env.g_dec_pos = tc.in_dec_pos
        local got_ret = t.env.decodeScreen()

        assertEqual("g_dec_err", tc.want_dec_err, t.env.g_dec_err)
        assertEqual("g_dec_pos", tc.want_dec_pos, t.env.g_dec_pos)
        assertEqual("ret", tc.want_ret, got_ret)
    end
end

function test_decl.testDecodeCell(t)
    local tt = {
        {
            in_dec_err = false,
            in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x00\x04\x05\x06\x00\x03\x00\x00\x00\x00\x00\x00\x00abc",
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 33,
            want_ret = {
                fg = {rgb = {0x01, 0x02, 0x03}},
                bg = {rgb = {0x04, 0x05, 0x06}},
                chars = "abc",
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x00\x04\x05\x06\x00\x03\x00\x00\x00\x00\x00\x00\x00abc", -- !
            in_dec_pos = 2, -- !
            want_dec_err = false,
            want_dec_pos = 34,
            want_ret = {
                fg = {rgb = {0x01, 0x02, 0x03}},
                bg = {rgb = {0x04, 0x05, 0x06}},
                chars = "abc",
            },
        },
        {
            in_dec_err = true,  -- !
            in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x00\x04\x05\x06\x00\x03\x00\x00\x00\x00\x00\x00\x00abc",
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = {
                fg = {},
                bg = {},
                chars = "",
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",    -- !
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = {
                fg = {},
                bg = {},
                chars = "",
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02",    -- !
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 13,
            want_ret = {
                fg = {},
                bg = {},
                chars = "",
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x00\x04\x05",    -- !
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 17,
            want_ret = {
                fg = {rgb = {0x01, 0x02, 0x03}},
                bg = {},
                chars = "",
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x00\x04\x05\x06",    -- !
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 21,
            want_ret = {
                fg = {rgb = {0x01, 0x02, 0x03}},
                bg = {rgb = {0x04, 0x05, 0x06}},
                chars = "",
            },
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x00\x04\x05\x06\x00\x03\x00\x00\x00\x00\x00\x00\x00ab",  -- !
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 30,
            want_ret = {
                fg = {rgb = {0x01, 0x02, 0x03}},
                bg = {rgb = {0x04, 0x05, 0x06}},
                chars = "",
            },
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_dec_err = tc.in_dec_err
        t.env.g_dec_bin = tc.in_dec_bin
        t.env.g_dec_pos = tc.in_dec_pos
        local got_ret = t.env.decodeCell()

        assertEqual("g_dec_err", tc.want_dec_err, t.env.g_dec_err)
        assertEqual("g_dec_pos", tc.want_dec_pos, t.env.g_dec_pos)
        assertEqual("ret", tc.want_ret, got_ret)
    end
end

function test_decl.testDecodeCursor(t)
    local tt = {
            {
                    in_dec_err = false,
                    in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
                    in_dec_pos = 1,
                    want_dec_err = false,
                    want_dec_pos = 20,
                    want_ret = {
                            visible = false,
                            blink = false,
                            shape = 0,
                            row = 1,
                            col = 1,
                    },
            },
            {
                    in_dec_err = false,
                    in_dec_bin = "\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",        -- !
                    in_dec_pos = 1,
                    want_dec_err = false,
                    want_dec_pos = 20,
                    want_ret = {
                            visible = true,
                            blink = false,
                            shape = 0,
                            row = 1,
                            col = 1,
                    },
            },
            {
                    in_dec_err = false,
                    in_dec_bin = "\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",        -- !
                    in_dec_pos = 1,
                    want_dec_err = false,
                    want_dec_pos = 20,
                    want_ret = {
                            visible = false,
                            blink = true,
                            shape = 0,
                            row = 1,
                            col = 1,
                    },
            },
            {
                    in_dec_err = false,
                    in_dec_bin = "\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",        -- !
                    in_dec_pos = 1,
                    want_dec_err = false,
                    want_dec_pos = 20,
                    want_ret = {
                            visible = false,
                            blink = false,
                            shape = 2,
                            row = 1,
                            col = 1,
                    },
            },
            {
                    in_dec_err = false,
                    in_dec_bin = "\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",        -- !
                    in_dec_pos = 1,
                    want_dec_err = false,
                    want_dec_pos = 20,
                    want_ret = {
                            visible = false,
                            blink = false,
                            shape = 0,
                            row = 4,
                            col = 1,
                    },
            },
            {
                    in_dec_err = false,
                    in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00",        -- !
                    in_dec_pos = 1,
                    want_dec_err = false,
                    want_dec_pos = 20,
                    want_ret = {
                            visible = false,
                            blink = false,
                            shape = 0,
                            row = 1,
                            col = 5,
                    },
            },
            {
                    in_dec_err = false,
                    in_dec_bin = "\x00\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00",        -- !
                    in_dec_pos = 1,
                    want_dec_err = false,
                    want_dec_pos = 20,
                    want_ret = {
                            visible = false,
                            blink = false,
                            shape = 0,
                            row = 0,
                            col = 1,
                    },
            },
            {
                    in_dec_err = false,
                    in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF",        -- !
                    in_dec_pos = 1,
                    want_dec_err = false,
                    want_dec_pos = 20,
                    want_ret = {
                            visible = false,
                            blink = false,
                            shape = 0,
                            row = 1,
                            col = 0,
                    },
            },
            {
                    in_dec_err = true,  -- !
                    in_dec_bin = "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF",        -- !
                    in_dec_pos = 1,
                    want_dec_err = true,
                    want_dec_pos = 1,
                    want_ret = {
                            visible = false,
                            blink = false,
                            shape = 0,
                            row = 1,
                            col = 1,
                    },
            },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_dec_err = tc.in_dec_err
        t.env.g_dec_bin = tc.in_dec_bin
        t.env.g_dec_pos = tc.in_dec_pos
        local got_ret = t.env.decodeCursor()

        assertEqual("g_dec_err", tc.want_dec_err, t.env.g_dec_err)
        assertEqual("g_dec_pos", tc.want_dec_pos, t.env.g_dec_pos)
        assertEqual("ret", tc.want_ret, got_ret)
    end
end

function test_decl.testDecodeColor(t)
    local tt = {
        {
            in_dec_err = false,
            in_dec_bin = "\x01\x02\x03\x04",
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 5,
            want_ret = {idx = 2},
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x00\x02\x03\x04",    -- !
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 5,
            want_ret = {rgb = {0x02, 0x03, 0x04}},
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x03\x02\x03\x04",    -- !
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 5,
            want_ret = {},
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x05\x02\x03\x04",    -- !
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 5,
            want_ret = {},
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x02\x02\x03\x04",    -- !
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 5,
            want_ret = {},
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x04\x02\x03\x04",    -- !
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 5,
            want_ret = {},
        },
        {
            in_dec_err = true,    -- !
            in_dec_bin = "\x01\x02\x03\x04",
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = {},
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x01\x02\x03",    -- !
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = {},
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_dec_err = tc.in_dec_err
        t.env.g_dec_bin = tc.in_dec_bin
        t.env.g_dec_pos = tc.in_dec_pos
        local got_ret = t.env.decodeColor()

        assertEqual("g_dec_err", tc.want_dec_err, t.env.g_dec_err)
        assertEqual("g_dec_pos", tc.want_dec_pos, t.env.g_dec_pos)
        assertEqual("ret", tc.want_ret, got_ret)
    end
end

function test_decl.testDecodeString(t)
    local tt = {
        {
            in_dec_err = false,
            in_dec_bin = "\x03\x00\x00\x00\x00\x00\x00\x00abc",
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 12,
            want_ret = "abc",
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x00\x00\x00\x00\x00\x00\x00\x00abc",    -- !
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 9,
            want_ret = "",
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x03\x00\x00\x00\x00\x00\x00\x00abcd",    -- !
            in_dec_pos = 1,
            want_dec_err = false,
            want_dec_pos = 12,
            want_ret = "abc",
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x00\x03\x00\x00\x00\x00\x00\x00\x00abc",    -- !
            in_dec_pos = 2,                                            -- !
            want_dec_err = false,
            want_dec_pos = 13,
            want_ret = "abc",
        },
        {
            in_dec_err = true,    -- !
            in_dec_bin = "\x03\x00\x00\x00\x00\x00\x00\x00abc",
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = "",
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x03\x00\x00\x00\x00\x00\x00",    -- !
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = "",
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x04\x00\x00\x00\x00\x00\x00\x00abc",    -- !
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 9,
            want_ret = "",
        },
        {
            in_dec_err = false,
            in_dec_bin = "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFFabc",    -- !
            in_dec_pos = 1,
            want_dec_err = true,
            want_dec_pos = 9,
            want_ret = "",
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_dec_err = tc.in_dec_err
        t.env.g_dec_bin = tc.in_dec_bin
        t.env.g_dec_pos = tc.in_dec_pos
        local got_ret = t.env.decodeString()

        assertEqual("g_dec_err", tc.want_dec_err, t.env.g_dec_err)
        assertEqual("g_dec_pos", tc.want_dec_pos, t.env.g_dec_pos)
        assertEqual("ret", tc.want_ret, got_ret)
    end
end

function test_decl.testDecodeElem(t)
    local tt = {
        {
            in_dec_err = false,
            in_dec_bin = "",
            in_dec_pos = 1,
            in_fmt = "",
            want_dec_err = false,
            want_dec_pos = 1,
            want_ret = {},
        },
        {
            in_dec_err = true,    -- !
            in_dec_bin = "",
            in_dec_pos = 1,
            in_fmt = "",
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = {},
        },
        {
            in_dec_err = false,
            in_dec_bin = "",
            in_dec_pos = 1,
            in_fmt = "!1<x",    -- !
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = {},
        },

        {
            in_dec_err = false,
            in_dec_bin = "\x01\x02\03\x04\x05\x06\x07\x08\x09",
            in_dec_pos = 1,
            in_fmt = "!1<Bi8",
            want_dec_err = false,
            want_dec_pos = 10,
            want_ret = {0x01, 0x0908070605040302},
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x00\x01\x02\03\x04\x05\x06\x07\x08\x09",    -- !
            in_dec_pos = 2,                                            -- !
            in_fmt = "!1<Bi8",
            want_dec_err = false,
            want_dec_pos = 11,
            want_ret = {0x01, 0x0908070605040302},
        },
        {
            in_dec_err = true,    -- !
            in_dec_bin = "\x01\x02\03\x04\x05\x06\x07\x08\x09",
            in_dec_pos = 1,
            in_fmt = "!1<Bi8",
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = {0x00, 0x0000000000000000},
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x01\x02\03\x04\x05\x06\x07\x08",    -- !
            in_dec_pos = 1,
            in_fmt = "!1<Bi8",
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = {0x00, 0x0000000000000000},
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x01\x02\03\x04\x05\x06\x07\x08\x09",
            in_dec_pos = 2,    -- !
            in_fmt = "!1<Bi8",
            want_dec_err = true,
            want_dec_pos = 2,
            want_ret = {0x00, 0x0000000000000000},
        },
        {
            in_dec_err = false,
            in_dec_bin = "\x01\x02\03\x04\x05\x06\x07\x08\x09",
            in_dec_pos = 1,
            in_fmt = "!1<Bi8x",    -- !
            want_dec_err = true,
            want_dec_pos = 1,
            want_ret = {0x00, 0x0000000000000000},
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_dec_err = tc.in_dec_err
        t.env.g_dec_bin = tc.in_dec_bin
        t.env.g_dec_pos = tc.in_dec_pos
        local got_ret = t.env.decodeElem(tc.in_fmt)

        assertEqual("g_dec_err", tc.want_dec_err, t.env.g_dec_err)
        assertEqual("g_dec_pos", tc.want_dec_pos, t.env.g_dec_pos)
        assertEqual("ret", tc.want_ret, got_ret)
    end
end

function test_decl.testDrawSet(t)
    local tt = {
        {
            in_scr = nil,
            in_err = nil,
            want_draw_screen = nil,
            want_draw_error = nil,
        },
        {
            in_scr = {
                rows = 1,
                cols = 1,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_err = nil,
            want_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            want_draw_error = nil,
        },
        {
            in_scr = nil,
            in_err = "error message",
            want_draw_screen = nil,
            want_draw_error = "error message",
        },
        {
            in_scr = {
                rows = 1,
                cols = 1,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_err = "error message",
            want_draw_screen = nil,
            want_draw_error = "error message",
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_draw_screen = {
            rows = 1,
            cols = 1,
            cell = {},
            cursor = {
                visible = true,
                blink = false,
                shape = t.env.c_cursor_shape_block,
                row = 1,
                col = 1,
            },
        }
        t.env.g_draw_error = "dummy error"
        t.env.drawSet(tc.in_scr, tc.in_err)
        assertEqual("g_draw_screen", tc.want_draw_screen, t.env.g_draw_screen)
        assertEqual("g_draw_error", tc.want_draw_error, t.env.g_draw_error)
    end
end

function test_decl.testDrawSetScreen(t)
    t:reset()
    t.fn()

    local tt = {
        {
            in_draw_screen = nil,
            in_scr = nil,
            want_draw_cursor_blink_time = 120,
        },
        {
            in_draw_screen = nil,
            in_scr = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            want_draw_cursor_blink_time = 120,
        },
        {
            in_draw_screen = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_scr = nil,
            want_draw_cursor_blink_time = 120,
        },

        {
            in_draw_screen = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_scr = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            want_draw_cursor_blink_time = 1,
        },
        {
            in_draw_screen = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_scr = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            want_draw_cursor_blink_time = 120,
        },
        {
            in_draw_screen = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_scr = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = true,   -- !
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            want_draw_cursor_blink_time = 120,
        },
        {
            in_draw_screen = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_scr = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_underline, -- !
                    row = 1,
                    col = 1,
                },
            },
            want_draw_cursor_blink_time = 120,
        },
        {
            in_draw_screen = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_scr = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 2,    -- !
                    col = 1,
                },
            },
            want_draw_cursor_blink_time = 120,
        },
        {
            in_draw_screen = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_scr = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 2,    -- !
                },
            },
            want_draw_cursor_blink_time = 120,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_draw_screen = tc.in_draw_screen
        t.env.g_draw_cursor_blink = t.env.blinkNew(60, 30, 30)
        t.env.g_draw_cursor_blink.time = 1
        t.env.drawSetScreen(tc.in_scr)
        assertEqual("g_draw_screen", tc.in_scr, t.env.g_draw_screen)
        assertEqual("g_draw_cursor_blink.time", tc.want_draw_cursor_blink_time, t.env.g_draw_cursor_blink.time)
    end
end

function test_decl.testDrawTick(t)
    local tt = {
        {
            in_draw_screen = nil,
            want_draw_cursor_blink_time = 120,
        },
        {
            in_draw_screen = {},
            want_draw_cursor_blink_time = 119,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_draw_screen = tc.in_draw_screen
        t.env.g_draw_cursor_blink = t.env.blinkNew(60, 30, 30)
        t.env.drawTick()
        assertEqual("g_draw_cursor_blink.time", tc.want_draw_cursor_blink_time, t.env.g_draw_cursor_blink.time)
    end
end

function test_decl.testDrawError(t)
    local tt = {
        {
            in_draw_error = nil,
            want_screen_log = {},
        },
        {
            in_draw_error = "",
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0xFF}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {0, 0, 288, 160, ""}},
            },
        },
        {
            in_draw_error = "error message",
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0xFF}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {0, 0, 288, 160, "error message"}},
            },
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_draw_error = tc.in_draw_error
        t.env.drawError()
        assertEqual("screen._log", tc.want_screen_log, t.env.screen._log)
    end
end

function test_decl.testDrawScreen(t)
    t:reset()
    t.fn()

    local tt = {
        {
            in_property_number_tbl = {},
            in_draw_screen = nil,
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {},
        },

        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 0,
                cols = 0,
                cell = {},
                cursor = {
                    visible = true,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
            },
        },

        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {idx = 1}, -- !
                            bg = {},
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0x40, 0x40}},
                {fn = "drawText", args = {0, 0, "A"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {idx = 1}, -- !
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0xC4, 0x40, 0x40}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "", -- !
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "\t",   -- !
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "AA",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0x3B, 0x3B, 0x3B}},
                {fn = "drawText", args = {0, 0, "A"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {rgb = {0x01, 0x02, 0x03}},    -- !
                            bg = {rgb = {0x04, 0x05, 0x06}},    -- !
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0xFB, 0xFA, 0xF9}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xFE, 0xFD, 0xFC}},
                {fn = "drawText", args = {0, 0, "A"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = true,   -- !
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 31,  -- !
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0x3B, 0x3B, 0x3B}},
                {fn = "drawText", args = {0, 0, "A"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = true,   -- !
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 30,  -- !
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_underline, -- !
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawText", args = {0, 0, "_"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {rgb = {0x01, 0x02, 0x03}},    -- !
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_underline, -- !
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x01, 0x02, 0x03}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0xFE, 0xFD, 0xFC}},
                {fn = "drawText", args = {0, 0, "_"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_barleft,   -- !
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawLine", args = {0, 0, 0, 6}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {rgb = {0x01, 0x02, 0x03}},    -- !
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_barleft,   -- !
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x01, 0x02, 0x03}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0xFE, 0xFD, 0xFC}},
                {fn = "drawLine", args = {0, 0, 0, 6}},
            },
        },
        {
            in_property_number_tbl = {
                ["Offset X"] = 1,   -- !
                ["Offset Y"] = 2,   -- !
            },
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {1, 2, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {1, 2, "A"}},
            },
        },
        {
            in_property_number_tbl = {
                ["Offset X"] = 1,   -- !
                ["Offset Y"] = 2,   -- !
            },
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_underline, -- !
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {1, 2, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {1, 2, "A"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawText", args = {1, 2, "_"}},
            },
        },
        {
            in_property_number_tbl = {
                ["Offset X"] = 1,   -- !
                ["Offset Y"] = 2,   -- !
            },
            in_draw_screen = {
                rows = 1,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_barleft,   -- !
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {1, 2, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {1, 2, "A"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawLine", args = {1, 2, 1, 8}},
            },
        },

        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 2,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 6, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 6, "B"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 2,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0x3B, 0x3B, 0x3B}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 6, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 6, "B"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 2,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_underline, -- !
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawText", args = {0, 0, "_"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 6, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 6, "B"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 2,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_barleft,   -- !
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawLine", args = {0, 0, 0, 6}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 6, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 6, "B"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 2,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 2,    -- !
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {0, 6, 5, 6}},
                {fn = "setColor", args = {0x3B, 0x3B, 0x3B}},
                {fn = "drawText", args = {0, 6, "B"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 2,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_underline, -- !
                    row = 2,    -- !
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 6, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 6, "B"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawText", args = {0, 6, "_"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 2,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_barleft,   -- !
                    row = 2,    -- !
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 6, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 6, "B"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawLine", args = {0, 6, 0, 12}},
            },
        },
        {
            in_property_number_tbl = {
                ["Offset X"] = 1,   -- !
                ["Offset Y"] = 2,   -- !
            },
            in_draw_screen = {
                rows = 2,
                cols = 1,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                    },
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {1, 2, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {1, 2, "A"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {1, 8, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {1, 8, "B"}},
            },
        },

        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 2,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {5, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {5, 0, "B"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 2,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0x3B, 0x3B, 0x3B}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {5, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {5, 0, "B"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 2,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_underline, -- !
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawText", args = {0, 0, "_"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {5, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {5, 0, "B"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 2,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_barleft,   -- !
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawLine", args = {0, 0, 0, 6}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {5, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {5, 0, "B"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 2,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 2,    -- !
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {5, 0, 5, 6}},
                {fn = "setColor", args = {0x3B, 0x3B, 0x3B}},
                {fn = "drawText", args = {5, 0, "B"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 2,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_underline, -- !
                    row = 1,
                    col = 2,    -- !
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {5, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {5, 0, "B"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawText", args = {5, 0, "_"}},
            },
        },
        {
            in_property_number_tbl = {},
            in_draw_screen = {
                rows = 1,
                cols = 2,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = true, -- !
                    blink = false,
                    shape = t.env.c_cursor_shape_barleft,   -- !
                    row = 1,
                    col = 2,    -- !
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {0, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {0, 0, "A"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {5, 0, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {5, 0, "B"}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawLine", args = {5, 0, 5, 6}},
            },
        },
        {
            in_property_number_tbl = {
                ["Offset X"] = 1,   -- !
                ["Offset Y"] = 2,   -- !
            },
            in_draw_screen = {
                rows = 1,
                cols = 2,
                cell = {
                    {
                        {
                            fg = {},
                            bg = {},
                            chars = "A",
                        },
                        {
                            fg = {},
                            bg = {},
                            chars = "B",
                        },
                    },
                },
                cursor = {
                    visible = false,
                    blink = false,
                    shape = t.env.c_cursor_shape_block,
                    row = 1,
                    col = 1,
                },
            },
            in_draw_cursor_blink = {
                want = 60,
                on = 30,
                off = 30,
                time = 120
            },
            want_screen_log = {
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawClear", args = {}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {1, 2, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {1, 2, "A"}},
                {fn = "setColor", args = {0x00, 0x00, 0x00}},
                {fn = "drawRectF", args = {6, 2, 5, 6}},
                {fn = "setColor", args = {0xC4, 0xC4, 0xC4}},
                {fn = "drawText", args = {6, 2, "B"}},
            },
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.env.property._number_tbl = tc.in_property_number_tbl
        t.fn()

        t.env.g_draw_screen = tc.in_draw_screen
        t.env.g_draw_cursor_blink = tc.in_draw_cursor_blink
        t.env.drawScreen()
        assertEqual("screen._log", tc.want_screen_log, t.env.screen._log)
    end
end

function test_decl.testConvertRGB(t)
    t:reset()
    t.fn()

    local tt = {
        {
            in_col = {},
            want_rgb = nil,
        },
        {
            in_col = {idx = -1},
            want_rgb = nil,
        },
        {
            in_col = {idx = 0},
            want_rgb = t.env.c_color_palette[0],
        },
        {
            in_col = {idx = 3},
            want_rgb = t.env.c_color_palette[3],
        },
        {
            in_col = {idx = 7},
            want_rgb = t.env.c_color_palette[7],
        },
        {
            in_col = {idx = 8},
            want_rgb = nil,
        },
        {
            in_col = {rgb = {0x01, 0x02, 0x03}},
            want_rgb = {0x01, 0x02, 0x03},
        },
        {
            in_col = {
                idx = 0,
                rgb = {0x01, 0x02, 0x03},
            },
            want_rgb = t.env.c_color_palette[0],
        },
    }

    for _, tc in ipairs(tt) do
        local got_rgb = t.env.convertRGB(tc.in_col, t.env.c_color_palette)
        assertEqual("rgb", tc.want_rgb, got_rgb)
    end
end

function test_decl.testInvertRGB(t)
    t:reset()
    t.fn()

    local in_col = {0x00, 0x5A, 0xFF}
    local want_col = {0xFF, 0xA5, 0x00}
    local got_col = t.env.invertRGB(in_col)
    assertEqual("col", want_col, got_col)
end

function test_decl.testBlink(t)
    t:reset()
    t.fn()

    local blink = t.env.blinkNew(1, 2, 4)
    assertEqual("check", true, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", true, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", true, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", false, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", false, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", false, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", false, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", true, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", true, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", false, t.env.blinkCheck(blink))

    t.env.blinkReset(blink)
    assertEqual("check", true, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", true, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", true, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", false, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", false, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", false, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", false, t.env.blinkCheck(blink))

    t.env.blinkTick(blink)
    assertEqual("check", true, t.env.blinkCheck(blink))
end

function test_decl.testBlinkNew(t)
    t:reset()
    t.fn()

    local want_blink = {
        wait = 1,
        on = 2,
        off = 4,
        time = 7,
    }
    local got_blink = t.env.blinkNew(1, 2, 4)

    assertEqual("blink", want_blink, got_blink)
end

function test_decl.testBlinkTick(t)
    local tt = {
        {
            in_wait = 1,
            in_on = 2,
            in_off = 4,
            in_time = 7,
            want_time = 6,
        },
        {
            in_wait = 1,
            in_on = 2,
            in_off = 4,
            in_time = 2,
            want_time = 1,
        },
        {
            in_wait = 1,
            in_on = 2,
            in_off = 4,
            in_time = 1,
            want_time = 6,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        local blink = t.env.blinkNew(tc.in_wait, tc.in_on, tc.in_off)
        blink.time = tc.in_time
        t.env.blinkTick(blink)
        assertEqual("time", tc.want_time, blink.time)
    end
end

function test_decl.testBlinkCheck(t)
    local tt = {
        {
            in_wait = 1,
            in_on = 2,
            in_off = 4,
            in_time = 5,
            want_ret = true,
        },
        {
            in_wait = 1,
            in_on = 2,
            in_off = 4,
            in_time = 4,
            want_ret = false,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        local blink = t.env.blinkNew(tc.in_wait, tc.in_on, tc.in_off)
        blink.time = tc.in_time
        local got_ret = t.env.blinkCheck(blink)
        assertEqual("ret", tc.want_ret, got_ret)
    end
end

local function buildMockInput()
    local input = {
        _bool_tbl = {},
    }

    function input.getBool(index)
        return input._bool_tbl[index] or false
    end

    return input
end

local function buildMockProperty()
    local property = {
        _number_tbl = {},
    }

    function property.getNumber(label)
        return property._number_tbl[label] or 0
    end

    return property
end

local function buildMockScreen()
    local screen = {
        _w = 288,
        _h = 160,
        _log = {},
    }

    function screen.getWidth()
        return screen._w
    end

    function screen.getHeight()
        return screen._h
    end

    function screen.setColor(...)
        table.insert(screen._log, {
            fn = "setColor",
            args = {...},
        })
    end

    function screen.drawClear(...)
        table.insert(screen._log, {
            fn = "drawClear",
            args = {...},
        })
    end

    function screen.drawTextBox(...)
        table.insert(screen._log, {
            fn = "drawTextBox",
            args = {...},
        })
    end

    function screen.drawRectF(...)
        table.insert(screen._log, {
            fn = "drawRectF",
            args = {...},
        })
    end

    function screen.drawText(...)
        table.insert(screen._log, {
            fn = "drawText",
            args = {...},
        })
    end

    function screen.drawLine(...)
        table.insert(screen._log, {
            fn = "drawLine",
            args = {...},
        })
    end

    return screen
end

local function buildMockAsync()
    local async = {
        _log = {},
    }

    function async.httpGet(...)
        table.insert(async._log, {...})
    end

    return async
end

local function buildT()
    local env = {}
    local fn, err = loadfile("script.lua", "t", env)
    if fn == nil then
        error(err)
    end

    local t = {
        env = env,
        fn = fn,
        reset = function(self)
            for k, _ in pairs(self.env) do
                self.env[k] = nil
            end

            self.env.pairs = pairs
            self.env.ipairs = ipairs
            self.env.next = next
            self.env.tostring = tostring
            self.env.tonumber = tonumber
            self.env.type = type
            self.env.math = math
            self.env.table = table
            self.env.string = string

            self.env.input = buildMockInput()
            self.env.property = buildMockProperty()
            self.env.screen = buildMockScreen()
            self.env.async = buildMockAsync()
        end,
    }
    t:reset()
    return t
end

local function testAll()
    local test_list = {}
    for test_name, test_fn in pairs(test_decl) do
        table.insert(test_list, {test_name, test_fn})
    end
    table.sort(test_list, function(x, y)
        return x[1] < y[1]
    end)

    local function msgh(err)
        return {
            err = err,
            traceback = debug.traceback(),
        }
    end

    local t = buildT()
    local s = "PASS"
    for _, test_entry in ipairs(test_list) do
        local test_name, test_fn = table.unpack(test_entry)

        t:reset()
        local is_success, err = xpcall(test_fn, msgh, t)
        if is_success then
            io.write(string.format("PASS %s\n", test_name))
        else
            io.write(string.format("FAIL %s\n", test_name))
            io.write(string.format("%s\n", err.err))
            io.write(string.format("%s\n", err.traceback))
            s = "FAIL"
        end
    end
    io.write(string.format("%s\n", s))
end

testAll()
