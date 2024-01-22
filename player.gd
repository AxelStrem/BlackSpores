extends CharacterBody3D

signal got_research_point_signal
signal to_menu_signal
var step_distance=0
var max_energy=200
var current_energy=200.0
var dead = false;
var old_velocity = Vector3(0.0,0.0,0.0)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const vec_up = Vector3(0.0,1.0,0.0)
const jump_impulse = 10.0
const air_control = 0.15
const crouch_speed = 10.0
const speed_decay = 0.85

var ground_close = false
var last_frame_on_ground = false
var jumping = false
var timer_paused = false

var dead_player_scene = preload("res://dead_player.tscn")
var crouch = 0.0

var checkpoint = Vector3(0.0,0.0,0.0)
var checkpoint_time = 0.0

var speed = 50.0
#var velocity = Vector3(0.0,0.0,0.0)
var camera_sensitivity = 0.5

var antigrav_charges = 0
var antigrav_protection = false
const antigrav_charges_max = 10
const antigrav_charges_bonus = 3

var teleporter_charges = 0
const teleporter_charges_max = 5
const teleporter_charges_bonus = 1

var ward_charges = 0
const ward_charges_max = 3
const ward_charges_bonus = 1

var research_points = 0

var time_passed = 0.0
var camera = null
var label_time = null
var label_points = null
var label_consumables = null
var label_debug = null
var label_fps = null
var label_energy = null
var label_dead = null

func get_game_root():
	var p = get_parent()
	while p!=null and !p.is_in_group("game"):
		p = p.get_parent()
	return p
	
# Called when the node enters the scene tree for the first time.
func _ready():
	camera = $Camera
	label_time = $Camera/LabelTime
	label_fps = $Camera/LabelFPS
	label_debug = $Camera/LabelDebug
	label_points = $Camera/LabelPoints
	label_consumables = $Camera/LabelConsumables
	label_energy = $Camera/LabelEnergy
	label_dead = $Camera/LabelDead
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$breath.set_volume_db(-1000)
	label_points.text = "points/{0}".format({0:int(research_points)})
	label_energy.text = "{0} Antigrav / {1} Tele / {2} Ward".format({0:int(antigrav_charges), 1:teleporter_charges, 2:ward_charges})
	#checkpoint = translation
	
func victory():
	timer_paused = true

func format_time(time):
	var ms = int((time - floor(time))*100.0)
	var s = int(floor(time))
	var m = int(s / 60.0)
	s = s % 60
	
	return "%02d:%02d.%02d" % [m, s, ms]

