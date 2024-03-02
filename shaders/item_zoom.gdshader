shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

uniform float blur_radius = 10.0;
uniform float sigma = 5.0;
uniform int blur_increment = 2;
uniform float saturation = 1.0;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

float gaussian(float s, float x, float y) {
	return (1.0 / sqrt(2.0 * PI * s * s)) * exp(-(x * x + y * y) / (2.0 * s * s));
}

vec3 blur(ivec2 uv, float r, float s) {
	vec3 col = vec3(0.0);
	float sum = 0.0;
	
	int radius = clamp(int(ceil(r)), 0, 50); // limit radius to 50 to prevent accidents
	for (int y = -radius; y <= radius; y += blur_increment) {
		for (int x = -radius; x <= radius; x += blur_increment) {
			float g = gaussian(s, float(x), float(y));
			col += texelFetch(screen_texture, uv + ivec2(x, y), 0).rgb * g;
			sum += g;
		}
	}
	
	return col / sum;
}

// naive approach
float luminance(vec3 color) {
	return dot(color, vec3(0.25, 0.5, 0.25));
}

vec3 saturate(vec3 color, float s) {
	return mix(vec3(luminance(color)), color, s);
}

void fragment() {
	ALBEDO = saturate(blur(ivec2(FRAGCOORD.xy), blur_radius, sigma), saturation);
}
