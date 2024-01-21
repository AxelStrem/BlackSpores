extends Node3D

var mainScene = preload("res://main.tscn")
var main_instance
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_button_clicked():	
	main_instance = mainScene.instantiate()
	var env = main_instance.find_child("WorldEnvironment")
	env.environment.adjustment_saturation = 1
	env.environment.adjustment_brightness = 1
	self.add_child(main_instance)
	main_instance.restart_signal.connect(on_restart)
	main_instance.to_menu_signal.connect(return_to_menu)
	
func on_restart():
	main_instance.queue_free()
	_on_start_button_button_clicked()

func return_to_menu():
	main_instance.queue_free()

func _on_close_button_clicked():
	get_tree().quit()

