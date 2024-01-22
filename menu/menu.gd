extends Node3D

var research_points = 0
var config = ConfigFile.new()
var mainScene = preload("res://main.tscn")
var main_instance
# Called when the node enters the scene tree for the first time.
func _ready():
	config.load("user://scores.cfg")
	research_points = config.get_value("player", "research_points",0)

func _on_start_button_button_clicked():	
	main_instance = mainScene.instantiate()
	var player = main_instance.find_child("player")
	player.research_points = research_points
	var env = main_instance.find_child("WorldEnvironment")
	env.environment.adjustment_saturation = 1
	env.environment.adjustment_brightness = 1
	self.add_child(main_instance)
	main_instance.restart_signal.connect(on_restart)
	main_instance.to_menu_signal.connect(return_to_menu)	
	player.got_research_point_signal.connect(_add_research_point)
	player.to_menu_signal.connect(return_to_menu)
	
func on_restart():
	main_instance.queue_free()
	_on_start_button_button_clicked()

func return_to_menu():
	main_instance.queue_free()

func _on_close_button_clicked():
	config.set_value("player","research_points", research_points)
	config.save("user://scores.cfg")
	get_tree().quit()

func _add_research_point():
	research_points+=1
