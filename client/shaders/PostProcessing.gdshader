shader_type canvas_item;

// Параметры эффектов
uniform float chromatic_aberration : hint_range(0.0, 0.02) = 0.003;
uniform float noise_amount : hint_range(0.0, 1.0) = 0.08;
uniform float scanline_amount : hint_range(0.0, 1.0) = 0.15;
uniform float vignette_amount : hint_range(0.0, 1.0) = 0.35;
uniform float glitch_amount : hint_range(0.0, 1.0) = 0.05;
uniform float time_scale : hint_range(0.1, 5.0) = 1.0;

// Текстура экрана
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

float random(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 uv) {
	vec2 i = floor(uv);
	vec2 f = fract(uv);
	
	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));
	
	vec2 u = f * f * (3.0 - 2.0 * f);
	
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	float time = TIME * time_scale;
	vec2 uv = SCREEN_UV;
	
	// Glitch эффект - периодическое смещение
	float glitch_line = step(0.99, random(vec2(floor(time * 10.0), floor(uv.y * 20.0))));
	float glitch_offset = glitch_line * (random(vec2(time, uv.y)) - 0.5) * glitch_amount;
	uv.x += glitch_offset;
	
	// Chromatic Aberration - разделение каналов
	float ca_offset = chromatic_aberration;
	float r = texture(screen_texture, uv + vec2(ca_offset, 0.0)).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - vec2(ca_offset, 0.0)).b;
	vec3 color = vec3(r, g, b);
	
	// Добавляем шум
	float n = noise(uv * 10.0 + time * 5.0) * noise_amount;
	color += n * 0.5 - noise_amount * 0.25;
	
	// Scanlines (CRT эффект)
	float scanline = sin(uv.y * 800.0 + time * 2.0) * 0.5 + 0.5;
	scanline = pow(scanline, 1.5) * scanline_amount;
	color -= scanline * 0.5;
	
	// Дополнительные горизонтальные полосы (более заметные)
	float scanline2 = sin(uv.y * 200.0) * 0.5 + 0.5;
	color -= scanline2 * scanline_amount * 0.3;
	
	// Vignette (затемнение по краям)
	float vignette = 1.0 - length((uv - 0.5) * 1.2);
	vignette = smoothstep(0.0, vignette_amount, vignette);
	color *= vignette;
	
	// Легкое мерцание
	float flicker = 1.0 + (random(vec2(time * 0.1, 0.0)) - 0.5) * 0.02;
	color *= flicker;
	
	COLOR = vec4(color, 1.0);
}
