// res://client/ui/ui_kit/fx/glow_text.gdshader
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 0.94, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 2.0) = 0.3;
uniform float glow_radius : hint_range(1.0, 10.0) = 3.0;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;
uniform float pulse_amount : hint_range(0.0, 0.5) = 0.1;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // Сэмплирование соседних пикселей для размытия
    float glow = 0.0;
    vec2 pixel_size = TEXTURE_PIXEL_SIZE * glow_radius;
    
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            glow += texture(
                TEXTURE, UV + vec2(x, y) * pixel_size
            ).a;
        }
    }
    glow /= 25.0;
    
    // Пульсация (20% — subtle анимация)
    float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_amount;
    
    vec3 glow_layer = glow_color.rgb * glow
        * glow_strength * pulse;
    vec3 result = tex.rgb + glow_layer;
    
    COLOR = vec4(result, tex.a);
}