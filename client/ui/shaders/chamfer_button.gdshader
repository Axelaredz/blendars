shader_type canvas_item;

// CHAMFER BUTTON SHADER
// Скошенные углы для кнопок и панелей

// Основные параметры
uniform bool chamfer_enabled = false;
uniform float chamfer_size : hint_range(4.0, 64.0) = 20.0;

// Какие угры скошены
uniform bool chamfer_bottom_right = false;
uniform bool chamfer_top_left = false;

// Цвета
uniform vec4 bg_color : source_color = vec4(1.0, 0.72, 0.42, 1.0);
uniform vec4 border_color : source_color = vec4(1.0, 0.72, 0.42, 1.0);
uniform float border_width : hint_range(0.0, 8.0) = 2.0;

// Hover эффект
uniform float hover_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 hover_color : source_color = vec4(1.0, 0.475, 0.776, 1.0);
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.5;

void fragment() {
	vec2 uv = UV;
	
	// BASE SHAPE MASK
	float alpha = 1.0;
	
	if (chamfer_enabled) {
		vec2 norm = uv;
		
		// Bottom-right chamfer
		if (chamfer_bottom_right) {
			vec2 rel = (norm - vec2(1.0, 0.0)) * vec2(1.0, -1.0);
			if (rel.x > 0.0 && rel.y > 0.0) {
				float dist = rel.x + rel.y;
				float chamfer_dist = chamfer_size * 0.012;
				if (dist < chamfer_dist) {
					alpha = 0.0;
				}
			}
		}
		
		// Top-left chamfer
		if (chamfer_top_left) {
			vec2 rel = (norm - vec2(0.0, 1.0)) * vec2(-1.0, 1.0);
			if (rel.x > 0.0 && rel.y > 0.0) {
				float dist = rel.x + rel.y;
				float chamfer_dist = chamfer_size * 0.012;
				if (dist < chamfer_dist) {
					alpha = 0.0;
				}
			}
		}
	}
	
	// BORDER
	float border_dist = border_width * 0.01;
	vec2 norm = uv;
	float edge_dist = min(min(norm.x, 1.0 - norm.x), min(norm.y, 1.0 - norm.y));
	
	if (chamfer_enabled && chamfer_bottom_right) {
		vec2 rel = (norm - vec2(1.0, 0.0)) * vec2(1.0, -1.0);
		if (rel.x > 0.0 && rel.y > 0.0) {
			float dist = rel.x + rel.y;
			float chamfer_dist = chamfer_size * 0.012;
			edge_dist = min(edge_dist, max(0.0, dist - chamfer_dist));
		}
	}
	if (chamfer_enabled && chamfer_top_left) {
		vec2 rel = (norm - vec2(0.0, 1.0)) * vec2(-1.0, 1.0);
		if (rel.x > 0.0 && rel.y > 0.0) {
			float dist = rel.x + rel.y;
			float chamfer_dist = chamfer_size * 0.012;
			edge_dist = min(edge_dist, max(0.0, dist - chamfer_dist));
		}
	}
	
	// COLOR
	vec4 final_color = bg_color;
	
	// Hover effect
	if (hover_amount > 0.0) {
		final_color.rgb = mix(final_color.rgb, hover_color.rgb, hover_amount * 0.4);
		final_color.rgb += hover_color.rgb * hover_amount * glow_intensity * 0.15;
	}
	
	// Border color
	if (edge_dist < border_dist) {
		final_color = border_color;
	}
	
	COLOR = vec4(final_color.rgb, final_color.a * alpha);
}
