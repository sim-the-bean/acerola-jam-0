shader_type spatial;
render_mode unshaded;

uniform sampler2D hud_viewport : source_color, repeat_disable, filter_nearest;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec4 hud = textureLod(hud_viewport, SCREEN_UV, 0);
	ALBEDO = hud.rgb;
	ALPHA = hud.a;
}
