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

function test_decl.testKeyboardTickOffset(t)
    local tt = {
        {
            in_touch_w = 96,
            in_touch_h = 32,
            want_keyboard_offset_x = 0,
            want_keyboard_offset_y = 0,
        },
        {
            in_touch_w = 160,
            in_touch_h = 96,
            want_keyboard_offset_x = 32,
            want_keyboard_offset_y = 64,
        },
        {
            in_touch_w = 1,
            in_touch_h = 1,
            want_keyboard_offset_x = -47,
            want_keyboard_offset_y = -31,
        },
        {
            in_touch_w = 1/0,
            in_touch_h = 1/0,
            want_keyboard_offset_x = 0,
            want_keyboard_offset_y = 0,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_keyboard_offset_x = nil
        t.env.g_keyboard_offset_y = nil
        t.env.g_touch_w = tc.in_touch_w
        t.env.g_touch_h = tc.in_touch_h
        t.env.keyboardTickOffset()

        assertEqual("g_keyboard_offset_x", tc.want_keyboard_offset_x, t.env.g_keyboard_offset_x)
        assertEqual("g_keyboard_offset_y", tc.want_keyboard_offset_y, t.env.g_keyboard_offset_y)
    end
end

function test_decl.testKeyboardTickKey(t)
    local tt = {
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {},
            in_http_cnt = 0,
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },

        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 12,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 13,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 18,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 19,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 12,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 13,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 19,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 20,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,  -- !
            in_touch_first_y = 80,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 44,  -- !
            in_touch_first_y = 80,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 45,  -- !
            in_touch_first_y = 80,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 50,  -- !
            in_touch_first_y = 80,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 51,  -- !
            in_touch_first_y = 80,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,  -- !
            in_touch_first_y = 76,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,  -- !
            in_touch_first_y = 77,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,  -- !
            in_touch_first_y = 83,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,  -- !
            in_touch_first_y = 84,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x01, -- !
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=A&mod=1"},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x06, -- !
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=6"},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 1,    -- !
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 1,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 29,   -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 30,   -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
            },
            in_http_cnt = 1,    -- !
            in_touch_first_time = 30,   -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },

        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
                {box = {40, 19, 5, 6}, plain_key = "b", shift_key = "B"},
            },
            in_http_cnt = 0,
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {},
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
                {box = {40, 19, 5, 6}, plain_key = "b", shift_key = "B"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
                {box = {40, 19, 5, 6}, plain_key = "b", shift_key = "B"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 42,  -- !
            in_touch_first_y = 22,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_async_log = {
                {52149, "/keyboard?key=b&mod=0"},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_key = "a", shift_key = "A"},
                {box = {40, 19, 5, 6}, plain_key = "b", shift_key = "B"},
            },
            in_http_cnt = 0,
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 42, -- !
            in_touch_second_y = 22, -- !
            want_async_log = {
                {52149, "/keyboard?key=a&mod=0"},
                {52149, "/keyboard?key=b&mod=0"},
            },
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.env.property._number_tbl["HTTP Port"] = 52149
        t.fn()

        t.env.g_keyboard_offset_x = tc.in_keyboard_offset_x
        t.env.g_keyboard_offset_y = tc.in_keyboard_offset_y
        t.env.g_keyboard_mod = tc.in_keyboard_mod
        t.env.g_keyboard_keydef_list = tc.in_keyboard_keydef_list
        t.env.g_http_cnt = tc.in_http_cnt
        t.env.g_touch_first_time = tc.in_touch_first_time
        t.env.g_touch_first_x = tc.in_touch_first_x
        t.env.g_touch_first_y = tc.in_touch_first_y
        t.env.g_touch_second_time = tc.in_touch_second_time
        t.env.g_touch_second_x = tc.in_touch_second_x
        t.env.g_touch_second_y = tc.in_touch_second_y
        t.env.keyboardTickKey()

        assertEqual("async._log", tc.want_async_log, t.env.async._log)
    end
end

function test_decl.testKeyboardTickMod(t)
    local tt = {
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {},
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x00,
        },

        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x00,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 8,   -- !
            in_touch_first_y = 22,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 1,    -- !
            in_touch_first_x = 8,   -- !
            in_touch_first_y = 22,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 0,   -- !
            in_touch_first_y = 22,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x00,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 1,   -- !
            in_touch_first_y = 22,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 22,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 16,  -- !
            in_touch_first_y = 22,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x00,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 8,   -- !
            in_touch_first_y = 18,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x00,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 8,   -- !
            in_touch_first_y = 19,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 8,   -- !
            in_touch_first_y = 25,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 8,   -- !
            in_touch_first_y = 26,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x00,
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 40,  -- !
            in_touch_first_y = 86,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 32,  -- !
            in_touch_first_y = 86,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x00,
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 33,  -- !
            in_touch_first_y = 86,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,  -- !
            in_touch_first_y = 86,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 48,  -- !
            in_touch_first_y = 86,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x00,
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 40,  -- !
            in_touch_first_y = 82,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x00,
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 40,  -- !
            in_touch_first_y = 83,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 40,  -- !
            in_touch_first_y = 89,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 40,  -- !
            in_touch_first_y = 90,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x00,
        },

        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x00,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 8,   -- !
            in_touch_first_y = 22,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x01,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 10,  -- !
            in_touch_first_y = 28,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x02,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 18,  -- !
            in_touch_first_y = 28,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_keyboard_mod = 0x04,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 8,   -- !
            in_touch_first_y = 22,  -- !
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 10, -- !
            in_touch_second_y = 28, -- !
            want_keyboard_mod = 0x03,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 8,   -- !
            in_touch_first_y = 22,  -- !
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 18, -- !
            in_touch_second_y = 28, -- !
            want_keyboard_mod = 0x05,
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 10,  -- !
            in_touch_first_y = 28,  -- !
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 18, -- !
            in_touch_second_y = 28, -- !
            want_keyboard_mod = 0x06,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_keyboard_offset_x = tc.in_keyboard_offset_x
        t.env.g_keyboard_offset_y = tc.in_keyboard_offset_y
        t.env.g_keyboard_mod = nil
        t.env.g_keyboard_moddef_list = tc.in_keyboard_moddef_list
        t.env.g_touch_first_time = tc.in_touch_first_time
        t.env.g_touch_first_x = tc.in_touch_first_x
        t.env.g_touch_first_y = tc.in_touch_first_y
        t.env.g_touch_second_time = tc.in_touch_second_time
        t.env.g_touch_second_x = tc.in_touch_second_x
        t.env.g_touch_second_y = tc.in_touch_second_y
        t.env.keyboardTickMod()

        assertEqual("g_keyboard_mod", tc.want_keyboard_mod, t.env.g_keyboard_mod)
    end
