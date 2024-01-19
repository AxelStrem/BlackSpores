extends Node3D

const sv_sideways = 2.0

var shlong_scene = preload("res://shlong.tscn")
const class_consumable = preload("res://spore_consumable.gd")

var next_eruption = 1.0

var velocity = Vector3(-1.0, 3.0, 0.0)
var accel = Vector3(0.0, -5.0, 0.0)
var current_scale = 1.0

var lifetime = 10.0
var wait_init = 0

var spawner = null
var shlong = null

var mistries = 5

var state = 0
var type = 0
var max_rad = 3.0
var rate = 1.0
var shlong_progress=0.1
var shlong_midpoint = Vector3(0.0,0.0,0.0)

func activate_spore():
	var p = get_parent()
	while p!=null:
		var np = p.get_parent()
		if p is class_consumable:
			p.activate_spore()
		p = np

func update_scale():
	$spore.scale = Vector3(1.0,1.0,1.0)*current_scale*Global.spore_scale

func try_init():
	#$hitbox_init_test.collision_mask = mask_allow_spawn
	if !$hitbox_init_test_allowed.has_overlapping_areas():
		queue_free()
		return 1
	if $hitbox_init_test_rejected.has_overlapping_areas():
		queue_free()
		return 1
	if $hitbox_init_overlapped.has_overlapping_areas():
		queue_free()
		return 2
	
	$hitbox_init_test_allowed.monitoring = false
	$hitbox_init_test_rejected.monitoring = false
	$hitbox_init_overlapped.monitoring = false
	$hitbox.monitorable = true
	$spore/hitbox.monitorable = true
	$spore/ball.show()
	current_scale = 0.01
	update_scale()
	max_rad = 1.5 + randf()*1.5
	rate = 0.5+randf()
	type = randi_range(0,4)
	if type==0:
		max_rad+=5.0
	state = 5
	shlong = shlong_scene.instantiate()
	shlong_midpoint = Vector3(randf()-0.5, randf()-0.5, randf()-0.5)*2.0
	add_child(shlong)
	#shlong.visible=false
	
	return 0
	
# Called when the node enters the scene tree for the first time.
func _ready():
	#$hitbox/CollisionShape3D.shape.radius = 0.6*Global.spore_scale
	#$hitbox_init_test_allowed/CollisionShape3D.shape.radius = 0.25*Global.spore_scale
	#$hitbox_init_test_rejected/CollisionShape3D.shape.radius = 0.25*Global.spore_scale
	#$hitbox_init_overlapped/CollisionShape3D.shape.radius = 0.5*Global.spore_scale
	pass # Replace with function body.

func deactivate():
	mistries-=1
	if mistries<=0:
		next_eruption = 1000.0

func _process(delta):
		if state == 1:
			current_scale += delta*rate
			update_scale()
			if current_scale >= max_rad:
				state = 2
		if state==2 and type!=0:
			current_scale -= delta*0.2
			
			if current_scale <= 0.1:
				queue_free()
				return
		if state==2 and type==0:
			current_scale += delta*rate*0.3
			update_scale()
		if state != 2 and state != 5:
			next_eruption -= delta
			if next_eruption <= 0.0:
				get_parent().add_active_spore(self)
				next_eruption = randf()*0.1
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
				
			
func _physics_process(_delta):
	if wait_init>1:
		wait_init-=1
		return
	if wait_init==1:
		wait_init = 0
		var ti = try_init()
		if spawner != null:
			if ti == 0:
				spawner.next_eruption = 0.0 + randf()*0.1
			else:
				spawner.next_eruption = 0.0 + randf()*0.0005
			if ti==2:
				spawner.deactivate()
