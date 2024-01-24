extends RigidBody3D

var engaged = false
var deploying = 0
var prog = 0.0
var lifetime = 0.0
var start_lifetime = 0.0
var zscale = 1.0

var spores_delayed = []

var spore_destructible_scene = preload("res://spore_destructible.tscn")

var crot = Vector3(0.0,0.0,0.0)
# Called when the node enters the scene tree for the first time.
func _ready():
	angular_damp = 1.0
	linear_damp = 1.0
	pass # Replace with function body.


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
			$OmniLight3D.show()
	if deploying == 2:
		prog+=delta/1.5
		translate_object_local(Vector3.UP*delta)
		if prog >= 1.0:
			deploying = 3
			engaged = true
			$spore_detector.monitoring = true
			start_lifetime = lifetime
			zscale = $ward/WardProgressBar.scale.y			
	if deploying == 3:
		lifetime-=delta
		$ward/WardProgressBar.scale.y = zscale*(lifetime / start_lifetime)		
		if lifetime < 0:
			deploying = 4
			engaged = false
			$spore_detector.monitoring = false
			for sp in spores_delayed:
				if sp!=null:
					sp.unpause_progress()		
			var sd = spore_destructible_scene.instantiate()
			add_child(sd)
			$ward/WardProgressBar.hide()
			$ward/WardBall.hide()
			$OmniLight3D.hide()


func _on_spore_detector_area_entered(area):
	if !engaged:
		return
	var sp = area.get_parent()
	if sp!=null and !sp.is_in_group("spore"):
		sp = sp.get_parent()
	if sp!=null:
		spores_delayed.append(sp)
		sp.pause_progress()
