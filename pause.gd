extends Node3D
var paused = false
var player

func _ready():
	player = get_parent().find_child("player")

func _physics_process(_delta):
	if player==null:
		return
	if Input.is_action_just_pressed("pause_game"):
		if get_tree().is_paused():
			get_tree().paused = false
			player._hide_menu()
		else:
			get_tree().paused = true
			player._show_menu()

