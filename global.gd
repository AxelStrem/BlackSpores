extends Node

var spore_scale = 1.0

var level_scenes = [
	preload("res://levels/chamber01.tscn"),
 	preload("res://levels/chamber02.tscn"),
 	preload("res://levels/chamber_troll.tscn")
]
var victory_scene = preload("res://levels/chamber_victory.tscn")
var total_chambers = 30

func random_direction():
	var a = randf_range(0, TAU)
	var z = randf_range(-1.0,1.0)
	return Vector3(cos(a),sin(a),z)

func generate_level(number):
	if number > total_chambers:
		return null
	var scene = victory_scene
	if number < total_chambers:
		scene = level_scenes.pick_random()
	var l = scene.instantiate()
	l.level_number = number
	return l
