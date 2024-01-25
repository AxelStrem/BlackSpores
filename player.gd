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
const full_height = 2.87
const full_rad = 0.8
const crouch_height = 1.5
const crouch_rad = 0.5
const crouch_slowdown = 0.4
const speed_decay = 0.85
const energy_boost_duration = 15.0

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

var lockpick_skill = 1.0

var antigrav_charges = 0
var antigrav_protection = false
var antigrav_jump_available = 0.0
const antigrav_charges_max = 10
const antigrav_charges_bonus = 3

var teleporter_charges = 0
const teleporter_charges_max = 10
const teleporter_charges_bonus = 2
var teleporter = null
var teleporter_scene = preload("res://entities/teleporter.tscn")
var teleporter_energy_boost = 3.0

var ward_charges = 0
const ward_charges_max = 10
const ward_charges_bonus = 1
var ward_scene = preload("res://entities/ward.tscn")

var research_points = 0

var time_passed = 0.0
var camera = null
var item_spawn = null
var label_time = null
var label_points = null
var label_consumables = null
var label_debug = null
var label_fps = null
var label_energy = null
var label_dead = null
var hud = null
var hud_sprite = null

var info_message = null
var info_timeout = 0.0

var energy_boost = 0.0

var controls_locked = false

func lock_controls():
	$Camera/HUDSprite.hide()
	controls_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func unlock_controls():
	controls_locked = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera/HUDSprite.show()	

func get_game_root():
	var p = get_parent()
	while p!=null and !p.is_in_group("game"):
		p = p.get_parent()
	return p
	
# Called when the node enters the scene tree for the first time.
func _ready():
	camera = $Camera
	item_spawn = $Camera/item_spawn
	label_time = $Camera/LabelTime
	label_fps = $Camera/LabelFPS
	label_debug = $Camera/LabelDebug
	label_points = $Camera/LabelPoints
	label_consumables = $Camera/LabelConsumables
	label_energy = $Camera/LabelEnergy
	label_dead = $Camera/LabelDead
	hud = $HUDViewport/Camera3D/HUD
	hud_sprite = $Camera/HUDSprite
	
	$Camera/restartButton.deactivate()
	$Camera/quitToMenuButton.deactivate()
	
	info_message = $Camera/InfoMessage
	info_message.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$breath.set_volume_db(-1000)
	label_points.text = "points/{0}".format({0:int(research_points)})
	label_energy.text = "{0} Antigrav / {1} Tele / {2} Ward".format({0:int(antigrav_charges), 1:teleporter_charges, 2:ward_charges})
	get_tree().paused = false
	#checkpoint = translation

func display_info(text):
	info_message.text = text
	info_message.visible = true
	info_timeout = 6.0

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
		display_info("Picked up a research datapoint")
		return true
	if pickup_type == 1:
		energy_boost = energy_boost_duration
		display_info("Picked up an energy boost")
		hud._set_infinit_energy(true)
		return true
	if pickup_type == 2:
		if antigrav_charges >= antigrav_charges_max:
			display_info("Antigrav charges full")
			return false
		antigrav_charges = min(antigrav_charges_max, antigrav_charges + antigrav_charges_bonus)
		display_info("Picked up Anti-Gravity Boots. Press jump twice to engage")
		return true
	if pickup_type == 3:
		if teleporter_charges >= teleporter_charges_max:
			display_info("Teleporter charges full")
			return false
		teleporter_charges = min(teleporter_charges_max, teleporter_charges + teleporter_charges_bonus)
		display_info("Picked up a Teleporter. Left click to deploy, right click to teleport")
		return true
	if pickup_type == 4:
		if ward_charges >= ward_charges_max:
			display_info("Ward charges full")
			return false
		ward_charges = min(ward_charges_max, ward_charges + ward_charges_bonus)
		display_info("Picked up a Ward. Press Q to deploy")
		return true
	return true

