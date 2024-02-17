shader_type spatial;

uniform float progress = 0.5;
uniform sampler2D map;


void fragment() {
	float v = texture(map, UV).r;
	if (v < 0.01)
		discard;
	v -= progress;
	if (v > 0.002)
		discard;
	if (v > -0.002)
		ALPHA = 0.5 - v*250.0;	
	ALBEDO = vec3(0.0,0.0,0.0);
}

void light() {
	
}
