shader_type spatial;
render_mode unshaded, skip_vertex_transform;

uniform sampler2D gradient : source_color, repeat_disable, filter_linear;

float schlick(float cos_theta) {
	float ior = 1.5;
	float r0 = ((1.0 - ior) / (1.0 + ior));
	r0 *= r0;
	return r0 + (1.0 - r0) * pow(1.0 - cos_theta, 5.0);
}

void vertex() {
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	float cos_theta = dot(-CAMERA_DIRECTION_WORLD, NORMAL);
	float fresnel = schlick(cos_theta);
	
	vec3 color = textureLod(gradient, vec2(pow(fresnel, 0.25) * 0.3, 0.0), 0).rgb;
	
	ALBEDO = color * 5.0;
}
