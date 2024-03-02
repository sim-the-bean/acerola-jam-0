shader_type spatial;
render_mode depth_prepass_alpha;

uniform vec4 albedo_color : source_color = vec4(1.0);

void fragment() {
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, FRAGCOORD.z);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	NORMAL = normalize(world.xyz);
	ALBEDO = albedo_color.rgb;
	ALPHA = FRAGCOORD.z;
}

