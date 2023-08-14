c_keyboard_mod_shift = 0x01
c_keyboard_back_rgb = {0x06, 0x06, 0x06}
c_keyboard_ctrl_rgb = {0x15, 0x15, 0x15}
c_keyboard_char_rgb = {0xFF, 0xFF, 0xFF}

p_http_port = property.getNumber("HTTP Port")

g_keyboard_w = 96
g_keyboard_h = 32
g_keyboard_offset_x = 0
g_keyboard_offset_y = 0
g_keyboard_mod = 0x00
g_keyboard_keydef_list = {}
g_keyboard_moddef_list = {}

g_http_cnt = 0

g_touch_w = 1
g_touch_h = 1
g_touch_first_time = -1
g_touch_first_x = 0
g_touch_first_y = 0
g_touch_second_time = -1
g_touch_second_x = 0
g_touch_second_y = 0

function init()
    g_keyboard_keydef_list = {
        keyboardNewControl({1, 1, 5, 6}, "E", "Escape"),
        keyboardNewGraphic({7, 1, 5, 6}, "`", "~"),
        keyboardNewGraphic({13, 1, 5, 6}, "1", "!"),
        keyboardNewGraphic({19, 1, 5, 6}, "2", "@"),
        keyboardNewGraphic({25, 1, 5, 6}, "3", "#"),
        keyboardNewGraphic({31, 1, 5, 6}, "4", "$"),
        keyboardNewGraphic({37, 1, 5, 6}, "5", "%"),
        keyboardNewGraphic({43, 1, 5, 6}, "6", "^"),
        keyboardNewGraphic({49, 1, 5, 6}, "7", "&"),
        keyboardNewGraphic({55, 1, 5, 6}, "8", "*"),
        keyboardNewGraphic({61, 1, 5, 6}, "9", "("),
        keyboardNewGraphic({67, 1, 5, 6}, "0", ")"),
        keyboardNewGraphic({73, 1, 5, 6}, "-", "_"),
        keyboardNewGraphic({79, 1, 5, 6}, "=", "+"),
        keyboardNewControl({85, 1, 10, 6}, "BS", "Backspace"),
        keyboardNewControl({1, 7, 8, 6}, ">", "Tab"),
        keyboardNewAlphabet({10, 7, 5, 6}, "q"),
        keyboardNewAlphabet({16, 7, 5, 6}, "w"),
        keyboardNewAlphabet({22, 7, 5, 6}, "e"),
        keyboardNewAlphabet({28, 7, 5, 6}, "r"),
        keyboardNewAlphabet({34, 7, 5, 6}, "t"),
        keyboardNewAlphabet({40, 7, 5, 6}, "y"),
        keyboardNewAlphabet({46, 7, 5, 6}, "u"),
        keyboardNewAlphabet({52, 7, 5, 6}, "i"),
        keyboardNewAlphabet({58, 7, 5, 6}, "o"),
        keyboardNewAlphabet({64, 7, 5, 6}, "p"),
        keyboardNewGraphic({70, 7, 5, 6}, "[", "{"),
        keyboardNewGraphic({76, 7, 5, 6}, "]", "}"),
        keyboardNewGraphic({82, 7, 5, 6}, "\\", "|"),
        keyboardNewControl({88, 7, 7, 6}, "D", "Delete"),
        keyboardNewAlphabet({13, 13, 5, 6}, "a"),
        keyboardNewAlphabet({19, 13, 5, 6}, "s"),
        keyboardNewAlphabet({25, 13, 5, 6}, "d"),
        keyboardNewAlphabet({31, 13, 5, 6}, "f"),
        keyboardNewAlphabet({37, 13, 5, 6}, "g"),
        keyboardNewAlphabet({43, 13, 5, 6}, "h"),
        keyboardNewAlphabet({49, 13, 5, 6}, "j"),
        keyboardNewAlphabet({55, 13, 5, 6}, "k"),
        keyboardNewAlphabet({61, 13, 5, 6}, "l"),
        keyboardNewGraphic({67, 13, 5, 6}, ";", ":"),
        keyboardNewGraphic({73, 13, 5, 6}, "'", "\""),
        keyboardNewControl({79, 13, 16, 6}, "CR", "Enter"),
        keyboardNewAlphabet({16, 19, 5, 6}, "z"),
        keyboardNewAlphabet({22, 19, 5, 6}, "x"),
        keyboardNewAlphabet({28, 19, 5, 6}, "c"),
        keyboardNewAlphabet({34, 19, 5, 6}, "v"),
        keyboardNewAlphabet({40, 19, 5, 6}, "b"),
        keyboardNewAlphabet({46, 19, 5, 6}, "n"),
        keyboardNewAlphabet({52, 19, 5, 6}, "m"),
        keyboardNewGraphic({58, 19, 5, 6}, ",", "<"),
        keyboardNewGraphic({64, 19, 5, 6}, ".", ">"),
        keyboardNewGraphic({70, 19, 5, 6}, "/", "?"),
        keyboardNewControl({76, 19, 5, 6}, "^", "ArrowUp"),
        keyboardNewGraphic({23, 25, 30, 6}, " ", " "),
        keyboardNewControl({70, 25, 5, 6}, "<", "ArrowLeft"),
        keyboardNewControl({76, 25, 5, 6}, "v", "ArrowDown"),
        keyboardNewControl({82, 25, 5, 6}, ">", "ArrowRight"),
    }

    g_keyboard_moddef_list = {
        keyboardNewModifier({1, 19, 14, 6}, "S", 0x01),
        keyboardNewModifier({82, 19, 13, 6}, "S", 0x01),
        keyboardNewModifier({7, 25, 7, 6}, "C", 0x02),
        keyboardNewModifier({62, 25, 7, 6}, "C", 0x02),
        keyboardNewModifier({15, 25, 7, 6}, "A", 0x04),
        keyboardNewModifier({54, 25, 7, 6}, "A", 0x04),
    }
