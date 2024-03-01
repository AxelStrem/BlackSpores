extends Node

var spore_scale = 1.0
var first_run = true

var perks_array = [0,0,0,0,0,0,0,0,0,0]

var picked_nums = [-1, -1, -1]

var level_scenes = [
	[preload("res://levels/chamber01.tscn"), 1.0],
 	[preload("res://levels/chamber02.tscn"), 1.0],
 	[preload("res://levels/chamber_troll.tscn"), 1.0],
	[preload("res://levels/chamber04_reversed.tscn"),0.8],
	[preload("res://levels/chamber04.tscn"), 0.2],
	[preload("res://levels/chamber05.tscn"), 1.0],
	[preload("res://levels/chamber06.tscn"), 0.5],
	[preload("res://levels/chamber06_alt.tscn"), 0.5],
	[preload("res://levels/chamber07.tscn"), 1.0],
	[preload("res://levels/chamber08.tscn"), 0.5],
	[preload("res://levels/chamber08_alt.tscn"), 0.5],
	[preload("res://levels/chamber09.tscn"), 1.0]
]

var test_chamber_scene = preload("res://levels/test_chamber.tscn")

var victory_scene = preload("res://levels/chamber_victory.tscn")
var total_chambers = 20
var test_chamber = false

func random_direction():
	var a = randf_range(0, TAU)
	var z = randf_range(-1.0,1.0)
	return Vector3(cos(a),sin(a),z)

func roll_num():
	var prob_sum = 0.0
	var prob_roll = []
	for l in level_scenes:
		prob_sum+=l[1]
		prob_roll.append(prob_sum)
	
	var picked = picked_nums.back()
	while picked_nums.find(picked)!=-1:
		var p = randf()*prob_sum
		for i in range(level_scenes.size()):
			picked = i
			if p < prob_roll[i]:
				break
	
	picked_nums.pop_front()
	picked_nums.append(picked)
	
	return picked

func generate_level(number):
	if number > total_chambers:
		return null
		
	var picked = roll_num()
		
	var scene = victory_scene
	if number < total_chambers:
		scene = level_scenes[picked][0]
	if test_chamber:
		scene = test_chamber_scene	
	
	var l = scene.instantiate()
	l.level_number = number
	l.level_difficulty = 10.0 + number
	return l

func get_game_root(node):
	var p = node.get_parent()
	while p!=null and !p.is_in_group("game"):
		p = p.get_parent()
	return p
	
func get_level_root(node):
	var p = node.get_parent()
	while p!=null and !p.is_in_group("level"):
		p = p.get_parent()
	return p


func list_children_recursive(node):
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(list_children_recursive(N))
		else:
			nodes.append(N)
	return nodes
