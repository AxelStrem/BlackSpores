extends Node3D

@export var spawn_probability = 0.2

var pickups = [preload("res://pickups/datapoint.tscn"), preload("res://pickups/speedboost.tscn"), preload("res://pickups/antigrav_boots.tscn")]

func _ready():
	if randf()<=spawn_probability:
		var pu = pickups.pick_random().instantiate()
		add_child(pu)

