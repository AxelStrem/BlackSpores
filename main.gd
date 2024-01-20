extends Node3D

var black_spore_scene = preload("res://black_spore.tscn")

var active_spores = {}

var black_shit_count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func activate_spore(s):
	active_spores[s]=null
	
func deactivate_spore(s):
	active_spores.erase(s)

func attempt_spawn(s):
	if s == null:
		return
	var spore = black_spore_scene.instantiate()
	var rad = 1.0*Global.spore_scale*s.current_scale
	if rad < 3.0:
		rad = 3.0
	s.get_parent().add_child(spore)	
	spore.global_transform = s.global_transform
	var shift_vec = Vector3(0.0,0.0,0.0)
	if s.spawner == null:
		shift_vec = Vector3((randf()*2.0-1.0),  (randf()*2.0-1.0), (randf()*2.0-1.0))*rad
	else:
		var or_dir = (s.global_position - s.spawner.global_position).normalized()
		var d1 = or_dir.cross(Vector3(1.0,0.0,0.0)).normalized()
		var d2 = or_dir.cross(d1).normalized()
		var q = 0.25*or_dir
		var d3 = -d1 - q
		var d4 = -d2 - q
		d1 -= q
		d2 -= q
		var r1 = randf()**2
		var r2 = randf()**2
		var r3 = randf()**2
		var r4 = randf()**2
		shift_vec = (or_dir + r1*d1 + r2*d2 + r3*d3 + r4*d4)*rad
	spore.global_position += shift_vec
	spore.spawner = s
	spore.wait_init = 2
	s.attempts+=1

const attempts_per_frame = 20
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var sproc = 0
	if active_spores.size()<=attempts_per_frame:
		while active_spores.size()>0:
			for s in active_spores:
				attempt_spawn(s)
				sproc+=1
				if sproc > attempts_per_frame:
					active_spores.clear()
					return
	else:
		active_spores.shuffle()
		for i in range(0, attempts_per_frame):
			
			attempt_spawn(active_spores.back())
			active_spores.pop_back()
