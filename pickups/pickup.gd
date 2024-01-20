extends Node3D
var time=0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(delta*3)
	time+=delta
	$MeshInstance3D.position.y = sin(time*5)*0.2


func _on_area_3d_body_entered(body):
	queue_free()


func _on_area_3d_area_entered(area):
	queue_free()
