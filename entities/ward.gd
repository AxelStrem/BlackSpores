extends RigidBody3D

var engaged = false
var deploying = 0
var prog = 0.0
var lifetime = 0.0
var start_lifetime = 0.0
var zscale = 1.0
var game = null
var lockpick = false
var slowdown = 1.0

var spore_destructible_scene = preload("res://spore_destructible.tscn")

@export var radius = 10.0

var crot = Vector3(0.0,0.0,0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	angular_damp = 1.0
	linear_damp = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if deploying==0 and linear_velocity.length_squared()<0.1:
		sleeping = true
		deploying = 1
		crot = rotation
		$CollisionShape3D.disabled = true
		
		freeze = true
	if deploying == 1:
		prog += delta*2.0
		rotation = lerp(crot, Vector3(0.0,0.0,0.0), prog)
		if prog>1.0:
			prog=0.0
			deploying = 2
			rotation = Vector3(0.0,0.0,0.0)
			$ward/WardStand.show()
			$ward/WardProgressBar.show()
			$ward_light.show()
	if deploying == 2:
		prog+=delta/1.5
		translate_object_local(Vector3.UP*delta)
		if prog >= 1.0:
			deploying = 3
			engaged = true
			if lockpick:
				$ward/lock_opener.monitorable = true
			$ward_light.light_energy = 100.0
			game = Global.get_game_root(self)
			if game!=null:
				game.add_ward(self)
			start_lifetime = lifetime
			zscale = $ward/WardProgressBar.scale.y			
	if deploying == 3:
		if slowdown == 1.0:
			$particles.emitting = true			
		lifetime -= delta * slowdown
		$ward/WardProgressBar.scale.y = zscale*(lifetime / start_lifetime)		
		if lifetime < 0:
			deploying = 4
			engaged = false
			$ward/lock_opener.monitorable = false
			$particles.emitting = false
			if game!=null:
				game.remove_ward(self)
			#for sp in spores_delayed:
			#	if sp!=null:
			#		sp.unpause_progress()		
			var sd = spore_destructible_scene.instantiate()
			add_child(sd)
			$ward/WardProgressBar.hide()
			$ward/WardBall.hide()
			$ward_light.hide()

func _exit_tree():
	if game!=null:
		game.remove_ward(self)


func _on_body_entered(_body):
	$thump.pitch_scale = 0.8 + randf()*0.3
	$thump.volume_db = -10.0-randf()*5.0
	$thump.play()
