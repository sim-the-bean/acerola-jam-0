shader_type spatial;
render_mode unshaded, depth_test_disabled;


void fragment() {
	ALBEDO = vec3(SCREEN_UV, 0.0);
}
