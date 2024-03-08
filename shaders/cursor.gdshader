shader_type spatial;
render_mode unshaded, depth_test_disabled;

varying vec3 center_world;
varying vec3 center_view;
varying vec3 center_proj;

void vertex() {
	center_world = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	center_view = (MODELVIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec4 center_proj_w = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0);
	center_proj = center_proj_w.xyz / center_proj_w.w;
}

void fragment() {
	float depth = distance(NODE_POSITION_WORLD, CAMERA_POSITION_WORLD);
	vec3 frag_proj = vec3(SCREEN_UV * 2.0 - 1.0, FRAGCOORD.z);
	vec2 aspect = vec2(VIEWPORT_SIZE.x / VIEWPORT_SIZE.y, 1.0);
	float dist_center = length(frag_proj.xy * aspect - center_proj.xy * aspect) * depth;
	vec3 color = vec3(float(dist_center > 0.018));
	ALBEDO = color;
}
