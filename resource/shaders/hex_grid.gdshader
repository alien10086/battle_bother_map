shader_type canvas_item;

uniform vec4 grid_color : source_color = vec4(1.0, 1.0, 1.0, 0.3);
uniform float line_thickness : hint_range(0.0, 0.1) = 0.03;
uniform vec2 tile_size = vec2(120.0, 104.0);

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

// 平顶六边形距离函数
float hex_dist(vec2 p) {
	p = abs(p);
	float d = dot(p, normalize(vec2(1.0, 1.73205)));
	return max(d, p.x);
}

void fragment() {
	// 将局部坐标转换为相对于瓦片中心的坐标
	// 这里假设平顶六边形的水平间距是 0.75 * W, 垂直间距是 H
	vec2 size = tile_size;
	vec2 r = size * 0.5;
	
	// 计算六边形网格坐标 (简单的近似实现)
	vec2 h = vec2(size.x * 0.75, size.y);
	vec2 p = local_pos;
	
	vec2 a = mod(p, h) - h * 0.5;
	vec2 b = mod(p - h * 0.5, h) - h * 0.5;
	
	vec2 g = dot(a, a) < dot(b, b) ? a : b;
	
	float dist = hex_dist(g);
	float edge = smoothstep(r.x * (1.0 - line_thickness), r.x, dist);
	
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = mix(tex_color, grid_color, edge * grid_color.a);
}
