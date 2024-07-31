shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
// float used as a boolean
uniform float outline_active : hint_range(0.0, 1.0, 0.01);
// float used as a boolean
uniform float ignore_modulate : hint_range(0.0, 1.0, 0.01);
// float used as a boolean
uniform float use_gradient : hint_range(0.0, 1.0, 0.01);

uniform sampler2D gradient : repeat_enable;
uniform float scroll_speed : hint_range(-2.0, 2.0, 0.1);
uniform float scroll_offset = 0.0;
// 0 is hoz, 1 is vert
uniform float scroll_dir : hint_range(0.0, 1.0, 0.01);

uniform int sheet_columns = 1;
uniform int sheet_rows = 1;


varying vec4 modulate;

void vertex()
{
    modulate = COLOR;
}

vec4 texturePointSmooth(sampler2D tex, vec2 uv) {
    vec2 size = vec2(textureSize(tex, 0));
    vec2 pixel = vec2(1.0) / size;
    uv -= pixel * vec2(0.5);
    vec2 uv_pixels = uv * size;
    vec2 delta_pixel = fract(uv_pixels) - vec2(0.5);
    vec2 ddxy = fwidth(uv_pixels);
    vec2 mip = log2(ddxy) - 0.5;
    return textureLod(tex, uv + (clamp(delta_pixel / ddxy, 0.0, 1.0) - delta_pixel) * pixel, min(mip.x, mip.y));
}

vec2 uvPointSmooth(sampler2D tex, vec2 uv) {
	vec2 size = vec2(textureSize(tex, 0));
    vec2 pixel = vec2(1.0) / size;
    uv -= pixel * vec2(0.5);
    vec2 uv_pixels = uv * size;
    vec2 delta_pixel = fract(uv_pixels) - vec2(0.5);
    vec2 ddxy = fwidth(uv_pixels);
 	return uv + (clamp(delta_pixel / ddxy, 0.0, 1.0) - delta_pixel) * pixel;
}


void fragment() {
	vec4 Texture = texturePointSmooth(TEXTURE, UV);
	COLOR = Texture.rgba;
	
	float size_x = 1.0/float(textureSize(TEXTURE, 0).x);
	float size_y = 1.0/float(textureSize(TEXTURE, 0).y);
	vec4 sprite_color = COLOR;
		vec2 sprite_sheet_size = vec2(textureSize(TEXTURE,0));
		vec2 frame_size;
		frame_size.x = sprite_sheet_size.x/float(sheet_columns);
		frame_size.y = sprite_sheet_size.y/float(sheet_rows);
		vec4 texture_color = texture(TEXTURE, UV);
		vec2 current_point = sprite_sheet_size * UV;
		float row = floor(current_point.y / frame_size.y);
		float column = floor(current_point.x / frame_size.x);
		vec2 max_point = (frame_size * vec2(column, row)) + frame_size;
		vec2 new_uv = 1.0 - (max_point - current_point) / frame_size;
	vec2 gradient_uv = uvPointSmooth(TEXTURE, new_uv);
	vec4 gradient_color = texture(gradient, vec2(mix(gradient_uv.x, gradient_uv.y, scroll_dir) + TIME * scroll_speed + scroll_offset), 0);
	vec4 outline_color_actual = mix(outline_color, gradient_color, use_gradient);
	float alpha = -4.0 * sprite_color.a;

	alpha += texturePointSmooth(TEXTURE, UV + vec2(size_x, 0)).a;
	alpha += texturePointSmooth(TEXTURE, UV + vec2(-size_x, 0)).a;
	alpha += texturePointSmooth(TEXTURE, UV + vec2(0, size_y)).a;
	alpha += texturePointSmooth(TEXTURE, UV + vec2(0, -size_y)).a;

	alpha = mix(0.0, alpha, outline_active);
	vec4 final_color = mix(sprite_color, outline_color_actual, clamp(alpha, 0.0, 1.0));
	COLOR = vec4(final_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
	COLOR = mix(COLOR * modulate, COLOR, ignore_modulate);
}