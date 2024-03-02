shader_type spatial;
render_mode unshaded, skip_vertex_transform;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise_texture : repeat_enable, filter_linear;
uniform float flicker_frequency = 0.5;
uniform float flicker_amplitude = 0.5;

varying vec3 center_world;
varying vec3 center_view;
varying vec3 center_proj;

float schlick(float cos_theta) {
	float ior = 1.5;
	float r0 = ((1.0 - ior) / (1.0 + ior));
	r0 *= r0;
	return r0 + (1.0 - r0) * pow(1.0 - cos_theta, 5.0);
}

void vertex() {
	center_world = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	center_view = (MODELVIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec4 center_proj_w = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0);
	center_proj = center_proj_w.xyz / center_proj_w.w;
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 frag_proj = vec3(SCREEN_UV * 2.0 - 1.0, FRAGCOORD.z);
	vec4 frag_view = INV_PROJECTION_MATRIX * vec4(frag_proj, 0.0);
	frag_view.xyz /= frag_view.w;
	vec4 frag_world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(frag_proj, 1.0);
	frag_world.xyz /= frag_world.w;
	vec3 camera_direction = normalize(frag_world.xyz - CAMERA_POSITION_WORLD);
	float camera_distance = length(frag_world.xyz - CAMERA_POSITION_WORLD);
	float cos_theta = dot(-camera_direction, NORMAL);
	float fresnel = schlick(cos_theta);
	
	float noise = textureLod(noise_texture, vec2(TIME * flicker_frequency, 0.0), 0).r * flicker_amplitude;
	
	vec3 reflected = center_world + (center_world - frag_world.xyz);
	vec4 reflected_proj = PROJECTION_MATRIX * VIEW_MATRIX * vec4(reflected, 1.0);
	reflected_proj.xyz /= reflected_proj.w;
	vec2 aspect = vec2(VIEWPORT_SIZE.x / VIEWPORT_SIZE.y, 1.0);
	float dist_center = length(frag_proj.xy * aspect - center_proj.xy * aspect);
	float distortion = -10.0 * pow(1.0 - dist_center, 5.0 + noise);
	vec2 distorted_proj = reflected_proj.xy * (1.0 + distortion);
	vec2 uv = distorted_proj.xy * 0.5 + 0.5;
	vec2 center_uv = center_proj.xy * 0.5 + 0.5;
	
	float black = clamp(1000.0 * pow(dist_center * camera_distance, 8.0 + noise), 0.0, 1.0);
	
	vec3 color = mix(textureLod(screen_texture, uv, 0).rgb,
		textureLod(screen_texture, center_uv, 0).rgb,
		clamp(5.0 * (fresnel - 0.1), 0.0, 1.0));
	color *= 1.0 + fresnel;
	color *= black;
	
	ALBEDO = color;
	EMISSION = color;
}

