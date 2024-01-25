extends MeshInstance3D

var center = Vector3(0.0,0.0,0.0)
var next_pos = Vector3(0.0,0.0,0.0)
var change_pos = 0.0
var next_scale = 0.5
# Called when the node enters the scene tree for the first time.
func _ready():
	center = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	change_pos -= delta
	if change_pos < 0.0:
		change_pos = 0.5+randf()*1.0
		next_pos = center + Global.random_direction()*1.3
		next_scale = 0.35 + randf()*0.3
	position.x = move_toward(position.x, next_pos.x, delta*0.5)
	position.y = move_toward(position.y, next_pos.y, delta*0.5)
	position.z = move_toward(position.z, next_pos.z, delta*0.5)
	scale.x = move_toward(scale.x, next_scale, delta*0.5)
	scale.y = move_toward(scale.y, next_scale, delta*0.5)
	scale.z = move_toward(scale.z, next_scale, delta*0.5)
	pass
