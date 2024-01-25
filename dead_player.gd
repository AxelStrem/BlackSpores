extends RigidBody3D

var regress = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	regress -= delta
	var sat = regress
	if sat < 0.01:
		sat = 0.01
	var bri = regress*0.2 + 0.8
	if bri < 0.2:
		bri = 0.2
	#var env = get_parent().find_child("WorldEnvironment")
	#env.environment.adjustment_saturation = sat
	#env.environment.adjustment_brightness = bri
