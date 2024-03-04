extends Node3D

var research_points = 0
var levels = [0,0,0,0,0,0]
var perks = Global.perks_array.duplicate()
var config = ConfigFile.new()
var mainScene = preload("res://main.tscn")
var main_instance
var mouse_sens = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	config.load("user://scores.cfg")
	mouse_sens = config.get_value("settings", "mouse_sensitivity",1.0)
	research_points = config.get_value("player", "research_points",0)
	for i in range(levels.size()):
		levels[i] = config.get_value("player", "level{0}".format({0:i}), 0)
	for i in range(perks.size()):
		perks[i] = config.get_value("player", "perk{0}".format({0:i}), 0)
	_on_start_button_button_clicked()
	

func update_config(rp, lvs, prks):
	research_points = rp
	levels = lvs
	perks = prks
	save_config()

func _on_start_button_button_clicked():	
	$startButton.deactivate()
	$closeButton.deactivate()
	main_instance = mainScene.instantiate()
	main_instance.load_config(research_points, levels, perks)	
	var player = main_instance.find_child("player")
	player.research_points = research_points
	player.mouse_sens = mouse_sens
	var env = main_instance.find_child("WorldEnvironment")
	env.environment.adjustment_saturation = 1
	env.environment.adjustment_brightness = 1
	self.add_child(main_instance)
	main_instance.restart_signal.connect(on_restart)
	main_instance.to_menu_signal.connect(return_to_menu)
	main_instance.update_config.connect(update_config)
	main_instance.load_config(research_points, levels, perks)
	player.got_research_point_signal.connect(_add_research_point)
	player.to_menu_signal.connect(return_to_menu)
	
func on_restart():
	Global.first_run = false
	main_instance.queue_free()
	_on_start_button_button_clicked()

func return_to_menu():
	#$startButton.activate()
	#$closeButton.activate()
	#main_instance.queue_free()
	
	get_tree().quit()

func save_config():
	config.set_value("player","research_points", research_points)
	for i in range(levels.size()):
		config.set_value("player", "level{0}".format({0:i}), levels[i])
	for i in range(perks.size()):
		config.set_value("player", "perk{0}".format({0:i}), perks[i])
	config.save("user://scores.cfg")

func _on_close_button_clicked():
	get_tree().quit()

func _add_research_point():
	research_points+=1
	save_config()
