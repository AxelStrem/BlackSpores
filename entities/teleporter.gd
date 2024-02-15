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
		player.teleporter = null
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
			$OmniLight3D.show()