end

function onTick()
    touchTick()
    keyboardTick()
end

function onDraw()
    keyboardDraw()
end

function keyboardNewAlphabet(box, plain_key)
    return keyboardNewGraphic(box, plain_key, string.upper(plain_key))
end

function keyboardNewGraphic(box, plain_key, shift_key)
    return {
        box = box,
        plain_label = plain_key,
        shift_label = shift_key,
        plain_key = plain_key,
        shift_key = shift_key,
    }
end

function keyboardNewControl(box, label, key)
    return {
        box = box,
        plain_label = label,
        shift_label = label,
        plain_key = key,
        shift_key = key,
    }
end

function keyboardNewModifier(box, label, mod)
    return {
        box = box,
        label = label,
        mod = mod,
    }
end

function keyboardTick()
    keyboardTickOffset()
    keyboardTickMod()
    keyboardTickKey()
end

function keyboardTickOffset()
    g_keyboard_offset_x = (g_touch_w - g_keyboard_w)/2
    g_keyboard_offset_x = math.tointeger(math.floor(g_keyboard_offset_x + 0.5)) or 0
    g_keyboard_offset_y = g_touch_h - g_keyboard_h
    g_keyboard_offset_y = math.tointeger(math.floor(g_keyboard_offset_y + 0.5)) or 0
end

function keyboardTickKey()
    for _, keydef in ipairs(g_keyboard_keydef_list) do
        local box = boxOffset(keydef.box, g_keyboard_offset_x, g_keyboard_offset_y)
        local shift = g_keyboard_mod&c_keyboard_mod_shift ~= 0x00
        local key = shift and keydef.shift_key or keydef.plain_key
        local url = string.format("/keyboard?key=%s&mod=%d", escapeQuery(key), g_keyboard_mod)

        local time = touchBox(box)
        if time == 0 then
            httpGet(p_http_port, url)
        elseif time >= 30 then
            httpGetIdle(p_http_port, url)
        end
    end
end

function keyboardTickMod()
    g_keyboard_mod = 0x00
    for _, moddef in ipairs(g_keyboard_moddef_list) do
        local box = boxOffset(moddef.box, g_keyboard_offset_x, g_keyboard_offset_y)

        local time = touchBox(box)
        if time >= 0 then
            g_keyboard_mod = g_keyboard_mod | moddef.mod
        end
    end
end

function keyboardDraw()
    keyboardDrawKey()
    keyboardDrawMod()
end

