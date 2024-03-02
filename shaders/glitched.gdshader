shader_type spatial;
render_mode blend_add, depth_prepass_alpha, shadows_disabled;

const vec2[3] position_offset = vec2[](vec2(-0.707, -0.707), vec2(0.707, -0.707), vec2(0.0, 1.0));
const float[3] noise_offset = float[](0.0, 0.33, 0.66);
const vec3[3] albedo = vec3[](vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(0.0, 0.0, 1.0));

uniform int color : hint_range(0, 2, 1) = 0;
uniform vec4 albedo_color = vec4(vec3(1.0), 0.75);
uniform vec3 chromatic_aberration_strength = vec3(0.02);
uniform float glitchiness_amplitude = 1.0;
uniform float glitchiness_frequency = 1.0;
uniform sampler2D noise_texture : repeat_enable, filter_nearest;

void vertex() {
	vec2 noise = vec2(
		texture(noise_texture, vec2(noise_offset[color] + TIME * glitchiness_frequency, 0.0)).r * 2.0 - 1.0,
		texture(noise_texture, vec2(noise_offset[color] + TIME * glitchiness_frequency, 0.5)).r * 2.0 - 1.0) * glitchiness_amplitude;
	
	vec2 pos_offset = position_offset[color] * noise;
	vec3 offset = (INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(pos_offset, 0.0, 0.0)).xyz;
	offset *= chromatic_aberration_strength[color];
	
    VERTEX += offset;
}

void fragment() {
	vec3 col = albedo[color] * albedo_color.rgb;
	ALBEDO = col;
	ALPHA = albedo_color.a * max(max(col.r, col.g), col.b);
}

