extends Node3D

var player = null

var target_transform = null
var current_transform = null
var starting_transform = null

var prog = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	var game = Global.get_game_root(self)
	if game!=null:
		player = game.get_player()
	player.global_transform = $PlayerPosDefault.global_transform


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target_transform != null:
		prog += delta
		if prog >= 1.0:
			prog = 1.0
		current_transform = starting_transform.interpolate_with(target_transform,prog)
		player.global_transform = current_transform
		if prog >= 1.0:
			target_transform = null
			prog = 0.0


func _on_character_button_clicked():
	if target_transform != null:
		return
	target_transform = $PlayerPosCharacter.global_transform
	starting_transform = player.global_transform
	current_transform = starting_transform


func _on_button_back_clicked():
	if target_transform != null:
		return
	target_transform = $PlayerPosDefault.global_transform
	starting_transform = player.global_transform
	current_transform = starting_transform