function keyboardDrawKey()
    for _, keydef in ipairs(g_keyboard_keydef_list) do
        local box = boxOffset(keydef.box, g_keyboard_offset_x, g_keyboard_offset_y)
        local shift = g_keyboard_mod&c_keyboard_mod_shift ~= 0x00
        local key = shift and keydef.shift_key or keydef.plain_key
        local label = shift and keydef.shift_label or keydef.plain_label
        local time = touchBox(box)

        local bg = c_keyboard_back_rgb
        local fg = key == label and c_keyboard_char_rgb or c_keyboard_ctrl_rgb
        if time >= 0 then
            bg = c_keyboard_char_rgb
            fg = c_keyboard_back_rgb
        end

        drawColor(bg)
        drawRectF(box)
        drawColor(fg)
        drawTextBox(box, label, 0, 0)
    end
end

function keyboardDrawMod()
    for _, moddef in ipairs(g_keyboard_moddef_list) do
        local box = boxOffset(moddef.box, g_keyboard_offset_x, g_keyboard_offset_y)

        local bg = c_keyboard_back_rgb
        local fg = c_keyboard_ctrl_rgb
        if g_keyboard_mod&moddef.mod ~= 0x00 then
            bg = c_keyboard_char_rgb
            fg = c_keyboard_back_rgb
        end

        drawColor(bg)
        drawRectF(box)
        drawColor(fg)
        drawTextBox(box, moddef.label, 0, 0)
    end
end

function httpGetIdle(port, url)
    if g_http_cnt <= 0 then
        httpGet(port, url)
    end
end

function httpGet(port, url)
    g_http_cnt = g_http_cnt + 1
    async.httpGet(port, url)
end

function httpReply(port, req, resp)
    g_http_cnt = math.max(0, g_http_cnt - 1)
end

function touchTick()
    g_touch_w = math.max(1, input.getNumber(1))
    g_touch_h = math.max(1, input.getNumber(2))

    local first_touch = input.getBool(1)
    if first_touch then
        g_touch_first_time = g_touch_first_time + 1
        if g_touch_first_time == 0 then
            g_touch_first_x = input.getNumber(3)
            g_touch_first_y = input.getNumber(4)
        end
    else
        g_touch_first_time = -1
        g_touch_first_x = 0
        g_touch_first_y = 0
    end

    local second_touch = input.getBool(2)
    if second_touch then
        g_touch_second_time = g_touch_second_time + 1
        if g_touch_second_time == 0 then
            g_touch_second_x = input.getNumber(5)
            g_touch_second_y = input.getNumber(6)
        end
    else
        g_touch_second_time = -1
        g_touch_second_x = 0
        g_touch_second_y = 0
    end
end

function touchBox(box)
    local box_x, box_y, box_w, box_h = table.unpack(box)

    local time = -1
    if g_touch_first_time > time and
        box_x <= g_touch_first_x and
        g_touch_first_x <= box_x + box_w and
        box_y <= g_touch_first_y and
        g_touch_first_y <= box_y + box_h then
        time = g_touch_first_time
    end
    if g_touch_second_time > time and
        box_x <= g_touch_second_x and
        g_touch_second_x <= box_x + box_w and
        box_y <= g_touch_second_y and
        g_touch_second_y <= box_y + box_h then
        time = g_touch_second_time
    end
    return time
end

function boxOffset(box, offset_x, offset_y)
    local x, y, w, h = table.unpack(box)
    return {x + offset_x, y + offset_y, w, h}
end

function drawColor(rgb)
    screen.setColor(table.unpack(rgb))
end

function drawRectF(box)
    screen.drawRectF(table.unpack(box))
end

function drawTextBox(box, text, h_align, v_align)
    local x, y, w, h = table.unpack(box)
    screen.drawTextBox(x, y, w, h, text, h_align, v_align)
end

function escapeQuery(s)
    local t = {}
    for i = 1, #s do
        local c = string.sub(s, i, i)
        if c == " " then
            c = "+"
        elseif string.match(c, "^[%-%.0-9A-Z_a-z~]$") == nil then
            c = string.format("%%%02X", string.byte(c, 1))
        end
        table.insert(t, c)
    end
    return table.concat(t)
end

init()