var SPEED = 5.0
const jump_velocity = 8.0
const jump_velocity_antigrav = 20.0
const jump_energy = 50.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	if controls_locked:
		return
	
	if not timer_paused:
		time_passed += delta
	label_time.text = format_time(time_passed)
	label_energy.text = "{0}/{1}".format({0:int(current_energy), 1:max_energy})
	velocity += Vector3(0.0,-20.0,0.0)*delta
		
	label_consumables.text = "{0} Antigrav / {1} Tele / {2} Ward".format({0:int(antigrav_charges), 1:teleporter_charges, 2:ward_charges})
	var game = get_game_root()
	if game:
		label_debug.text = "Spores {0}/{1}".format({0:game.active_spore_count(), 1:game.total_spore_count()})
		
	if info_timeout > 0.0:
		info_timeout -= delta
		if info_timeout <= 0.0:
			info_message.visible = false
	
	$breath.set_volume_db((tanh(current_energy-100)+1)*(-1000))
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_strafe_left", "player_strafe_right", "player_forward", "player_reverse")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	hud._set_energy_percent(current_energy/max_energy)
	hud._set_grav_bonus(antigrav_charges)
	hud._set_teleport_bonus(teleporter_charges)
	hud._set_vard_bonus(ward_charges)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		step_distance = 0
	else: 		
		if direction:	
			step_distance += delta
			if step_distance>0.5:
				$Camera/Feet.position.x = -$Camera/Feet.position.x
				$Camera/Feet.get_children().pick_random().play()
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
	antigrav_jump_available -= delta
	if antigrav_jump_available < 0.0:
		antigrav_jump_available = 0.0
	if Input.is_action_just_pressed("player_jump"):
		if is_on_floor():
			var je = current_energy
			if je > jump_energy:
				je = jump_energy
			current_energy -= je
			je/=jump_energy			
			velocity.y = jump_velocity*je
			antigrav_jump_available = 0.6
		elif antigrav_jump_available > 0.0:
			if antigrav_charges > 0:
				velocity.y += jump_velocity_antigrav
				antigrav_charges -= 1
				antigrav_protection = true
				antigrav_jump_available = 0.0
	
	#Handle crouch
	if Input.is_action_pressed("player_crouch"):
		crouch+=crouch_speed*delta
	else:
		crouch-=crouch_speed*delta
		
	crouch = clamp(crouch, 0.0, 1.0)
		
	#scale.y = 1.0 - crouch*0.5
	var rad = lerp(full_rad, crouch_rad, crouch)
	var h = lerp(full_height, crouch_height, crouch)
	$hitbox.shape.radius = rad
	$hitbox.shape.height = h
	var speed_coef = lerp(1.0, crouch_slowdown, crouch)
			


	if direction:
		if Input.is_action_pressed("player_run") && current_energy > 0:
			direction*=1.5
			current_energy-=delta*60
		velocity.x = direction.x * SPEED * speed_coef
		velocity.z = direction.z * SPEED * speed_coef
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if !Input.is_action_pressed("player_run") or !direction:
		current_energy = min(max_energy,current_energy + delta * 30)
		
	if energy_boost > 0.0:
		energy_boost-=delta
		if energy_boost < 0.0:
			hud._set_infinit_energy(false)
		current_energy = max_energy
	
	move_and_slide()

func _input(event):
	if controls_locked:
		return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q:
			if ward_charges > 0:
					ward_charges -= 1
					var ward = ward_scene.instantiate()
					ward.lifetime = 10.0
					get_parent().add_child(ward)
					ward.global_transform = item_spawn.global_transform
					ward.linear_velocity = -ward.global_transform.basis.z.normalized()*10.0
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg_to_rad(event.relative.x * -camera_sensitivity))
		camera.rotate_x(deg_to_rad(event.relative.y * -camera_sensitivity))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -70, 70)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if teleporter_charges > 0:
					teleporter_charges -= 1
					if teleporter!=null:
						teleporter.queue_free()
					teleporter = teleporter_scene.instantiate()
					teleporter.player = self
					get_parent().add_child(teleporter)
					teleporter.global_transform = item_spawn.global_transform
					teleporter.linear_velocity = -teleporter.global_transform.basis.z.normalized()*10.0
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if teleporter!=null:
					if teleporter.engaged:
						var bs = basis
						global_transform = teleporter.global_transform
						energy_boost = teleporter_energy_boost
						translate_object_local(Vector3.UP*1.5)
						basis = bs
						teleporter.queue_free()
						teleporter = null
					
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
	var game = get_game_root()
	if game and game.do_spores_kill():
		_player_dead(velocity)

func _player_dead(death_velocity):
	dead = true
	_show_menu()
	
	var dead_body = dead_player_scene.instantiate()
	get_parent().add_child(dead_body)
	dead_body.global_transform = self.global_transform
	dead_body.linear_velocity = death_velocity	
	remove_child(camera)
	dead_body.add_child(camera)	
	queue_free()


func _on_breath_finished():
	$breath.play()
	
func _show_menu():	
	hud_sprite.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var restart_button = $Camera/restartButton
	restart_button.visible=true
	restart_button.activate()
	var menu_button = $Camera/quitToMenuButton
	menu_button.visible=true
	menu_button.activate()
	
func _hide_menu():
	hud_sprite.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var restart_button = $Camera/restartButton
	restart_button.visible=false
	restart_button.deactivate()
	var menu_button = $Camera/quitToMenuButton
	menu_button.visible=false
	menu_button.deactivate()	
