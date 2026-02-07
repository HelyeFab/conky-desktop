require 'cairo'

local bg_png = os.getenv("HOME") .. "/.config/conky/lyrics/rounded_bg.png"
local last_w = 0
local last_h = 0

function conky_draw_background()
    if conky_window == nil then return end

    local w = conky_window.width
    local h = conky_window.height

    -- Only regenerate PNG when window size changes
    if w == last_w and h == last_h then return end
    last_w = w
    last_h = h

    local r = 15
    local cs = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, w, h)
    local cr = cairo_create(cs)

    -- Rounded rectangle path
    cairo_move_to(cr, r, 0)
    cairo_line_to(cr, w - r, 0)
    cairo_arc(cr, w - r, r, r, -math.pi / 2, 0)
    cairo_line_to(cr, w, h - r)
    cairo_arc(cr, w - r, h - r, r, 0, math.pi / 2)
    cairo_line_to(cr, r, h)
    cairo_arc(cr, r, h - r, r, math.pi / 2, math.pi)
    cairo_line_to(cr, 0, r)
    cairo_arc(cr, r, r, r, math.pi, 3 * math.pi / 2)
    cairo_close_path(cr)

    cairo_set_source_rgba(cr, 0, 0, 0, 1.0)
    cairo_fill(cr)

    cairo_surface_write_to_png(cs, bg_png)
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

function conky_mouse_hook(button, x, y)
    local cache_dir = os.getenv("HOME") .. "/.config/conky/lyrics"
    local offset_file = cache_dir .. "/scroll_offset.txt"
    local lyrics_file = cache_dir .. "/lyrics.txt"
    local manual_file = cache_dir .. "/manual_scroll.txt"

    -- Only handle scroll up (4) and scroll down (5)
    if button ~= 4 and button ~= 5 then
        return
    end

    -- Count total lines in lyrics
    local total = 0
    local f = io.open(lyrics_file, "r")
    if f then
        for _ in f:lines() do total = total + 1 end
        f:close()
    end
    if total == 0 then return end

    -- Read current offset
    local offset = 0
    f = io.open(offset_file, "r")
    if f then
        offset = tonumber(f:read("*l")) or 0
        f:close()
    end

    -- Adjust offset (3 lines per scroll tick)
    local step = 3
    if button == 4 then
        offset = offset - step
        if offset < 0 then offset = 0 end
    elseif button == 5 then
        offset = offset + step
        if offset >= total then offset = total - 1 end
    end

    -- Write new offset
    f = io.open(offset_file, "w")
    if f then
        f:write(tostring(offset) .. "\n")
        f:close()
    end

    -- Mark manual scroll timestamp (pauses auto-scroll)
    f = io.open(manual_file, "w")
    if f then
        f:write(tostring(os.time()) .. "\n")
        f:close()
    end
end
