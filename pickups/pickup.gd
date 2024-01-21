extends Node3D
var time=0

@export var pickup_type = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(delta*3)
	time+=delta
	$model.position.y = sin(time*5)*0.2


func _on_area_3d_body_entered(body):
	#body.SPEED*=2
	if body.pickup(pickup_type):
		queue_free()


func _on_area_3d_area_entered(_area):
	queue_free()
