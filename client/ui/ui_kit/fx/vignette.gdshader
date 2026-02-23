// res://client/ui/ui_kit/fx/vignette.gdshader
shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform float radius : hint_range(0.0, 1.0) = 0.7;
uniform float softness : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    float dist = distance(UV, vec2(0.5));
    float vignette = smoothstep(radius, radius - softness, dist);
    
    vec3 result = tex.rgb * mix(1.0 - intensity, 1.0, vignette);
    COLOR = vec4(result, tex.a);
}