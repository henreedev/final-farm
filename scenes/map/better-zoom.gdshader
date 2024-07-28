shader_type canvas_item;
//render_mode unshaded;

// outline color (black)
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform bool outline_active = false;
uniform bool ignore_modulate = false;

uniform bool use_gradient = false;
uniform sampler2D gradient : repeat_enable;
uniform float scroll_speed : hint_range(-2.0, 2.0, 0.1);

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
	vec4 outline_color_actual = outline_color;
	if (use_gradient) {
		outline_color_actual = texture(gradient, uvPointSmooth(TEXTURE, UV) + TIME * scroll_speed);
	}
	float alpha = -4.0 * sprite_color.a;
	if (!outline_active) {
		alpha = 0.0;
	} else {
		alpha += texturePointSmooth(TEXTURE, UV + vec2(size_x, 0)).a;
		alpha += texturePointSmooth(TEXTURE, UV + vec2(-size_x, 0)).a;
		alpha += texturePointSmooth(TEXTURE, UV + vec2(0, size_y)).a;
		alpha += texturePointSmooth(TEXTURE, UV + vec2(0, -size_y)).a;
	}
	vec4 final_color = mix(sprite_color, outline_color_actual, clamp(alpha, 0.0, 1.0));
	COLOR = vec4(final_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
	if (!ignore_modulate){
		COLOR = COLOR * modulate;
	}
}