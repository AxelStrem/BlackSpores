extends Node3D

const sv_sideways = 2.0

var next_eruption = 1.0

var current_state = 0

var velocity = Vector3(-1.0, 3.0, 0.0)
var accel = Vector3(0.0, -5.0, 0.0)
var current_scale = 1.0

var lifetime = 10.0

var spawner = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$hitbox_disable/CollisionShape3D.shape = $hitbox_disable/CollisionShape3D.shape.duplicate()
	$hitbox/CollisionShape3D.shape = $hitbox/CollisionShape3D.shape.duplicate()
	$hitbox_attach/CollisionShape3D.shape = $hitbox_attach/CollisionShape3D.shape.duplicate()
	pass # Replace with function body.

func set_state(ns):
	current_state = ns
	
func set_radius(rad):
	$ball.scale = Vector3(1.0,1.0,1.0)*rad
	$hitbox_disable/CollisionShape3D.shape.radius = rad*0.3
	$hitbox/CollisionShape3D.shape.radius = rad*0.5
	$hitbox_attach/CollisionShape3D.shape.radius = rad*0.5

func erupt():
	var spore = self.duplicate()
	spore.global_transform = self.global_transform
	spore.current_scale = 0.2
	spore.scale = Vector3(1.0,1.0,1.0)
	spore.set_radius(spore.current_scale)
	get_parent().add_child(spore)
	spore.velocity = Vector3((randf()*2.0-1.0)*sv_sideways,  (randf()*2.0-1.0)*sv_sideways, (randf()*2.0-1.0)*sv_sideways)
	spore.position += velocity.normalized()*current_scale*0.6
	spore.set_state(1)
	spore.spawner = self
	spore.find_child("hitbox").monitorable = false
	spore.find_child("hitbox_attach").monitoring = true
	spore.find_child("hitbox_disable").monitoring = true
	spore.lifetime = 10.0

func _process(delta):
	if current_state==0:
		current_scale += delta*0.2
		set_radius(current_scale)
		#scale = Vector3(1.0,1.0,1.0)*current_scale
		next_eruption -= delta
		if next_eruption <= 0.0:
			erupt()
			next_eruption = 0.01 + randf()*0.5
		var ars = $hitbox_disable.get_overlapping_areas()
		for a in ars:
			var bs = a.get_parent()
			var dist = (self.global_position - bs.global_position).length()
			if dist < 0.5*abs(bs.current_scale - current_scale):
				if bs.current_scale > current_scale:
					get_parent().remove_shit()
					queue_free()
					break
	if current_state==1:
		self.position += velocity*delta
		#velocity += accel*delta
		lifetime -= delta
		if lifetime < 0.0:
			queue_free()
	if current_state==2:
		current_scale += delta
		#scale = Vector3(1.0,1.0,1.0)*current_scale
		set_radius(current_scale)
		if(current_scale >= 1.0):
			current_state = 0


func _on_hitbox_attach_area_entered(_area):

	#$hitbox_disable.monitoring = true
	if current_state == 1:
		if lifetime > 9.5:
			queue_free()
			return
		else:
			print(_area.get_parent())
		$hitbox_attach.set_deferred("monitoring", false)		
		var ars = $hitbox_disable.get_overlapping_areas()
		#$hitbox_disable.set_deferred("monitoring", false)
		#print(ars.size())
		if (ars.size()>0):
			queue_free()
		else:
			current_state = 2
			$hitbox.set_deferred("monitorable", true)
			get_parent().add_black_shit()
		$hitbox_attach.disable_mode = true
