// = res://client/ui/shaders/cyber_button.gdshader =
shader_type canvas_item;

// Uniforms для анимации без _process
uniform float hover_amount : hint_range(0.0, 1.0) = 0.0;
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.5;
uniform vec4 accent_color : source_color = vec4(0.0, 0.941, 1.0, 1.0);

// Срезанные углы (передаются из GDScript)
uniform float cut_size : hint_range(4.0, 32.0) = 10.0;
uniform float notch_size : hint_range(4.0, 32.0) = 14.0;

void fragment() {
    vec2 uv = UV;
    vec2 size = SCREEN_PIXEL_SIZE * textureSize(TEXTURE, 0);
    
    // Нормализованные координаты 0-1
    vec2 norm = uv / size;
    
    // Маска срезанных углов
    float alpha = 1.0;
    
    // Top-right срез
    float tr_dist = distance(norm, vec2(1.0, 0.0));
    float tr_threshold = cut_size / min(size.x, size.y);
    if (tr_dist < tr_threshold * 1.5) {
        alpha = 0.0;
    }
    
    // Bottom-left вырез
    float bl_dist = distance(norm, vec2(0.0, 1.0));
    float bl_threshold = notch_size / min(size.x, size.y);
    if (bl_dist < bl_threshold * 1.5) {
        alpha = 0.0;
    }
    
    // Базовый цвет
    vec4 color = texture(TEXTURE, uv);
    
    // Hover tint
    if (hover_amount > 0.0) {
        color.rgb = mix(color.rgb, accent_color.rgb, hover_amount * 0.3);
        color.rgb += accent_color.rgb * hover_amount * glow_intensity * 0.1;
    }
    
    COLOR = vec4(color.rgb, color.a * alpha);
}