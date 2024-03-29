extends Node3D

var ds_scene = preload("res://level_parts/building_blocks/door.tscn")
var dw_scene = preload("res://level_parts/building_blocks/door_w.tscn")

@export var window_probability = 0.5
@export var speed = 1.5
@export var gap = 4.0
@export var no_top = false

var state = 0
var locks = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var dr = null
	if no_top:
		$doorway.remove_child($doorway/MeshInstance3D)
	if randf()<window_probability:
		dr = dw_scene.instantiate()
	else:
		dr = ds_scene.instantiate()
	$door.add_child(dr)
	
func unlock():
	state = 1
	$door/AudioStreamPlayer3D.play()
	for l in locks:
		if l != null:
			l.force_unlock()

func register_lock(l):
	locks.append(l)

func _process(delta):
	if state == 1:
		$door.translate_object_local(Vector3.UP*delta*speed)
		gap-=delta*speed
		if gap<=0.0:
			state = 2
