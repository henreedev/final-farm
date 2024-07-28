shader_type canvas_item;

uniform int amount = 40;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

void fragment()
{
	vec2 grid_uv = round(SCREEN_UV * float(amount)) / float(amount);
	
	vec4 text = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	COLOR = text;
}