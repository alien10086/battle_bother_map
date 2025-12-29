shader_type canvas_item;

uniform vec4 grid_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform float line_thickness : hint_range(0.0, 0.2) = 0.05;
uniform vec2 tile_size = vec2(120.0, 104.0);

varying vec2 world_pos;

void vertex() {
	// 获取世界坐标或相对于 CanvasItem 的局部坐标
	world_pos = VERTEX;
}

// 六边形距离函数 (平顶)
float hex_dist(vec2 p, float r) {
	p = abs(p);
	float d = dot(p, normalize(vec2(1.0, 1.73205)));
	return max(d, p.x) - r;
}

void fragment() {
	// 平顶六边形布局参数
	// 水平间距 = 0.75 * W
	// 垂直间距 = H
	float w = tile_size.x;
	float h = tile_size.y;
	
	vec2 grid = vec2(w * 0.75, h);
	
	// 计算两个候选网格点（处理偏移）
	vec2 p1 = mod(world_pos, grid) - grid * 0.5;
	vec2 p2 = mod(world_pos - grid * 0.5, grid) - grid * 0.5;
	
	vec2 p;
	if (length(p1) < length(p2)) {
		p = p1;
	} else {
		p = p2;
	}
	
	// 计算到边缘的距离
	// r 是内切圆半径，平顶六边形 r = w/2
	float r = w * 0.5;
	float dist = hex_dist(p, r);
	
	// 边缘高亮逻辑
	// 使用 line_thickness 控制宽度
	float border = smoothstep(-w * line_thickness, 0.0, dist);
	
	vec4 tex_color = texture(TEXTURE, UV);
	
	// 混合颜色：在原有纹理基础上叠加强调色
	// 如果 tex_color.a 为 0，说明超出了瓦片范围，我们保持透明
	vec3 final_color = mix(tex_color.rgb, grid_color.rgb, border * grid_color.a);
	COLOR = vec4(final_color, tex_color.a);
	
	// 调试模式：如果没效果，取消下面一行的注释，整个地图会变成红色网格
	// COLOR = vec4(grid_color.rgb, border * grid_color.a);
}
