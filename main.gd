extends Node3D

@export var spread_spores = true
@export var spores_kill = true
@export var debug_items = false
@export var show_info = false
@export var show_spore_zone = false
@export var infinite_stamina = false
@export var test_chamber = false
@export var soundtrack = false
@export var reset_points = false

signal to_menu_signal
signal restart_signal
signal update_config

var black_spore_scene = preload("res://black_spore.tscn")
var black_ball_scene = preload("res://black_ball.tscn")

var active_spores = {}

var black_shit_count = 0

var spore_delay = 1.0
var spore_limit = 200


var total_timer = 0.0

var game_started = false

const spore_res = 1.0
var spore_loc = {}

var spore_level_list = []
var spore_area_list = []
var spore_mutex : Mutex
var spore_thread : Thread
var spore_semaphore : Semaphore
var spore_thread_exit = false
var spore_inner_nbors = []
var spore_outer_nbors = []
var spore_active_layer = {}
var spore_ref_dict = {}
var spore_density = 0.1

var ward_list = {}

var current_chamber_player = 0
var current_chamber_spore = 0

var character_menu = null
var research_points = 0
var plevels = []
var klevels = []

func save_character(rp, lv_dist, pk_list):
	research_points = rp
	plevels = lv_dist
	klevels = pk_list
	emit_signal("update_config", rp, lv_dist, pk_list)
	$player.update_profile(lv_dist, pk_list)
	
func load_character(pnode):
	character_menu = pnode
	pnode.set_points(research_points, plevels, klevels)
	$player.update_profile(plevels, klevels)	
	
func load_config(research_points_, levels, perks):
	if reset_points:
		research_points_ = 300
		levels = [0,0,0,0,0,0]
		perks = [0]
	research_points = research_points_
	plevels = levels
	klevels = perks
	if character_menu:
		character_menu.set_points(research_points_, plevels, klevels)
	$player.update_profile(plevels, klevels)	

class SporeCell:
	var position : Vector3
	var spread_class : int
	var callbacks : Array
	var parent : Node3D

func spores_at_chamber(c):
	if current_chamber_spore < c:
		current_chamber_spore = c

func add_ward(w):
	ward_list[w] = w.global_position
	
func remove_ward(w):
	ward_list.erase(w)

func hash_vec(pos : Vector3):
	return Vector3i(pos * spore_res)
	
func vec_to_pos(vec : Vector3i):
	return Vector3(vec / spore_res)

func roll_spawn_spore(parent, location):
	if show_spore_zone:
		call_deferred("spawn_pink",parent,location)
	if randf()<spore_density:
		call_deferred("spawn_spore",parent,location)
		
func activate_spore_cell(cell):
	roll_spawn_spore(cell.parent, cell.position)
	for cb in cell.callbacks:
		if cb[0]!=null:
			cb[0].call_deferred(cb[1], cb[2])

func get_nearby_spores(pos):
	var vec = hash_vec(pos)
	var res = []
	for p in spore_inner_nbors[1]:
		var r = vec + p
		if r in spore_ref_dict:
			res.append(spore_ref_dict[r])
	return res

const ward_radius = 10.0
func check_wards(vec, extra_radius):
	var p1 = Vector3(vec)
	for w in ward_list:
		var p2 = ward_list[w]
		if (p1-p2).length()<(ward_radius + extra_radius):
			return true
	return false

func expand_spores():
	if(!spread_spores):
		return
	
	var new_active = []
	var alst = spore_active_layer.keys()
	if alst.is_empty():
		return
	var rep = alst.size()*0.002
	if rep < 1:
		rep = 1
	for r in range(rep):
		var sp = alst.pick_random()
		if check_wards(sp, 0.0):
			continue
		var vel = spore_active_layer[sp]
		for nb in spore_outer_nbors[vel]:
			var v = sp + nb
			if v in spore_loc:
				var cell : SporeCell = spore_loc[v]
				new_active.append([v, cell.spread_class])
				activate_spore_cell(cell)
				spore_loc.erase(v)				
		for nb in spore_inner_nbors[vel]:
			var v = sp + nb
			spore_active_layer.erase(v)
			if v in spore_loc:
				var cell : SporeCell = spore_loc[v]
				activate_spore_cell(cell)
				spore_loc.erase(v)	
	#spore_active_layer.clear()
	for n in new_active:
		spore_active_layer[n[0]] = n[1]

func activate_pos(pos):
	spore_active_layer[hash_vec(pos)] = 2
	pass

func register_spore(sp):
	var vec = hash_vec(sp.global_position)
	spore_ref_dict[vec] = sp

func spawn_spore(s, pos):
	if s!=null:
		var bsc = black_spore_scene.instantiate()
		s.get_parent().add_child(bsc)
		bsc.global_position = pos
		bsc.global_basis = Basis.IDENTITY
		