end

function test_decl.testKeyboardDrawKey(t)
    local tt = {
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {},
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {},
        },

        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {45, 77, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {45, 77, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x01, -- !
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "A", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 1,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 12,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 13,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 18,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 19,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 12,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 13,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 19,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 20,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 32,
            in_keyboard_offset_y = 64,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,  -- !
            in_touch_first_y = 80,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {45, 77, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {45, 77, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 32,
            in_keyboard_offset_y = 64,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 44,  -- !
            in_touch_first_y = 80,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {45, 77, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {45, 77, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 32,
            in_keyboard_offset_y = 64,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 45,  -- !
            in_touch_first_y = 80,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {45, 77, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {45, 77, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 32,
            in_keyboard_offset_y = 64,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 50,  -- !
            in_touch_first_y = 80,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {45, 77, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {45, 77, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 32,
            in_keyboard_offset_y = 64,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 51,  -- !
            in_touch_first_y = 80,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {45, 77, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {45, 77, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 32,
            in_keyboard_offset_y = 64,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,  -- !
            in_touch_first_y = 76,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {45, 77, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {45, 77, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 32,
            in_keyboard_offset_y = 64,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,  -- !
            in_touch_first_y = 77,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {45, 77, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {45, 77, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 32,
            in_keyboard_offset_y = 64,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,  -- !
            in_touch_first_y = 83,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {45, 77, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {45, 77, 5, 6, "a", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 32,
            in_keyboard_offset_y = 64,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,  -- !
            in_touch_first_y = 84,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {45, 77, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {45, 77, 5, 6, "a", 0, 0}},
            },
        },

        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
                {box = {40, 19, 5, 6}, plain_label = "b", shift_label = "B", plain_key = "b", shift_key = "B"},
            },
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {40, 19, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {40, 19, 5, 6, "b", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
                {box = {40, 19, 5, 6}, plain_label = "b", shift_label = "B", plain_key = "b", shift_key = "B"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {40, 19, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {40, 19, 5, 6, "b", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
                {box = {40, 19, 5, 6}, plain_label = "b", shift_label = "B", plain_key = "b", shift_key = "B"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 42,  -- !
            in_touch_first_y = 22,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {40, 19, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {40, 19, 5, 6, "b", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {13, 13, 5, 6}, plain_label = "a", shift_label = "A", plain_key = "a", shift_key = "A"},
                {box = {40, 19, 5, 6}, plain_label = "b", shift_label = "B", plain_key = "b", shift_key = "B"},
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 15,  -- !
            in_touch_first_y = 16,  -- !
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 42, -- !
            in_touch_second_y = 22, -- !
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {13, 13, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {13, 13, 5, 6, "a", 0, 0}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {40, 19, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {40, 19, 5, 6, "b", 0, 0}},
            },
        },

        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {1, 1, 5, 6}, plain_label = "E", shift_label = "E", plain_key = "Escape", shift_key = "Escape"},
            },
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {1, 1, 5, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {1, 1, 5, 6, "E", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x01, -- !
            in_keyboard_keydef_list = {
                {box = {1, 1, 5, 6}, plain_label = "E", shift_label = "E", plain_key = "Escape", shift_key = "Escape"},
            },
            in_touch_first_time = -1,
            in_touch_first_x = 0,
            in_touch_first_y = 0,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {1, 1, 5, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {1, 1, 5, 6, "E", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_keydef_list = {
                {box = {1, 1, 5, 6}, plain_label = "E", shift_label = "E", plain_key = "Escape", shift_key = "Escape"},
            },
            in_touch_first_time = 0,
            in_touch_first_x = 3,
            in_touch_first_y = 4,
            in_touch_second_time = -1,
            in_touch_second_x = 0,
            in_touch_second_y = 0,
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {1, 1, 5, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {1, 1, 5, 6, "E", 0, 0}},
            },
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_keyboard_offset_x = tc.in_keyboard_offset_x
        t.env.g_keyboard_offset_y = tc.in_keyboard_offset_y
        t.env.g_keyboard_mod = tc.in_keyboard_mod
        t.env.g_keyboard_keydef_list = tc.in_keyboard_keydef_list
        t.env.g_touch_first_time = tc.in_touch_first_time
        t.env.g_touch_first_x = tc.in_touch_first_x
        t.env.g_touch_first_y = tc.in_touch_first_y
        t.env.g_touch_second_time = tc.in_touch_second_time
        t.env.g_touch_second_x = tc.in_touch_second_x
        t.env.g_touch_second_y = tc.in_touch_second_y
        t.env.keyboardDrawKey()

        assertEqual("screen._log", tc.want_screen_log, t.env.screen._log)
    end
end

function test_decl.testKeyboardDrawMod(t)
    local tt = {
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_moddef_list = {},
            want_screen_log = {},
        },

        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x00,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {1, 19, 14, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {1, 19, 14, 6, "S", 0, 0}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {7, 25, 7, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {7, 25, 7, 6, "C", 0, 0}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {15, 25, 7, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {15, 25, 7, 6, "A", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 32,  -- !
            in_keyboard_offset_y = 64,  -- !
            in_keyboard_mod = 0x00,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {33, 83, 14, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {33, 83, 14, 6, "S", 0, 0}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {39, 89, 7, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {39, 89, 7, 6, "C", 0, 0}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {47, 89, 7, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {47, 89, 7, 6, "A", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x01, -- !
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {1, 19, 14, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {1, 19, 14, 6, "S", 0, 0}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {7, 25, 7, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {7, 25, 7, 6, "C", 0, 0}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {15, 25, 7, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {15, 25, 7, 6, "A", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x02, -- !
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {1, 19, 14, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {1, 19, 14, 6, "S", 0, 0}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {7, 25, 7, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {7, 25, 7, 6, "C", 0, 0}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {15, 25, 7, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {15, 25, 7, 6, "A", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x04,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            want_screen_log = {
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {1, 19, 14, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {1, 19, 14, 6, "S", 0, 0}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawRectF", args = {7, 25, 7, 6}},
                {fn = "setColor", args = {0x15, 0x15, 0x15}},
                {fn = "drawTextBox", args = {7, 25, 7, 6, "C", 0, 0}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {15, 25, 7, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {15, 25, 7, 6, "A", 0, 0}},
            },
        },
        {
            in_keyboard_offset_x = 0,
            in_keyboard_offset_y = 0,
            in_keyboard_mod = 0x07,
            in_keyboard_moddef_list = {
                {box = {1, 19, 14, 6}, mod = 0x01, label = "S"},
                {box = {7, 25, 7, 6}, mod = 0x02, label = "C"},
                {box = {15, 25, 7, 6}, mod = 0x04, label = "A"},
            },
            want_screen_log = {
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {1, 19, 14, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {1, 19, 14, 6, "S", 0, 0}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {7, 25, 7, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {7, 25, 7, 6, "C", 0, 0}},
                {fn = "setColor", args = {0xFF, 0xFF, 0xFF}},
                {fn = "drawRectF", args = {15, 25, 7, 6}},
                {fn = "setColor", args = {0x06, 0x06, 0x06}},
                {fn = "drawTextBox", args = {15, 25, 7, 6, "A", 0, 0}},
            },
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_keyboard_offset_x = tc.in_keyboard_offset_x
        t.env.g_keyboard_offset_y = tc.in_keyboard_offset_y
        t.env.g_keyboard_mod = tc.in_keyboard_mod
        t.env.g_keyboard_moddef_list = tc.in_keyboard_moddef_list
        t.env.keyboardDrawMod()

        assertEqual("screen._log", tc.want_screen_log, t.env.screen._log)
    end
end

function test_decl.testHttpGetIdle(t)
    local tt = {
        {
            in_http_cnt = 0,
            in_port = 52149,
            in_req = "/keyboard?key=a&mod=0",
            want_http_cnt = 1,
            want_async_log = {{52149, "/keyboard?key=a&mod=0"}},
        },
        {
            in_http_cnt = 1,
            in_port = 52149,
            in_req = "/keyboard?key=a&mod=0",
            want_http_cnt = 1,
            want_async_log = {},
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_http_cnt = tc.in_http_cnt
        t.env.httpGetIdle(tc.in_port, tc.in_req)

        assertEqual("g_http_cnt", tc.want_http_cnt, t.env.g_http_cnt)
        assertEqual("async._log", tc.want_async_log, t.env.async._log)
    end
end

function test_decl.testHttpGet(t)
    local tt = {
        {in_http_cnt = 0, want_http_cnt = 1},
        {in_http_cnt = 1, want_http_cnt = 2},
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_http_cnt = tc.in_http_cnt
        t.env.httpGet(52149, "/keyboard?key=a&mod=0")

        local want_async_log = {{52149, "/keyboard?key=a&mod=0"}}
        assertEqual("g_http_cnt", tc.want_http_cnt, t.env.g_http_cnt)
        assertEqual("async._log", want_async_log, t.env.async._log)
    end
end

function test_decl.testHttpReply(t)
    local tt = {
        {in_http_cnt = 2, want_http_cnt = 1},
        {in_http_cnt = 1, want_http_cnt = 0},
        {in_http_cnt = 0, want_http_cnt = 0},
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_http_cnt = tc.in_http_cnt
        t.env.httpReply(52149, "/keyboard?key=a&mod=0", "")
        assertEqual("g_http_cnt", tc.want_http_cnt, t.env.g_http_cnt)
    end
end

function test_decl.testTouchTick(t)
    local tt = {
        {
            in_input_bool_tbl = {
                [1] = false,
                [2] = false,
            },
            in_input_number_tbl = {
                [1] = 96,
                [2] = 32,
                [3] = 1,
                [4] = 2,
                [5] = 3,
                [6] = 4,
            },
            in_touch_first_time = 0,
            in_touch_first_x = 1,
            in_touch_first_y = 2,
            in_touch_second_time = 0,
            in_touch_second_x = 3,
            in_touch_second_y = 4,
            want_touch_w = 96,
            want_touch_h = 32,
            want_touch_first_time = -1,
            want_touch_first_x = 0,
            want_touch_first_y = 0,
            want_touch_second_time = -1,
            want_touch_second_x = 0,
            want_touch_second_y = 0,
        },
        {
            in_input_bool_tbl = {
                [1] = false,
                [2] = false,
            },
            in_input_number_tbl = {
                [1] = 0,    -- !
                [2] = 0,    -- !
                [3] = 1,
                [4] = 2,
                [5] = 3,
                [6] = 4,
            },
            in_touch_first_time = 0,
            in_touch_first_x = 1,
            in_touch_first_y = 2,
            in_touch_second_time = 0,
            in_touch_second_x = 3,
            in_touch_second_y = 4,
            want_touch_w = 1,
            want_touch_h = 1,
            want_touch_first_time = -1,
            want_touch_first_x = 0,
            want_touch_first_y = 0,
            want_touch_second_time = -1,
            want_touch_second_x = 0,
            want_touch_second_y = 0,
        },
        {
            in_input_bool_tbl = {
                [1] = true, -- !
                [2] = false,
            },
            in_input_number_tbl = {
                [1] = 96,
                [2] = 32,
                [3] = 1,
                [4] = 2,
                [5] = 3,
                [6] = 4,
            },
            in_touch_first_time = -1,   -- !
            in_touch_first_x = 0,   -- !
            in_touch_first_y = 0,   -- !
            in_touch_second_time = 0,
            in_touch_second_x = 3,
            in_touch_second_y = 4,
            want_touch_w = 96,
            want_touch_h = 32,
            want_touch_first_time = 0,
            want_touch_first_x = 1,
            want_touch_first_y = 2,
            want_touch_second_time = -1,
            want_touch_second_x = 0,
            want_touch_second_y = 0,
        },
        {
            in_input_bool_tbl = {
                [1] = true, -- !
                [2] = false,
            },
            in_input_number_tbl = {
                [1] = 96,
                [2] = 32,
                [3] = 1,
                [4] = 2,
                [5] = 3,
                [6] = 4,
            },
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 5,   -- !
            in_touch_first_y = 6,   -- !
            in_touch_second_time = 0,
            in_touch_second_x = 3,
            in_touch_second_y = 4,
            want_touch_w = 96,
            want_touch_h = 32,
            want_touch_first_time = 1,
            want_touch_first_x = 5,
            want_touch_first_y = 6,
            want_touch_second_time = -1,
            want_touch_second_x = 0,
            want_touch_second_y = 0,
        },
        {
            in_input_bool_tbl = {
                [1] = false,
                [2] = true, -- !
            },
            in_input_number_tbl = {
                [1] = 96,
                [2] = 32,
                [3] = 1,
                [4] = 2,
                [5] = 3,
                [6] = 4,
            },
            in_touch_first_time = 0,
            in_touch_first_x = 1,
            in_touch_first_y = 2,
            in_touch_second_time = -1,  -- !
            in_touch_second_x = 0,  -- !
            in_touch_second_y = 0,  -- !
            want_touch_w = 96,
            want_touch_h = 32,
            want_touch_first_time = -1,
            want_touch_first_x = 0,
            want_touch_first_y = 0,
            want_touch_second_time = 0,
            want_touch_second_x = 3,
            want_touch_second_y = 4,
        },
        {
            in_input_bool_tbl = {
                [1] = false,
                [2] = true, -- !
            },
            in_input_number_tbl = {
                [1] = 96,
                [2] = 32,
                [3] = 1,
                [4] = 2,
                [5] = 3,
                [6] = 4,
            },
            in_touch_first_time = 0,
            in_touch_first_x = 1,
            in_touch_first_y = 2,
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 5,  -- !
            in_touch_second_y = 6,  -- !
            want_touch_w = 96,
            want_touch_h = 32,
            want_touch_first_time = -1,
            want_touch_first_x = 0,
            want_touch_first_y = 0,
            want_touch_second_time = 1,
            want_touch_second_x = 5,
            want_touch_second_y = 6,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.input._bool_tbl = tc.in_input_bool_tbl
        t.env.input._number_tbl = tc.in_input_number_tbl
        t.env.g_touch_w = nil
        t.env.g_touch_h = nil
        t.env.g_touch_first_time = tc.in_touch_first_time
        t.env.g_touch_first_x = tc.in_touch_first_x
        t.env.g_touch_first_y = tc.in_touch_first_y
        t.env.g_touch_second_time = tc.in_touch_second_time
        t.env.g_touch_second_x = tc.in_touch_second_x
        t.env.g_touch_second_y = tc.in_touch_second_y
        t.env.touchTick()

        assertEqual("g_touch_w", tc.want_touch_w, t.env.g_touch_w)
        assertEqual("g_touch_h", tc.want_touch_h, t.env.g_touch_h)
        assertEqual("g_touch_first_time", tc.want_touch_first_time, t.env.g_touch_first_time)
        assertEqual("g_touch_first_x", tc.want_touch_first_x, t.env.g_touch_first_x)
        assertEqual("g_touch_first_y", tc.want_touch_first_y, t.env.g_touch_first_y)
        assertEqual("g_touch_second_time", tc.want_touch_second_time, t.env.g_touch_second_time)
        assertEqual("g_touch_second_x", tc.want_touch_second_x, t.env.g_touch_second_x)
        assertEqual("g_touch_second_y", tc.want_touch_second_y, t.env.g_touch_second_y)
    end
end

function test_decl.testTouchBox(t)
    local tt = {
        {
            in_touch_first_time = -1,
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = -1,
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = -1,
        },

        {
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = -1,
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = 0,
        },
        {
            in_touch_first_time = 1,    -- !
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = -1,
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = 1,
        },
        {
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 22,  -- !
            in_touch_first_y = 17,
            in_touch_second_time = -1,
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = -1,
        },
        {
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 71,  -- !
            in_touch_first_y = 17,
            in_touch_second_time = -1,
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = 0,
        },
        {
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 72,  -- !
            in_touch_first_y = 17,
            in_touch_second_time = -1,
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = -1,
        },
        {
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,
            in_touch_first_y = 6,   -- !
            in_touch_second_time = -1,
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = -1,
        },
        {
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,
            in_touch_first_y = 7,   -- !
            in_touch_second_time = -1,
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = 0,
        },
        {
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,
            in_touch_first_y = 23,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = 0,
        },
        {
            in_touch_first_time = 0,    -- !
            in_touch_first_x = 47,
            in_touch_first_y = 24,  -- !
            in_touch_second_time = -1,
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = -1,
        },

        {
            in_touch_first_time = -1,
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = 0,
        },
        {
            in_touch_first_time = -1,
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 1,   -- !
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = 1,
        },
        {
            in_touch_first_time = -1,
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 22, -- !
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = -1,
        },
        {
            in_touch_first_time = -1,
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 23, -- !
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = 0,
        },
        {
            in_touch_first_time = -1,
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 71, -- !
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = 0,
        },
        {
            in_touch_first_time = -1,
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 72, -- !
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = -1,
        },
        {
            in_touch_first_time = -1,
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 47,
            in_touch_second_y = 6,  -- !
            in_box = {23, 7, 48, 16},
            want_time = -1,
        },
        {
            in_touch_first_time = -1,
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 47,
            in_touch_second_y = 7,  -- !
            in_box = {23, 7, 48, 16},
            want_time = 0,
        },
        {
            in_touch_first_time = -1,
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 47,
            in_touch_second_y = 23, -- !
            in_box = {23, 7, 48, 16},
            want_time = 0,
        },
        {
            in_touch_first_time = -1,
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 0,   -- !
            in_touch_second_x = 47,
            in_touch_second_y = 24, -- !
            in_box = {23, 7, 48, 16},
            want_time = -1,
        },

        {
            in_touch_first_time = 2,    -- !
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 3,   -- !
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = 3,
        },
        {
            in_touch_first_time = 3,    -- !
            in_touch_first_x = 47,
            in_touch_first_y = 17,
            in_touch_second_time = 2,   -- !
            in_touch_second_x = 47,
            in_touch_second_y = 17,
            in_box = {23, 7, 48, 16},
            want_time = 3,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.g_touch_first_time = tc.in_touch_first_time
        t.env.g_touch_first_x = tc.in_touch_first_x
        t.env.g_touch_first_y = tc.in_touch_first_y
        t.env.g_touch_second_time = tc.in_touch_second_time
        t.env.g_touch_second_x = tc.in_touch_second_x
        t.env.g_touch_second_y = tc.in_touch_second_y
        local got_time = t.env.touchBox(tc.in_box)

        assertEqual("time", tc.want_time, got_time)
    end
end

local function buildMockInput()
    local input = {
        _bool_tbl = {},
        _number_tbl = {},
    }

    function input.getBool(index)
        return input._bool_tbl[index] or false
    end

    function input.getNumber(index)
        return input._number_tbl[index] or 0
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
        _log = {},
    }

    function screen.setColor(...)
        table.insert(screen._log, {
            fn = "setColor",
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
