extends "res://spore_consumable.gd"

@export var level_in : Node3D = null
@export var level_out : Node3D = null
@export var next_level : Node3D = null


func _ready():
	pass 


func player_N_levels_away(N):
	if N>=4:
		return
	if next_level == null:
		next_level = Global.generate_level()
		get_parent().add_child(next_level)
		var nl_in = next_level.level_in
		var nl_out = level_out
		var q1 = Quaternion(nl_out.global_basis)
		var q2 = Quaternion(nl_in.global_basis).inverse()
		next_level.global_basis = Basis(q1*q2)
		
		var sh = nl_out.global_position - nl_in.global_position
		next_level.global_position += sh
	next_level.player_N_levels_away(N+1)
		

func _on_player_entered(_body):
	player_N_levels_away(0)