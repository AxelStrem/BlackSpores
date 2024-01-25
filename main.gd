extends Node3D

@export var spread_spores = true
@export var spores_kill = true
@export var debug_items = true
@export var show_info = true

signal to_menu_signal
signal restart_signal

var black_spore_scene = preload("res://black_spore.tscn")

var active_spores = {}

var black_shit_count = 0

var spore_delay = 1.0
var spore_limit = 200


var total_timer = 0.0

var game_started = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if debug_items:
		$player.antigrav_charges = 10
		$player.teleporter_charges = 10
		$player.ward_charges = 10
	if !show_info:
		$player/Camera/LabelFPS.hide()
		$player/Camera/LabelTime.hide()
		$player/Camera/LabelEnergy.hide()
		$player/Camera/LabelDead.hide()
		$player/Camera/LabelPoints.hide()
		$player/Camera/LabelConsumables.hide()
		$player/Camera/LabelDebug.hide()
	$player.lock_controls()
	pass # Replace with function body.

func start_game():
	game_started = true
	$player.unlock_controls()

func activate_spore(s):
	active_spores[s] = total_timer
	
func add_spore():
	black_shit_count+=1

func remove_spore():
	black_shit_count-=1

func deactivate_spore(s):
	active_spores.erase(s)
	
func active_spore_count():
	return active_spores.size()
	
func total_spore_count():
	return black_shit_count
	
func do_spores_kill():
	return spores_kill
	
func bs_sort(a, b):
	return a.age < b.age

func attempt_spawn(s):
	if s == null:
		return
	var spore = black_spore_scene.instantiate()
	var rad = 2.0*Global.spore_scale*s.current_scale
	rad*=randf_range(0.5,1.2)
	if rad < 3.0:
		rad = 3.0
	s.get_parent().add_child(spore)
	spore.global_transform = s.global_transform
	var shift_vec = Vector3(0.0,0.0,0.0)
	if s.spawner == null:
		shift_vec = Global.random_direction()*rad
	else:
		var or_dir = (s.global_position - s.spawner.global_position)
		if or_dir.length() == 0.0:
			or_dir = Global.random_direction()
		or_dir = or_dir.normalized()
		var d1 = or_dir.cross(Vector3(1.0,0.0,0.0)).normalized()
		var d2 = or_dir.cross(d1).normalized()
		var a = randf()*TAU
		var d = d1*cos(a)+d2*sin(a)
		var m = PI*(1.0-s.decay*0.8)
		var b = randf_range(-m, m)
		shift_vec = (cos(b)*or_dir + sin(b)*d)*rad
	spore.global_position += shift_vec
	spore.spawner = s
	spore.wait_init = 2
	s.attempts+=1

const attempts_per_frame = 10
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !game_started:
		return
	total_timer += delta
	
	if !spread_spores:
		active_spores.clear()
	if active_spores.size()<=attempts_per_frame:
			for s in active_spores:
				if s.age > spore_delay:
					attempt_spawn(s)
	else:
		var asp = []
		var rem = attempts_per_frame
		for s in active_spores:
			if s.age > spore_delay:
				asp.append(s)
		if black_shit_count < spore_limit:
			asp.shuffle()
			for i in range(0, attempts_per_frame>>1):
				if asp.size()>0:
					attempt_spawn(asp.back())
					asp.pop_back()
					rem-=1
		asp.sort_custom(bs_sort)
		for i in range(0, rem):
			if asp.size()>0:
				attempt_spawn(asp.back())
				asp.pop_back()
		if asp.size()>0 and black_shit_count < 100:
			attempt_spawn(asp.front())	
		


func _on_restart_button_button_clicked():
	restart_signal.emit()


func _on_quit_to_menu_button_clicked():
	to_menu_signal.emit()
