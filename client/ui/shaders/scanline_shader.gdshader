shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float scanline_count : hint_range(50.0, 800.0) = 300.0;
uniform float scanline_alpha : hint_range(0.0, 0.2) = 0.05;
uniform float aberration_amount : hint_range(0.0, 10.0) = 2.0;
uniform float flicker_speed : hint_range(0.0, 20.0) = 8.0;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    // Глитч-сдвиг по горизонтали
    float glitch_line = step(0.98 - intensity * 0.3, random(vec2(floor(uv.y * 40.0), floor(TIME * flicker_speed))));
    uv.x += glitch_line * intensity * 0.08 * (random(vec2(TIME)) - 0.5);

    // Хроматическая аберрация
    float ab = aberration_amount * intensity / 1000.0;
    float r = texture(TEXTURE, uv + vec2(ab, 0.0)).r;
    float g = texture(TEXTURE, uv).g;
    float b = texture(TEXTURE, uv - vec2(ab, 0.0)).b;
    float a = texture(TEXTURE, uv).a;

    // Сканлайны
    float scanline = sin(uv.y * scanline_count * 3.14159) * 0.5 + 0.5;
    float scan_mask = 1.0 - scanline_alpha * scanline * intensity;

    // Мерцание
    float flicker = 1.0 - intensity * 0.03 * random(vec2(floor(TIME * flicker_speed), 0.0));

    COLOR = vec4(r, g, b, a) * scan_mask * flicker;
}
