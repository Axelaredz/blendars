// res://client/ui/ui_kit/fx/chromatic_aberration.gdshader
shader_type canvas_item;

uniform float strength : hint_range(0.0, 0.02) = 0.002;
uniform float edge_only : hint_range(0.0, 1.0) = 0.8;

void fragment() {
    vec2 center = vec2(0.5);
    float dist = distance(UV, center);
    
    // Эффект усиливается к краям (edge_only)
    float factor = mix(1.0, dist * 2.0, edge_only);
    vec2 offset = (UV - center) * strength * factor;
    
    float r = texture(TEXTURE, UV + offset).r;
    float g = texture(TEXTURE, UV).g;
    float b = texture(TEXTURE, UV - offset).b;
    float a = texture(TEXTURE, UV).a;
    
    COLOR = vec4(r, g, b, a);
}