extends Node3D

var ds_scene = preload("res://level_parts/building_blocks/door.tscn")
var dw_scene = preload("res://level_parts/building_blocks/door_w.tscn")

@export var window_probability = 0.5
@export var speed = 1.5
@export var gap = 4.0

var state = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	var dr = null
	if randf()<window_probability:
		dr = dw_scene.instantiate()
	else:
		dr = ds_scene.instantiate()
	$door.add_child(dr)
	
func unlock():
	state = 1

func _process(delta):
	if state == 1:
		$door.translate_object_local(Vector3.UP*delta*speed)
		gap-=delta*speed
		if gap<=0.0:
			state = 2
