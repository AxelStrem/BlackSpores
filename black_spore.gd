extends Node3D

const sv_sideways = 2.0

var shlong_scene = preload("res://shlong.tscn")
const class_consumable = preload("res://spore_consumable.gd")

var velocity = Vector3(-1.0, 3.0, 0.0)
var accel = Vector3(0.0, -5.0, 0.0)
var current_scale = 1.0

var lifetime = 20.0
var wait_init = 0

var spawner = null
var shlong = null

var mistries = 5
var decay = 1.0

@export var state = 0
var type = 0
var max_rad = 3.0
var rate = 1.0
var shlong_progress=0.1
var shlong_midpoint = Vector3(0.0,0.0,0.0)

var b_active = false
var attempts = 0

var progress_paused = 0

func activate_spore():
	if b_active:
		return
	#if randf()<0.12:
	#	$AudioStreamPlayer3D.seek(randf()*20.0)
	#	$AudioStreamPlayer3D.play()
	
	b_active = true	
	var p = get_parent()
	while p!=null:
		var np = p.get_parent()
		if p is class_consumable or p.is_in_group("game"):
			p.activate_spore(self)
		p = np

func deactivate_spore(_cs):
	if !b_active:
		return
	b_active = false
	var p = get_parent()
	while p!=null:
		var np = p.get_parent()
		if p is class_consumable or p.is_in_group("game"):
			p.deactivate_spore(self)
		p = np


func update_scale():
	$spore.scale = Vector3(1.0,1.0,1.0)*current_scale*Global.spore_scale

func try_init():
	#$hitbox_init_test.collision_mask = mask_allow_spawn
	var overlap = $hitbox_init_test_allowed.get_overlapping_areas()
	if overlap.size()==0:
		queue_free()
		return 1
	if $hitbox_init_test_rejected.has_overlapping_areas():
		queue_free()
		return 1
	if $hitbox_init_overlapped.has_overlapping_areas():
		queue_free()
		return 2
	
	var gt = self.global_transform
	get_parent().remove_child(self)
	overlap[0].add_child(self)
	self.global_transform = gt
	call_deferred("activate_spore")
	
	$hitbox_init_test_allowed.monitoring = false
	$hitbox_init_test_rejected.monitoring = false
	$hitbox_init_overlapped.monitoring = false
	$hitbox.monitorable = true
	$spore/hitbox.monitorable = true
	$spore/ball.show()
	current_scale = 0.01
	update_scale()
	max_rad = 1.5 + randf()*1.5
	rate = 0.1+randf()
	type = randi_range(0,2)
	if type==0:
		max_rad+=5.0
	state = 5
	shlong = shlong_scene.instantiate()
	shlong_midpoint = Vector3(randf()-0.5, randf()-0.5, randf()-0.5)*2.0
	add_child(shlong)	
	return 0
	
# Called when the node enters the scene tree for the first time.
func _ready():
	#$hitbox/CollisionShape3D.shape.radius = 0.6*Global.spore_scale
	#$hitbox_init_test_allowed/CollisionShape3D.shape.radius = 0.25*Global.spore_scale
	#$hitbox_init_test_rejected/CollisionShape3D.shape.radius = 0.25*Global.spore_scale
	#$hitbox_init_overlapped/CollisionShape3D.shape.radius = 0.5*Global.spore_scale
	pass # Replace with function body.

func _enter_tree():
	get_game_root().add_spore()

func get_game_root():
	var p = get_parent()
	while p!=null and !p.is_in_group("game"):
		p = p.get_parent()
	return p

func _exit_tree():
	get_game_root().remove_spore()
	deactivate_spore(1)

func pause_progress():
	progress_paused += 1
	var gg = get_game_root()
	if gg!=null:
		gg.deactivate_spore(self)
	
func unpause_progress():
	progress_paused -= 1
	if progress_paused <= 0:
		progress_paused = 0
		var gg = get_game_root()
		if gg!=null:
			gg.activate_spore(self)


func _process(delta):
		if progress_paused:
			return
		#var cm_rad = max_rad*attempts/100
	
		if state==7:
			if !b_active:
				activate_spore()
		if state == 1:
			current_scale += delta*rate
			#if current_scale > cm_rad:
			#	current_scale = cm_rad
			update_scale()
			#$spore/ball.hide()
			#$spore/ball2.hide()
			#$spore/ball3.hide()
			#$spore/ball4.show()
			if current_scale >= max_rad:
				state = 2
		if state==2 and type!=0:
			#$spore/ball.hide()
			#$spore/ball2.hide()
			#$spore/ball4.hide()
			#$spore/ball3.show()
			current_scale -= delta*0.2
			update_scale()
			if current_scale <= 0.1:
				deactivate_spore(21)
				queue_free()
				return
		if state==2 and type==0:
			#$spore/ball.hide()
			#$spore/ball3.hide()
			#$spore/ball4.hide()
			#$spore/ball2.show()
			current_scale += delta*rate*2.3
			update_scale()
			if current_scale > 10.0:
				deactivate_spore(20)
				state = 9
				
		#if state != 2 and state != 5:
		#	next_eruption -= delta
		#	if next_eruption <= 0.0:
		#		get_game_root().add_active_spore(self)
		#		next_eruption = randf()*0.05
				
		if state == 5:
			shlong_progress+=delta*2.0
			if shlong_progress >= 1.0:
				state = 1
			elif spawner!=null:
				var p1 = spawner.global_position
				var p2 = self.global_position
				p2 = p1 + (p2-p1)*shlong_progress
				var midoff = sqrt(0.25-(shlong_progress-0.5)**2)
				p2 += midoff*shlong_midpoint
				var w = shlong_progress
				if w < 0.1:
					w=0.1
				if w >0.4:
					w=0.4
				shlong.align_mesh(p1,p2, w*Global.spore_scale)
				shlong.visible = true
		#if !b_active:
		#	$spore/ball.show()
		#	$spore/ball2.hide()
		#	$spore/ball3.hide()
		#	$spore/ball4.hide()
		
func spawn_result(ti):
	if ti==2:
		decay-=0.2
	if ti==1:
		decay-=0.01
	if ti==0:
		decay=1.0
	if decay<=0:
		deactivate_spore(0)
			
func _physics_process(_delta):
	if progress_paused:
		return
	if wait_init>1:
		wait_init-=1
		return
	if wait_init==1:
		wait_init = 0
		var ti = try_init()
		if spawner != null:
			spawner.spawn_result(ti)