func pickup(pickup_type):
	$pickup_sound.play()
	$pickup_sound.seek(0.3)	
	if pickup_type == 0:
		research_points += 1
		got_research_point_signal.emit()
		label_points.text = "points/{0}".format({0:int(research_points)})
		return true
	if pickup_type == 1:
		SPEED*=2
		return true
	if pickup_type == 2:
		if antigrav_charges >= antigrav_charges_max:
			return false
		antigrav_charges = min(antigrav_charges_max, antigrav_charges + antigrav_charges_bonus)
		return true
	if pickup_type == 3:
		if teleporter_charges >= teleporter_charges_max:
			return false
		teleporter_charges = min(teleporter_charges_max, teleporter_charges + teleporter_charges_bonus)
		return true
	if pickup_type == 4:
		if ward_charges >= ward_charges_max:
			return false
		ward_charges = min(ward_charges_max, ward_charges + ward_charges_bonus)
		return true
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("exit_to_menu"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		to_menu_signal.emit()
	var direction = -get_transform().basis.z
#	var ortho_dir = get_transform().basis.x
	
	if not timer_paused:
		time_passed += delta
	label_time.text = format_time(time_passed)
	label_energy.text = "{0}/{1}".format({0:int(current_energy), 1:max_energy})
	velocity += Vector3(0.0,-20.0,0.0)*delta
	
	#if is_on_floor():	
	#	ground_close = true
	#	last_frame_on_ground = true
	#else:
	#	if last_frame_on_ground:
	#		last_frame_on_ground = false
			#$AirtimeDelay.start()		
	
	#var air_coef = air_control
	#if is_on_floor():
	#	air_coef = 1.0	
	
	#var velocity_increment = Vector3(0.0,0.0,0.0)
	#var velocity_changing = false
	
	if Input.is_action_pressed("player_crouch"):
		crouch+=crouch_speed*delta
	else:
		crouch-=crouch_speed*delta
		
	#if velocity_changing:
	#	velocity_increment = velocity_increment.normalized()
	#	velocity += velocity_increment*delta*speed*air_coef
		
	crouch = clamp(crouch, 0.0, 1.0)
		
	scale.y = 1.0 - crouch*0.5
	
	#if is_on_floor():	
	#	velocity*=pow(speed_decay,60.0*delta)
	
	#if is_on_floor() and not jumping:
	#	velocity = move_and_slide_with_snap(velocity, -vec_up, vec_up)
	#else:
	#	velocity = move_and_slide(velocity, vec_up)	
	#
	#if translation.y < -10.0:
	#	kill_player()

var SPEED = 5.0
const JUMP_VELOCITY = 7.5
const JUMP_VELOCITY_ANTIGRAV = 20.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	label_consumables.text = "{0} Antigrav / {1} Tele / {2} Ward".format({0:int(antigrav_charges), 1:teleporter_charges, 2:ward_charges})
	var game = get_game_root()
	if game:
		label_debug.text = "Spores {0}/{1}".format({0:game.active_spore_count(), 1:game.total_spore_count()})
	
	$breath.set_volume_db((tanh(current_energy-100)+1)*(-1000))
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_strafe_left", "player_strafe_right", "player_forward", "player_reverse")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		step_distance = 0
	else: 		
		if direction:	
			step_distance += delta
			if step_distance>0.5:
				$Feet.position.x = -$Feet.position.x
				$Feet.get_children().pick_random().play()
				step_distance=0
		if old_velocity.y < -32.0:
			if antigrav_charges > 0 and not antigrav_protection:
				antigrav_charges-=1
				antigrav_protection=true
			if not antigrav_protection:
				label_dead.text = "v = {0}".format({0:snapped(old_velocity.y,0.01)})	
				_player_dead(old_velocity)
		antigrav_protection = false
	
	old_velocity = velocity

	# Handle Jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if antigrav_charges > 0:
			velocity.y = JUMP_VELOCITY_ANTIGRAV
			antigrav_charges -= 1
			antigrav_protection = true
			


	if direction:
		if Input.is_action_pressed("player_run") && current_energy > 0:
			direction*=1.5
			current_energy-=delta*60
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if !Input.is_action_pressed("player_run") or !direction:
		current_energy = min(max_energy,current_energy + delta * 30)
	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg_to_rad(event.relative.x * -camera_sensitivity))
		camera.rotate_x(deg_to_rad(event.relative.y * -camera_sensitivity))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -70, 70)
	#if event.is_action_pressed("player_jump") and ground_close and not jumping:
	#	velocity += vec_up*jump_impulse
	#	ground_close = false
	#	jumping = true
	#	$JumpDelay.start()
	#if event.is_action_pressed("player_save") and ground_close:
		#checkpoint = translation
		#checkpoint_time = time_passed
	#if event.is_action_pressed("player_reset"):
	#	kill_player()


func _on_AirtimeDelay_timeout():
	ground_close = false

func _on_jump_delay_timeout():
	jumping = false


func _on_area_3d_area_entered(_area):
	_player_dead(velocity)

func _player_dead(death_velocity):
	dead = true	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var restart_button = $Camera/restartButton
	restart_button.visible=true
	var menu_button = $Camera/quitToMenuButton
	menu_button.visible=true
	
	var dead_body = dead_player_scene.instantiate()
	get_parent().add_child(dead_body)
	dead_body.global_transform = self.global_transform
	dead_body.linear_velocity = death_velocity	
	remove_child(camera)
	dead_body.add_child(camera)	
	queue_free()


func _on_breath_finished():
	$breath.play()
