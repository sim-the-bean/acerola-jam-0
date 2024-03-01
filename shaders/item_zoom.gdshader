shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

uniform float blur_radius = 10.0;
uniform float sigma = 5.0;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

float gaussian(float x, float y) {
	return (1.0 / sqrt(2.0 * PI * sigma * sigma)) * exp(-(x * x + y * y) / (2.0 * sigma * sigma));
}

vec3 blur(ivec2 uv) {
	vec3 col = vec3(0.0);
	float sum = 0.0;
	
	int radius = min(int(ceil(blur_radius)), 50); // limit radius to 50 to prevent accidents
	for (int y = -radius; y <= radius; y++) {
		for (int x = -radius; x <= radius; x++) {
			float g = gaussian(float(x), float(y));
			col += texelFetch(screen_texture, uv + ivec2(x, y), 0).rgb * g;
			sum += g;
		}
	}
	
	return col / sum;
}

void fragment() {
	if (blur_radius >= 0.5) {
		ALBEDO = blur(ivec2(FRAGCOORD.xy));
	} else {
		ALBEDO = texture(screen_texture, SCREEN_UV).rgb;
	}
}
