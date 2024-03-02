shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D source_texture : source_color, repeat_disable, filter_linear;
uniform vec3 chromatic_aberration_strength = vec3(5.0);
uniform vec2 red_offset = vec2(0.707, 0.707);
uniform vec2 green_offset = vec2(-0.707, 0.707);
uniform vec2 blue_offset = vec2(0.0, -1.0);
uniform float glitchiness_amplitude = 1.0;
uniform float glitchiness_frequency = 1.0;
uniform sampler2D noise_texture : repeat_enable, filter_nearest;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec2 size = vec2(textureSize(source_texture, 0));
	vec2 r_noise = vec2(
		texture(noise_texture, vec2(TIME * glitchiness_frequency, 0.0)).r * 2.0 - 1.0,
		texture(noise_texture, vec2(0.0, TIME * glitchiness_frequency)).r * 2.0 - 1.0) * glitchiness_amplitude;
	vec2 g_noise = vec2(
		texture(noise_texture, vec2(0.33 + TIME * glitchiness_frequency, 0.0)).r * 2.0 - 1.0,
		texture(noise_texture, vec2(0.0, 0.33 + TIME * glitchiness_frequency)).r * 2.0 - 1.0) * glitchiness_amplitude;
	vec2 b_noise = vec2(
		texture(noise_texture, vec2(0.66 + TIME * glitchiness_frequency, 0.0)).r * 2.0 - 1.0,
		texture(noise_texture, vec2(0.0, 0.66 + TIME * glitchiness_frequency)).r * 2.0 - 1.0) * glitchiness_amplitude;
	vec4 col_r = texture(source_texture, SCREEN_UV + (red_offset + r_noise) * chromatic_aberration_strength.r / size);
	vec4 col_g = texture(source_texture, SCREEN_UV + (green_offset + g_noise) * chromatic_aberration_strength.g / size);
	vec4 col_b = texture(source_texture, SCREEN_UV + (blue_offset + b_noise) * chromatic_aberration_strength.b / size);
	float source_depth = max(max(col_r.a, col_g.a), col_b.a);
	if (source_depth != 0.0) {
		ALBEDO = vec3(col_r.r, col_g.g, col_b.b);
		//ALPHA = (col_r.a + col_g.a + col_b.a) / 3.0;
		ALPHA = 0.75 * clamp((col_r.r + col_g.g + col_b.b) / 3.0, 0.0, 1.0);
		DEPTH = source_depth;
	} else {
		ALPHA = 0.0;
		DEPTH = 1.0;
	}
}
