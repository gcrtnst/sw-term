c_color_default_fg = {0xC4, 0xC4, 0xC4}
c_color_default_bg = {0x00, 0x00, 0x00}
c_color_palette = {
    [0] = {0x00, 0x00, 0x00},
    [1] = {0xC4, 0x40, 0x40},
    [2] = {0x40, 0xC4, 0x40},
    [3] = {0xC4, 0xC4, 0x40},
    [4] = {0x40, 0x40, 0xC4},
    [5] = {0xC4, 0x40, 0xC4},
    [6] = {0x40, 0xC4, 0xC4},
    [7] = {0xC4, 0xC4, 0xC4},
}

c_cell_width = 5
c_cell_height = 6

c_cursor_shape_block = 1
c_cursor_shape_underline = 2
c_cursor_shape_barleft = 3

p_http_port = property.getNumber("HTTP Port")
p_offset_x = property.getNumber("Offset X")
p_offset_y = property.getNumber("Offset Y")

g_active = false
g_http = false

g_dec_err = false
g_dec_bin = ""
g_dec_pos = 1

g_draw_error = nil
g_draw_screen = nil
g_draw_cursor_blink = nil

function init()
    g_draw_cursor_blink = blinkNew(60, 30, 30)
end

function onTick()
    g_active = input.getBool(1)

    if g_active then
        drawTick()
        httpTrigger()
    else
        drawSet(nil, nil)
    end
end

function httpReply(port, req, resp)
    g_http = false

    if g_active then
        local scr, err = parseHTTPResponse(resp)
        drawSet(scr, err)

        httpTrigger()
    end
end

function onDraw()
    drawDo()
end

function httpTrigger()
    if not g_http then
        async.httpGet(p_http_port, "/screen")
        g_http = true
    end
end

function parseHTTPResponse(resp)
    if string.sub(resp, 1, 8) == "%SWTSCRN" then
        local bin
        bin = string.sub(resp, 9)
        bin = unescapeZero(bin)
        if bin == nil then
            return nil, "sw-term: unescape failed"
        end

        local scr = decodeDo(bin)
        if scr == nil then
            return nil, "sw-term: decode failed"
        end

        return scr, nil
    end

    if string.match(resp, "^[ -~]+$") ~= nil then
        return nil, resp
    end

    return nil, "sw-term: invalid response"
end

