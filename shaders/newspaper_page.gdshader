shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_texture : source_color, repeat_disable, filter_linear;
uniform sampler2D canvas_texture : source_color, repeat_disable, filter_linear;

void fragment() {
	vec4 canvas = texture(canvas_texture, UV);
	vec3 albedo = texture(albedo_texture, UV).rgb;
	ALBEDO = mix(albedo, albedo * canvas.rgb, canvas.a);
	ROUGHNESS = mix(1.0, 0.7, canvas.a);
}
