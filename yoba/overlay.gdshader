shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float progress = 0.5;
uniform sampler2D map;


void fragment() {
	float v = texture(map, UV).r;
	v*=1.5;
	vec3 col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	ALBEDO = vec3(0.0,0.0,0.0);
	if (v < 0.01)
	{
		//ALBEDO = ALBEDO;
		ALPHA = 0.0;
	}
	else
	{
		v -= progress;
		if (v > 0.002)
			ALPHA = 0.0;
		else if (v > -0.002)
			ALPHA = 0.5 - v*250.0;
	}
}

void light() {
	
}
