shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (VERTEX.x > 0.935) {
		discard;
	}
	ALBEDO = vec3(10.0, 10.0, 0.0);
}