func spawn_pink(s, pos):
	if s!=null:
		var bsc = black_ball_scene.instantiate()
		s.get_parent().add_child(bsc)
		bsc.global_position = pos
		bsc.global_basis = Basis.IDENTITY

func spore_render_shape(s : CollisionShape3D, spore_velocity):
	if s!=null and s.is_inside_tree():
		var trans = s.global_transform
		var sc = trans.basis
		var scc = sc.get_scale() * spore_res
		var sh : BoxShape3D = s.shape
		var sz = sh.size
		for x in range(ceil(-sz.x*scc.x/2), ceil(sz.x*scc.x/2)):
			for y in range(ceil(-sz.y*scc.y/2), ceil(sz.y*scc.y/2)):
				for z in range(ceil(-sz.z*scc.z/2), ceil(sz.z*scc.z/2)):
					var pos = Vector3(x,y,z)/scc
					pos = trans * pos
					var vec = hash_vec(pos)
					if spore_velocity<0:
						spore_loc.erase(vec)
					else:
						var cell = SporeCell.new()
						if vec in spore_loc:
							cell = spore_loc[vec]
						cell.position = pos
						cell.spread_class = spore_velocity
						cell.parent = s
						spore_loc[vec] = cell


func spore_render_level_in(level : Node3D, level_in : Vector3):
	var pos = level_in
	var vec = hash_vec(pos)
	for x in range(-9,10):
		for y in range(-9,10):
			for z in range(-9,10):
				var v = Vector3i(x,y,z)+vec
				if v in spore_loc:
					spore_loc[v].callbacks.append([level, "spores_in", null])
					
func spore_render_level_out(level : Node3D, level_out : Vector3):
	var pos = level_out
	var vec = hash_vec(pos)
	for x in range(-9,10):
		for y in range(-9,10):
			for z in range(-9,10):
				var v = Vector3i(x,y,z)+vec
				if v in spore_loc:
					spore_loc[v].callbacks.append([level, "spores_out", null])
		

func _spore_thread_body():
	var exit_loop = false
	while !exit_loop:
		spore_semaphore.wait()
		var process_level = null		
		spore_mutex.lock()
		exit_loop = spore_thread_exit
		if spore_level_list.size()>0:
			process_level = spore_level_list.pop_front()
		spore_mutex.unlock()
		if process_level!=null:
			process_level.render_spores(self)
				
				
func append_level(level):
	spore_mutex.lock()
	spore_level_list.append(level)
	spore_mutex.unlock()
	spore_semaphore.post()

func append_nbors(rad, ring):
	var R1 = rad
	var R12 = R1*R1
	var sinb = []
	var sonb = []
	for x in range(-R1, R1):
		for y in range(-R1, R1):
			for z in range(-R1, R1):
				var r2 = x*x + y*y + z*z
				if r2 < R12-ring:
					sinb.append(Vector3i(x,y,z))
				elif r2 <= R12:
					sonb.append(Vector3i(x,y,z))
	spore_inner_nbors.append(sinb)
	spore_outer_nbors.append(sonb)
				
# Called when the node enters the scene tree for the first time.
func _ready():
	spore_mutex = Mutex.new()
	spore_semaphore = Semaphore.new()
	spore_thread = Thread.new()
	spore_thread.start(_spore_thread_body)
	
	if soundtrack:
		$player/Camera/Soundtrack/Bass01.play()
	
	#set up nbors sets
	append_nbors(5, 10)
	append_nbors(8, 10)
	append_nbors(3, 5)
	
	Global.test_chamber = test_chamber
			
	$player.infinite_energy_cheat = infinite_stamina
	
	if debug_items:
		$player.antigrav_charges = 10
		$player.teleporter_charges = 7
		$player.ward_charges = 5
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

func _exit_tree():
	spore_mutex.lock()
	spore_thread_exit = true
	spore_mutex.unlock()
	spore_semaphore.post()
	spore_thread.wait_to_finish()

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
var dd = 0.0

var spore_timer = 0.5
var spore_timer_goal = 0.2
var spore_timer_sp = 0.3/60

func spore_timer_adjusted():
	var spore_speedup = 0.005*current_chamber_spore
	var spore_catchup = 1.0
	var dp = current_chamber_player - current_chamber_spore
	if dp >= 2:
		spore_catchup = 0.9
	if dp >= 3:
		spore_catchup = 0.8
	if dp >= 4:
		spore_catchup = 0.7
	if dp >= 5:
		spore_catchup = 0.5
	return spore_catchup * (spore_timer - spore_speedup)

func get_player():
	return $player

func _physics_process(delta):	
	if !game_started:
		return
	
	spore_timer -= spore_timer_sp*delta
	if spore_timer < spore_timer_goal:
		spore_timer = spore_timer_goal
		
	dd-=delta
	if dd < 0.0:
		expand_spores()
		dd += spore_timer_adjusted()
		
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
