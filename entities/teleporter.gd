extends RigidBody3D

var engaged = false
var deploying = 0
var prog = 0.0

var deploy_speed = 1.0

var player = null
var crot = Vector3(0.0,0.0,0.0)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _exit_tree():
	if player!=null:
		if player.teleporter == null or player.teleporter == self:
			player.hud.tele_destroyed()
		
var player_basis = null

func activate(bs):
	player_basis = bs
	$activate_timer.start()
	
func _on_activate_timer_timeout():
	player.global_transform = global_transform
	if player.perk_tele1:
		player.add_energy_boost(player.teleporter_energy_boost)
	player.translate_object_local(Vector3.UP*1.5)
	player.basis = player_basis
	player.crouch = 1.0
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player!=null and position.y < player.position.y - 100.0:
		queue_free()
	
	if deploying==0 and linear_velocity.length_squared()<0.1:
		sleeping = true
		deploying = 1
		crot = rotation
		$CollisionShape3D.disabled = true
		
		freeze = true
	if deploying == 1:
		prog += delta*2.0*deploy_speed
		rotation = lerp(crot, Vector3(0.0,0.0,0.0), prog)
		if prog>1.0:
			prog=0.0
			deploying = 2
			rotation = Vector3(0.0,0.0,0.0)
	if deploying == 2:
		$teleporter_net.scale *= (1.0+delta*deploy_speed*0.8)
		if $teleporter_net.scale.x > 0.13:
			deploying = 3
			engaged = true
			if player != null:
				player.hud.tele_online()
				player.tele_online()
			$OmniLight3D.show()



func _on_body_entered(_body):
	$thump.pitch_scale = 0.8 + randf()*0.3
	$thump.volume_db = -10.0-randf()*5.0
	$thump.play()
