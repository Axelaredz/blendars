// res://client/ui/ui_kit/fx/crt_scanlines.gdshader
shader_type canvas_item;

uniform float line_count : hint_range(100, 800) = 300.0;
uniform float opacity : hint_range(0.0, 0.3) = 0.08;
uniform float speed : hint_range(0.0, 5.0) = 0.5;
uniform float flicker_intensity : hint_range(0.0, 0.05) = 0.01;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // Горизонтальные линии
    float scanline = sin(
        (UV.y + TIME * speed * 0.01) * line_count * 3.14159
    );
    scanline = scanline * 0.5 + 0.5;
    scanline = pow(scanline, 1.5);
    
    // Лёгкое мерцание (20% — subtle анимация)
    float flicker = 1.0 - flicker_intensity
        * sin(TIME * 8.0)
        * sin(TIME * 12.3);
    
    vec3 final_color = tex.rgb * (1.0 - opacity * scanline) * flicker;
    COLOR = vec4(final_color, tex.a);
}