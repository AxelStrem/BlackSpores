extends Node3D

var state = -3

var time = 0.0
var speed = 0.3
var lifetime = 0.0

var parent_spore = null
var children_spores = []
var radius = 0.0001

var shlong_scene = preload("res://shlong.tscn")
var shlong = null
var shlong_progress=0.1
var shlong_time = 1.0
var shlong_midpoint = Vector3(0.0,0.0,0.0)

var mat_ward = preload("res://entities/ward_spore.tres")
var mat_black = preload("res://black_spore.tres")
var ward_close = false

var type = 0

var game = null

# Called when the node enters the scene tree for the first time.
func _ready():
	time = randf()*0.5
	speed = 0.15+randf()*0.35
	type = randi_range(0,12)
	game = Global.get_game_root(self)

func _exit_tree():
	if game:
		game.total_spores -= 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(delta):
	lifetime+=delta
	if type != 0:
		if (type > 5 and lifetime > 15.0) or lifetime > 30.0:
			state = 3
			if shlong:
				remove_child(shlong)
				shlong = null
	elif lifetime > 30.0:
		speed=7.0
	if lifetime > 10.0:
		$GPUParticles3D.emitting = false
	if radius > 50.0:
		return
	if state < 0:
		state+=1
		if state==0:
			var overlaps = []
			if game!=null:
				overlaps = game.get_nearby_spores(self.global_position)#$parent_search.get_overlapping_areas()
			if overlaps.size()>0:
				var o = overlaps.pick_random()
				if o!=null:
					parent_spore = o
					if parent_spore!=null:
						#parent_spore.children_spores.append(self)
						shlong = shlong_scene.instantiate()
						shlong_midpoint = Vector3(randf()-0.5, randf()-0.5, randf()-0.5)*2.0
						shlong_progress = 0.01
						add_child(shlong)
			#$parent_search.monitoring = false
		return
	time -= delta
	if time < 0:
		if state == 0:
			state = 1
			time = randf()*0.1 + 0.1
			shlong_time = time
			return
		if state == 1:
			$spore.scale = Vector3.ONE*radius			
			$spore.visible = true
			$spore/hitbox.monitorable = true
			if game!=null:
				game.register_spore(self)
			time = 0.0
			state = 2
		time = 0.0
	if state == 0:
		pass
	if state == 1:
		if shlong != null and parent_spore != null:
			shlong_progress = (1.0 - time/shlong_time)+0.01
			shlong_progress = clamp(shlong_progress, 0.01, 1.0)
			var p1 = parent_spore.global_position
			var p2 = self.global_position
			p2 = p1 + (p2-p1)*shlong_progress
			var midoff = sqrt(0.25-(shlong_progress-0.5)**2)
			p2 += midoff*shlong_midpoint
			var w = shlong_progress
			if w < 0.1:
				w=0.1
			if w >0.4:
				w=0.4
			shlong.align_mesh(p1,p2, w*2.0)
			shlong.visible = true
	if state == 2:
		if ward_close:
			if radius > 0.25:
				radius -= delta*2.0
		else:
			radius += delta*speed
		$spore.scale = Vector3.ONE*radius
		if radius > 2.0 and shlong != null:
			remove_child(shlong)
			shlong = null
	if state == 3:
		radius -= delta*2.0
		$spore.scale = Vector3.ONE*radius
		if radius < 0.25:
			queue_free()
		


func _on_ward_check_timeout():
	if game:
		if game.check_wards(global_position, radius*0.5) != ward_close:
			ward_close = !ward_close
			if ward_close:
				$spore/ball.material_override = mat_ward
			else:
				$spore/ball.material_override = mat_black
