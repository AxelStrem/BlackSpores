extends Node

var spore_scale = 1.0

var level_scenes = [preload("res://levels/chamber01.tscn"), preload("res://levels/chamber02.tscn")]
var total_chambers = 30

func random_direction():
	var a = randf_range(0, TAU)
	var z = randf_range(-1.0,1.0)
	return Vector3(cos(a),sin(a),z)

func generate_level():
	var scene = level_scenes.pick_random()
	return scene.instantiate()
