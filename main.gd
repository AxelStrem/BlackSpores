extends Node3D

var black_shit_count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_black_shit():
	black_shit_count += 1
	print(black_shit_count)
	

func remove_shit():
	black_shit_count -= 1
	print(black_shit_count)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
