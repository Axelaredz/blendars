shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.4;
uniform float softness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 0.7);

void fragment() {
    vec2 center = UV - vec2(0.5);
    float dist = length(center);
    float vignette = smoothstep(radius, radius + softness, dist);
    COLOR = vec4(color.rgb, color.a * vignette);
}
