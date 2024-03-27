extends Node3D

var ext = 0.0
var target_ext = 0.0

const ext_deploy = 0.2
const ext_extended = 1.0

var ext_enabled = false
var ext_speed = 1.0

var col_count = 0

const PC_min = 0.0
const PC_max = 2.5

const H1_min = 0.0
const H1_max = 2.5

const H2_min = 0.0
const H2_max = 2.4

const H3_min = -3.456
const H3_max = -1.4

func update_ext():
	$PistonH3.position.y = lerpf(H3_min, H3_max, ext)
	$PistonH3/PistonH2.position.y = lerpf(H2_min, H2_max, ext)
	$PistonH3/PistonH2/PistonH1.position.y = lerpf(H1_min, H1_max, ext)
	$PistonH3/PistonH2/PistonH1/PistonCenter.position.y = lerpf(PC_min, PC_max, ext)

func _physics_process(delta):
	if ext != target_ext:
		var dv = delta*ext_speed
		var d = (dv if ext < target_ext else -dv)
		ext += d
		if abs(ext - target_ext) < dv:
			ext = target_ext
		update_ext()

func deploy(n_speed):
	ext_speed = n_speed
	target_ext = ext_deploy
	$Animation.speed_scale = ext_speed*6.0
	$Animation.play("deploy")
	
func enable_extension():
	ext_enabled = true
	ext_speed = 1.0
	$PistonH3/PistonH2/PistonH1/PistonCenter/detector.monitoring = true
	$PistonH3/PistonH2/PistonH1/PistonCenter/PistonBody.set_collision_layer_value(1,true)
	$PistonH3/PistonH2/PistonH1/PistonCenter/PistonBody.set_collision_mask_value(1,true)


func _on_detector_area_entered(area):
	target_ext = ext_extended
	col_count += 1
	if area.is_in_group("piston_sensitive"):
		area.register_piston(self)

func _on_detector_area_exited(area):
	col_count -= 1
	if area.is_in_group("piston_sensitive"):
		area.unregister_piston(self)
	if col_count==0:
		target_ext = ext_deploy


func _on_piston_body_ext_lock():
	target_ext = ext_extended
	col_count = 300
