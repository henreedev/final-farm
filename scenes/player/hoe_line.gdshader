shader_type canvas_item;

uniform sampler2D noise : hint_default_white, repeat_enable;
uniform int x_pixels = 40;
uniform int y_pixels = 40;
uniform float scroll_speed : hint_range(-2.0, 2.0, 0.05) = 0.2;
uniform float thickness_pow : hint_range(0.0, 4.0, 0.05) = 1.0;
uniform float thickness : hint_range(0.0, 1.0, 0.01) = 0.2;

void fragment(){ 

	float speed_factor = TIME * scroll_speed;
	vec2 grid_uv = vec2(round(UV.x * float(x_pixels)) / float(x_pixels), 
						round(UV.y * float(y_pixels)) / float(y_pixels));
	float thickness_factor = thickness;
	if (thickness_pow != 0.0) {
		thickness_factor = (1.0 - pow(COLOR.a, thickness_pow));
	}

	vec2 fake_UV = vec2(grid_uv.y * thickness_factor, COLOR.a + speed_factor);

	vec4 n = texture(noise, fake_UV);

	float grey = 1.0 - (0.2126 * n.r + 0.7152 * n.g + 0.0722 * n.b);

		if (grey < 0.55) { COLOR.a = COLOR.a * pow(grey, 2); }

		if (grey < 0.5) { discard; } 
	}