shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void light() {
	// Called for every pixel for every light affecting the material.
}

void fragment() {
	if (VERTEX.x > 0.95) {
		discard;
	}
	ALBEDO = vec3(10.0, 10.0, 0.0);
}