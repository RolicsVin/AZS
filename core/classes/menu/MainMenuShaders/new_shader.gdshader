shader_type spatial;
render_mode unshaded, blend_mix;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float blur = 3.0;

void fragment() {
	vec2 screen_uv = SCREEN_UV;

	ALBEDO = textureLod(screen_texture, screen_uv, blur).rgb;
	ALPHA = 1.0;
}