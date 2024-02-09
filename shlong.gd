extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func align_mesh(p1, p2, w):
	var sz = (p2-p1).length()
	if sz != 0.0:
		if(!Vector3.UP.cross(p2-p1).is_zero_approx()):
			$mesh.look_at_from_position((p1+p2)*0.5,p2)
	$mesh.scale.z = sz
	$mesh.scale.x = w
	$mesh.scale.y = w
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#align_mesh($p1.global_position, $p2.global_position)
	pass
