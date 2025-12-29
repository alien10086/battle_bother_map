shader_type canvas_item;

uniform vec4 grid_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform float line_thickness : hint_range(0.0, 0.2) = 0.05;
uniform vec2 tile_size = vec2(120.0, 140.0);

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

// 平顶六边形距离函数
float hex_dist(vec2 p, float r) {
	p = abs(p);
	// 0.866025 = sqrt(3)/2
	float d = dot(p, normalize(vec2(1.0, 1.73205)));
	return max(d, p.x) - r;
}

void fragment() {
	float w = tile_size.x;
	float h = tile_size.y;
	
	// Godot 平顶六边形排列逻辑：
	// 中心点偏移：每隔一列垂直偏移 0.5 * h
	// 水平间距：0.75 * w
	// 垂直间距：h
	
	vec2 size = vec2(w * 0.75, h);
	vec2 p = local_pos;
	
	// 修正偏移：Godot 的 (0,0) 瓦片中心通常在 (w/2, h/2)
	p -= vec2(w * 0.5, h * 0.5);
	
	vec2 p1 = mod(p, size * vec2(2.0, 1.0)); // 采样两列以处理交错
	
	// 计算两个候选中心的相对位置
	vec2 grid = vec2(w * 0.75, h);
	
	// 简化的六边形网格最近中心点查找
	vec2 a = mod(p, grid) - grid * 0.5;
	vec2 b = mod(p - grid * 0.5, grid) - grid * 0.5;
	
	vec2 g = dot(a, a) < dot(b, b) ? a : b;
	
	// r 为外接圆半径 (w/2)
	float r = w * 0.5;
	float dist = hex_dist(g, r);
	
	// 边缘高亮
	float edge = smoothstep(-w * line_thickness, 0.0, dist);
	
	vec4 tex_color = texture(TEXTURE, UV);
	
	// 只在有纹理的地方显示网格线
	if (tex_color.a > 0.01) {
		COLOR = mix(tex_color, grid_color, edge * grid_color.a);
	} else {
		discard;
	}
}
