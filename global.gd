extends Node

var spore_scale = 1.0
var first_run = true

var perks_array = [0,0,0,0,0,0,0,0,0,0,0,0]

var picked_nums = [-1]

var level_scenes = [
	[preload("res://levels/chamber01.tscn"), 1.0, 1],
 	[preload("res://levels/chamber02.tscn"), 1.0, 2],
 	[preload("res://levels/chamber_troll.tscn"), 1.0, 3],
	[preload("res://levels/chamber04_reversed.tscn"),0.8, 4],
	[preload("res://levels/chamber04.tscn"), 0.2, 4],
	[preload("res://levels/chamber05.tscn"), 1.0, 5],
	[preload("res://levels/chamber06.tscn"), 0.5, 6],
	[preload("res://levels/chamber06_alt.tscn"), 0.5, 6],
	[preload("res://levels/chamber07.tscn"), 1.0, 7],
	[preload("res://levels/chamber08.tscn"), 0.5, 8],
	[preload("res://levels/chamber08_alt.tscn"), 0.5, 8],
	[preload("res://levels/chamber09.tscn"), 1.0, 9],
	[preload("res://levels/chamber10.tscn"), 1.0, 10],
	[preload("res://levels/chamber11.tscn"), 100.0, 11]
]

var level_scenes1 = [
	[preload("res://levels/chamber01.tscn"), 1.0, 1],
 	[preload("res://levels/chamber02.tscn"), 1.0, 2],
	[preload("res://levels/chamber04_reversed.tscn"),0.8, 4],
	[preload("res://levels/chamber04.tscn"), 0.2, 4],
	[preload("res://levels/chamber05.tscn"), 1.0, 5],
	[preload("res://levels/chamber11.tscn"), 1.0, 11]
]

var level_scenes2 = [
	[preload("res://levels/chamber01.tscn"), 1.0, 1],
 	[preload("res://levels/chamber02.tscn"), 1.0, 2],
	[preload("res://levels/chamber04_reversed.tscn"),0.8, 4],
	[preload("res://levels/chamber04.tscn"), 0.2, 4],
	[preload("res://levels/chamber05.tscn"), 1.0, 5],
 	[preload("res://levels/chamber_troll.tscn"), 1.0, 3],
	[preload("res://levels/chamber06.tscn"), 0.5, 6],
	[preload("res://levels/chamber06_alt.tscn"), 0.5, 6],
	[preload("res://levels/chamber08.tscn"), 0.5, 8],
	[preload("res://levels/chamber08_alt.tscn"), 0.5, 8]
]

var level_scenes3 = [
	[preload("res://levels/chamber04_reversed.tscn"),0.8, 4],
	[preload("res://levels/chamber05.tscn"), 1.0, 5],
 	[preload("res://levels/chamber_troll.tscn"), 1.0, 3],
	[preload("res://levels/chamber06.tscn"), 0.5, 6],
	[preload("res://levels/chamber06_alt.tscn"), 0.5, 6],
	[preload("res://levels/chamber07.tscn"), 1.0, 7],
	[preload("res://levels/chamber08.tscn"), 0.5, 8],
	[preload("res://levels/chamber08_alt.tscn"), 0.5, 8],
	[preload("res://levels/chamber10.tscn"), 1.0, 10]
]

var level_scenes4 = [
	[preload("res://levels/chamber05.tscn"), 1.0, 5],
	[preload("res://levels/chamber06.tscn"), 0.5, 6],
	[preload("res://levels/chamber06_alt.tscn"), 0.5, 6],
	[preload("res://levels/chamber07.tscn"), 1.0, 7],
	[preload("res://levels/chamber09.tscn"), 1.0, 9],
	[preload("res://levels/chamber10.tscn"), 1.0, 10]
]

var test_chamber_scene = preload("res://levels/test_chamber.tscn")

var victory_scene = preload("res://levels/chamber_victory.tscn")
var total_chambers = 20
var test_chamber = false

func random_direction():
	var a = randf_range(0, TAU)
	var z = randf_range(-1.0,1.0)
	return Vector3(cos(a),sin(a),z)

func roll_num(scenes):
	var prob_sum = 0.0
	var prob_roll = []
	for l in scenes:
		prob_sum+=l[1]
		prob_roll.append(prob_sum)
	
	var picked = 0
	var sn = picked_nums.back()
	while picked_nums.find(sn)!=-1:
		var p = randf()*prob_sum
		for i in range(scenes.size()):
			picked = i
			if p < prob_roll[i]:
				break
		sn = scenes[picked][2]
	
	picked_nums.pop_front()
	picked_nums.append(sn)
	
	return picked

func generate_level(number):
	if number > total_chambers:
		return null
		
	var scenes = level_scenes
	if number <= 5:
		scenes = level_scenes1
	elif number <= 10:
		scenes = level_scenes2
	elif number <= 15:
		scenes = level_scenes3
	else:
		scenes = level_scenes4
	
		
	var picked = roll_num(scenes)
		
	var scene = victory_scene
	if number < total_chambers:
		scene = scenes[picked][0]
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
	
func is_an_ancestor(node, ancestor):
	if node == null:
		return false
	if node == ancestor:
		return true
	var p = node.get_parent()
	return is_an_ancestor(p, ancestor)
