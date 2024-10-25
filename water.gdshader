shader_type spatial;

uniform sampler2D noise : hint_normal;
uniform vec3 color : source_color;
uniform sampler2D noise1 : hint_normal;

uniform vec2 wave_direction = vec2(2.0,0.0);
uniform vec2 wave_direction2 = vec2(0.0,1.0);

uniform sampler2D depth_texture : hint_depth_texture;
uniform float depth_distance : hint_range(0.0, 10.0, 0.05) = 0.5;

uniform float noise_scale = 10.0;

uniform float alpha : hint_range(0.0, 1.0, 0.05) = 0.5;

uniform float wave_speed : hint_range(0.0, 1.0, 0.005);
uniform float height_scale = 0.15;

uniform sampler2D screen_texture : hint_screen_texture;

uniform sampler2D wave;

uniform float thickness : hint_range(0.0,  20.0, 0.1) = 3.0;


varying vec3 world_pos;
varying float height;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_pos.xz / noise_scale + TIME * wave_speed).r;
	VERTEX.z += height * height_scale;
}

void fragment() {
	
	vec2 _uv = UV;
	
	vec2 time = (TIME * wave_direction) * wave_speed;
	vec2 time2 = (TIME * wave_direction2) * wave_speed;
	
	vec3 normalblend = mix(texture(noise, world_pos.xz + time).rgb, texture(noise1, world_pos.xz + time2).rgb, 0.5);
	
	float depth_r = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec4 world = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 -1.0, depth_r,1.0);
	
	world.xyz /= world.w;
	
	float depth_blend = smoothstep(world.z + depth_distance, world.z, VERTEX.z);
	
	//_uv.x = sin(TIME * wave_speed + (_uv.x + _uv.y));
	//_uv.y = cos(TIME * wave_speed * 2.0 + (_uv.y + _uv.x));
	
	
	depth_blend = exp(depth_blend*-thickness);
	
	vec3 screen = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	
	NORMAL_MAP = normalblend; //textureLod(noise, _uv, 50.0).xyz;
	
	NORMAL_MAP_DEPTH = 0.8;
	
	ALPHA = alpha;
	
	
	RIM = 0.5;
	
	ROUGHNESS = 0.5;
	
	ALBEDO = mix(screen * depth_blend, color, alpha);
	
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
