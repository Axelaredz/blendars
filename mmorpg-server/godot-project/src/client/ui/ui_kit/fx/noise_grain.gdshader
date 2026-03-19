// res://client/ui/ui_kit/fx/noise_grain.gdshader
shader_type canvas_item;

uniform float intensity : hint_range(0.0, 0.2) = 0.04;
uniform float speed : hint_range(0.0, 30.0) = 15.0;

// Pseudo-random
float random(vec2 co) {
    return fract(
        sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453
    );
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // Шум, меняющийся каждый кадр
    float noise = random(UV * vec2(
        floor(TIME * speed),
        floor(TIME * speed * 1.3)
    ));
    noise = (noise - 0.5) * 2.0 * intensity;
    
    vec3 result = tex.rgb + vec3(noise);
    COLOR = vec4(clamp(result, 0.0, 1.0), tex.a);
}