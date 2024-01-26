extends Node3D

@export var speed = 1.5
@export var slide_speed = 1.0
@export var gap = 3.0

var state = 0
var state_l = 0
var state_u = 0
var slide_l = 2.5
var slide_u = 2.5

func unlock():
	state = 1

func unlock_u():
	state_u = 1
	
func unlock_l():
	state_l = 1

func _process(delta):
	if state_l == 1:
		$SiloSlider.translate_object_local(Vector3.LEFT*delta*slide_speed)
		$SiloRoller.rotate_z(delta*slide_speed)
		slide_l -= delta*slide_speed
		if slide_l < 0.0:
			state_l = 2
			if state_u == 2:
				state = 1
	if state_u == 1:
		$SiloSliderU.translate_object_local(Vector3.LEFT*delta*slide_speed)
		$SiloRollerU.rotate_z(delta*slide_speed)
		slide_u -= delta*slide_speed
		if slide_u < 0.0:
			state_u = 2
			if state_l == 2:
				state = 1
	
	if state == 1:
		$SiloDoorU.translate_object_local(Vector3.BACK*delta*speed)
		$SiloDoorD.translate_object_local(Vector3.FORWARD*delta*speed)
		gap-=delta*speed
		if gap<=0.0:
			state = 2
