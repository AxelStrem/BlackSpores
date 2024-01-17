extends Node3D

var black_spore_scene = preload("res://black_spore.tscn")

var active_spores = []

var black_shit_count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_black_shit():
	black_shit_count += 1
	print(black_shit_count)
	

func remove_shit():
	black_shit_count -= 1
	print(black_shit_count)

func add_active_spore(s):
	active_spores.append(s)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var sproc = 0
	while active_spores.size()>0:
		for s in active_spores:
			var spore = black_spore_scene.instantiate()
			s.get_parent().add_child(spore)	
			spore.global_transform = s.global_transform
			spore.global_position += Vector3((randf()*2.0-1.0),  (randf()*2.0-1.0), (randf()*2.0-1.0))*3.0*Global.spore_scale
			spore.spawner = s
			spore.wait_init = 2
			sproc+=1
			if sproc > 20:
				active_spores.clear()
				return
	pass
