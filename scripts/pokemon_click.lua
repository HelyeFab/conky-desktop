require 'cairo'

local btn_png = os.getenv("HOME") .. "/.config/conky/pokemon/next_btn.png"
local generated = false

function conky_draw_button()
    if generated then return end

    local bw = 70
    local bh = 24
    local r = 6

    local cs = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, bw, bh)
    local cr = cairo_create(cs)

    -- Rounded button background
    cairo_new_path(cr)
    cairo_move_to(cr, r, 0)
    cairo_line_to(cr, bw - r, 0)
    cairo_arc(cr, bw - r, r, r, -math.pi/2, 0)
    cairo_line_to(cr, bw, bh - r)
    cairo_arc(cr, bw - r, bh - r, r, 0, math.pi/2)
    cairo_line_to(cr, r, bh)
    cairo_arc(cr, r, bh - r, r, math.pi/2, math.pi)
    cairo_line_to(cr, 0, r)
    cairo_arc(cr, r, r, r, math.pi, 3*math.pi/2)
    cairo_close_path(cr)
    cairo_set_source_rgba(cr, 1, 0.796, 0.02, 0.3)
    cairo_fill(cr)

    -- Button text
    cairo_select_font_face(cr, "Cantarell", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, 12)
    cairo_set_source_rgba(cr, 1, 0.796, 0.02, 1)
    local text = "NEXT"
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)
    local tx = (bw - extents.width) / 2 - extents.x_bearing
    local ty = (bh - extents.height) / 2 - extents.y_bearing
    cairo_move_to(cr, tx, ty)
    cairo_show_text(cr, text)

    cairo_surface_write_to_png(cs, btn_png)
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    generated = true
end

function conky_mouse_hook(button, x, y)
    if conky_window == nil then return end
    if type(button) == "table" and button.type == "button_down" then
        os.execute(os.getenv("HOME") .. "/.config/conky/pokemon_next.sh &")
    end
end