function unescapeZero(bin)
    local buf = {}
    local i = 1
    while true do
        local c

        c = string.byte(bin, i)
        i = i + 1

        if c == nil then
            break
        elseif c == 0xFF then
            c = string.byte(bin, i)
            i = i + 1

            if c ~= nil and 0xFE <= c then
                buf[#buf + 1] = c
            else
                return nil
            end
        elseif 0x01 <= c then
            buf[#buf + 1] = c - 0x01
        else
            return nil
        end
    end
    return string.char(table.unpack(buf))
end

function decodeDo(bin)
    g_dec_err = false
    g_dec_bin = bin
    g_dec_pos = 1
    local scr = decodeScreen()

    local err = g_dec_err
    local pos = g_dec_pos
    g_dec_err = false
    g_dec_bin = ""
    g_dec_pos = 1

    if err or pos ~= #bin + 1 then
        return nil
    end
    return scr
end

function decodeScreen()
    local cursor = decodeCursor()

    local rows, cols = table.unpack(decodeElem("!1<i8i8"))
    if not ((rows == 0 and cols == 0) or (rows > 0 and cols > 0)) then
        g_dec_err = true
        return {
            rows = 0,
            cols = 0,
            cell = {},
            cursor = cursor,
        }
    end

    local cell = {}
    for row = 1, rows do
        cell[row] = {}
        for col = 1, cols do
            cell[row][col] = decodeCell()
        end
    end

    return {
        rows = rows,
        cols = cols,
        cell = cell,
        cursor = cursor,
    }
end

function decodeCell()
    decodeElem("!1<xxxxxxxxxxxx")   -- ignore attrs
    local fg = decodeColor()
    local bg = decodeColor()
    decodeElem("!1<x")  -- ignore width
    local chars = decodeString()

    return {
        fg = fg,
        bg = bg,
        chars = chars,
    }
end

function decodeCursor()
    local list = decodeElem("!1<BBBi8i8")
    return {
        visible = list[1] ~= 0,
        blink = list[2] ~= 0,
        shape = list[3],
        row = list[4] + 1,
        col = list[5] + 1,
    }
end

function decodeColor()
    local list = decodeElem("!1<BBBB")
    if g_dec_err then
        return {}
    end

    local kind = list[1]
    if kind & 0x06 ~= 0x00 then
        return {}
    end
    if kind & 0x01 ~= 0x00 then
        return {idx = list[2]}
    end

    table.remove(list, 1)
    return {
        rgb = list,
    }
end

function decodeString()
    local sublen = decodeElem("!1<I8")[1]
    if g_dec_err or sublen < 0 or #g_dec_bin - g_dec_pos + 1 < sublen then
        g_dec_err = true
        return ""
    end

    local sub = string.sub(g_dec_bin, g_dec_pos, g_dec_pos + sublen - 1)
    g_dec_pos = g_dec_pos + sublen
    return sub
end

function decodeElem(fmt)
    local fmtsize = string.packsize(fmt)
    if g_dec_err or #g_dec_bin < g_dec_pos + fmtsize - 1 then
        g_dec_err = true

        local bin = string.rep("\x00", fmtsize)
        local list = {string.unpack(fmt, bin)}
        list[#list] = nil
        return list
    end

    local list = {string.unpack(fmt, g_dec_bin, g_dec_pos)}
    g_dec_pos = list[#list]
    list[#list] = nil
    return list
end

function drawSet(scr, err)
    if err ~= nil then
        scr = nil
    end

    g_draw_error = err
    drawSetScreen(scr)
end

function drawSetScreen(scr)
    local old = g_draw_screen
    g_draw_screen = scr

    if old == nil or
        scr == nil or
        old.cursor.visible ~= scr.cursor.visible or
        old.cursor.blink ~= scr.cursor.blink or
        old.cursor.shape ~= scr.cursor.shape or
        old.cursor.row ~= scr.cursor.row or
        old.cursor.col ~= scr.cursor.col then
        blinkReset(g_draw_cursor_blink)
    end
end

function drawTick()
    if g_draw_screen ~= nil then
        blinkTick(g_draw_cursor_blink)
    end
end

function drawDo()
    drawError()
    drawScreen()
end

function drawError()
    if g_draw_error == nil then
        return
    end

    local w = screen.getWidth()
    local h = screen.getHeight()

    screen.setColor(0x00, 0x00, 0xFF)
    screen.drawClear()

    screen.setColor(0xFF, 0xFF, 0xFF)
    screen.drawTextBox(0, 0, w, h, g_draw_error)
end

function drawScreen()
    if g_draw_screen == nil then
        return
    end
    local cursor_visible = g_draw_screen.cursor.visible and (not g_draw_screen.cursor.blink or blinkCheck(g_draw_cursor_blink))

    screen.setColor(table.unpack(c_color_default_bg))
    screen.drawClear()
    for row = 1, g_draw_screen.rows do
        for col = 1, g_draw_screen.cols do
            local cell = g_draw_screen.cell[row][col]
            local x = (col - 1)*c_cell_width + p_offset_x
            local y = (row - 1)*c_cell_height + p_offset_y
            local cursor_visible = cursor_visible and g_draw_screen.cursor.row == row and g_draw_screen.cursor.col == col

            local fg = convertRGB(cell.fg, c_color_palette) or c_color_default_fg
            local bg = convertRGB(cell.bg, c_color_palette) or c_color_default_bg

            if cursor_visible and g_draw_screen.cursor.shape == c_cursor_shape_block then
                fg = invertRGB(fg)
                bg = invertRGB(bg)
            end

            screen.setColor(table.unpack(bg))
            screen.drawRectF(x, y, c_cell_width, c_cell_height)

            local chars = convertChars(cell.chars)
            screen.setColor(table.unpack(fg))
            screen.drawText(x, y, chars)

            if cursor_visible then
                if g_draw_screen.cursor.shape == c_cursor_shape_underline then
                    screen.setColor(table.unpack(invertRGB(bg)))
                    screen.drawText(x, y, "_")
                elseif g_draw_screen.cursor.shape == c_cursor_shape_barleft then
                    screen.setColor(table.unpack(invertRGB(bg)))
                    screen.drawLine(x, y, x, y+c_cell_height)
                end
            end
        end
    end
end

function convertRGB(col, palette)
    return col.idx ~= nil and palette[col.idx] or col.rgb
end

function invertRGB(rgb)
    return {
        rgb[1] ~ 0xFF,
        rgb[2] ~ 0xFF,
        rgb[3] ~ 0xFF,
    }
end

function convertChars(s)
    if string.match(s, "^[ -~]$") ~= nil or s == "" then
        return s
    end
    return "?"
end

function blinkNew(wait, on, off)
    local blink = {
        wait = wait,
        on = on,
        off = off,
        time = 0,
    }
    blinkReset(blink)
    return blink
end

function blinkReset(blink)
    blink.time = blink.wait + blink.on + blink.off
end

function blinkTick(blink)
    blink.time = blink.time - 1
    if blink.time <= 0 then
        blink.time = blink.on + blink.off
    end
end

function blinkCheck(blink)
    return blink.time > blink.off
end

init()
