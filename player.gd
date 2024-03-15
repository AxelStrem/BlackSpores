extends CharacterBody3D

signal got_research_point_signal
signal to_menu_signal
var step_distance=0
var max_energy=200.0
var current_energy=200.0
var energy_regain_speed = 30.0
var dead = false;
var old_velocity = Vector3(0.0,0.0,0.0)

var mouse_sens = 1.0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const vec_up = Vector3(0.0,1.0,0.0)
const jump_impulse = 10.0
const air_control = 8.0
const aircontrol_limit = 1.0
const aircontrol_damp = 1.0
const crouch_speed = 10.0

const full_height = 2.7
const full_rad = 0.8
const crouch_height = 1.5
const crouch_rad = 0.7

const crouch_slowdown = 0.4
const speed_decay = 0.85
const energy_boost_duration = 15.0

var level_speed = 0
var level_stamina = 0
var level_hacking = 0
var level_teleport = 0
var level_ward = 0
var level_strength = 0

var chamber_bottom = -999999.0

var perk_boots1 = false
var perk_cumulative = false
var perk_hacking1 = false
var perk_tele1 = false
var perk_ward1 = false
var perk_tele2 = false
var perk_inventory = false
var perk_ward2 = false
var perk_throw = false
var perk_fall1 = false
var perk_bonus = false
var perk_ward3 = false

var ground_close = false
var last_frame_on_ground = false
var jumping = false
var timer_paused = false
var last_strafe = Vector2i(0,0)
var dodge_timeout = 0.0
var dodge_cooldown = 0.0

var current_chamber = 0
var infinite_energy_cheat = false

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
var antigrav_charges_base = 10
var antigrav_charges_max = 10
const antigrav_charges_bonus = 3

var teleporter_charges = 0
var teleporter_charges_max = 7
const teleporter_charges_base = 7
const teleporter_charges_bonus = 2
var teleporter = null
var teleporter_scene = preload("res://entities/teleporter.tscn")
var teleporter_energy_boost = 3.0
var teleporter_locstack = []

var ward_charges = 0
const ward_charges_base = 5
var ward_charges_max = 5
const ward_charges_bonus = 1
var ward_scene = preload("res://entities/ward.tscn")
var exward_scene = preload("res://entities/super_ward.tscn")

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

var SPEED = 4.0
var acceleration = 60.0
const jump_velocity = 8.0
const jump_velocity_antigrav = 20.0
const jump_energy = 50.0
const dodge_energy = 50.0
const dodge_velocity_vertical = 5.0
const dodge_velocity_horizontal = 10.0
const fatal_velocity = 25.0
var dodge_buffer = Vector3(0.0,0.0,0.0)
var jump_energy_built = 0.0
var jump_energy_limit = 0.0
var throw_speed = 5.0

const jump_type = 3 # 0 - usual jump
					# 1 - jump on release
					# 2 - jump on release after build up
					# 3 - usual jump with build up after
					
var spores_on_player = 0.0
var spore_resistance = 2.0
var touching_spores = 0

var spores_close = 0.0
var spores_intensity = 0.0

@onready var death_screen = $Camera/DeathScreen
@onready var restart_button = $Camera/DeathScreen/restartButton
@onready var menu_button = $Camera/DeathScreen/quitToMenuButton

func add_energy_boost(b):
	var eb = energy_boost * energy_boost
	var ab = b * b
	energy_boost = sqrt(eb + ab)
	hud.set_infinite_energy(true)
	

func update_profile(skills, perks):
	level_speed = skills[0]
	level_stamina = skills[1]
	level_hacking = skills[2]
	level_teleport = skills[3]
	level_ward = skills[4]
	level_strength = skills[5]
	
	perk_boots1 = (perks[0]==2)
	perk_cumulative = (perks[1]==2)
	perk_hacking1 = (perks[2]==2)
	perk_tele1 = (perks[3]==2)
	perk_ward1 = (perks[4]==2)
	perk_tele2 = (perks[5]==2)
	perk_inventory = (perks[6]==2)
	perk_ward2 = (perks[7]==2)
	perk_throw = (perks[8]==2)
	perk_fall1 = (perks[9]==2)
	perk_ward3 = (perks[10]==2)
	perk_bonus = (perks[11]==2)
	
	if perk_inventory:
		antigrav_charges_max = antigrav_charges_base*2
		ward_charges_max = ward_charges_base*2
		teleporter_charges_max = teleporter_charges_base*2
	else:
		antigrav_charges_max = antigrav_charges_base
		ward_charges_max = ward_charges_base
		teleporter_charges_max = teleporter_charges_base
	
	if hud:
		hud.set_style(2 if perk_inventory else 1)
	
	SPEED = 5.0 + level_speed*0.15
	acceleration = 60.0 + level_speed*1.8
	
	max_energy = 200 + 5*level_stamina
	
	lockpick_skill = 1.0+0.1*level_hacking
	
	if perk_throw:
		throw_speed = 10.0
	

func tele_online():
	$sounds/tele_ready.play()

func get_lockpick_skill():
	if perk_hacking1 and energy_boost > 0.0:
		return lockpick_skill*2.0
	return lockpick_skill

func lock_controls():
	$Camera/HUDSprite.hide()
	controls_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func unlock_controls():
	controls_locked = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera/HUDSprite.show()	
	$Camera/Soundtrack.set_state("run")

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
	
	restart_button.deactivate()
	menu_button.deactivate()
		
	info_message = $Camera/InfoMessage
	info_message.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$sounds/breath.set_volume_db(-1000)
	label_points.text = "points/{0}".format({0:int(research_points)})
	label_energy.text = "{0} Antigrav / {1} Tele / {2} Ward".format({0:int(antigrav_charges), 1:teleporter_charges, 2:ward_charges})
	get_tree().paused = false
	#checkpoint = translation
	if Global.first_run:
		$AnimationPlayer.play("title_fade")	

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
	$sounds/pickup_sound.play()
	$sounds/pickup_sound.seek(0.3)
	var extra = 1
	if perk_bonus:
		if randf()<0.1:
			extra = 2
			$sounds/pickup_sound2.play()
			
	if pickup_type == 0:
		research_points += 1 * extra
		got_research_point_signal.emit()
		label_points.text = "points/{0}".format({0:int(research_points)})
		display_info("Picked up a research datapoint")
		return true
	if pickup_type == 1:
		add_energy_boost(energy_boost_duration)
		if extra == 2:
			add_energy_boost(energy_boost_duration)
		if perk_cumulative:
			energy_regain_speed += 2.0 * extra
			display_info("Picked up an energy boost. Energy recovery rate at {0}%".format({0:int(energy_regain_speed/0.3)}))
		else:
			display_info("Picked up an energy boost")
		return true
	if pickup_type == 2:
		if antigrav_charges >= antigrav_charges_max:
			display_info("Antigrav charges full")
			return false
		antigrav_charges = min(antigrav_charges_max, antigrav_charges + antigrav_charges_bonus*extra)
		display_info("Picked up Anti-Gravity Boots. Press jump twice to engage")
		return true
	if pickup_type == 3:
		if teleporter_charges >= teleporter_charges_max:
			display_info("Teleporter charges full")
			return false
		teleporter_charges = min(teleporter_charges_max, teleporter_charges + teleporter_charges_bonus*extra)
		display_info("Picked up a Teleporter. Left click to deploy, right click to teleport")
		return true
	if pickup_type == 4:
		if ward_charges >= ward_charges_max:
			display_info("Ward charges full")
			return false
		ward_charges = min(ward_charges_max, ward_charges + ward_charges_bonus*extra)
		display_info("Picked up a Ward. Press Q to deploy")
		return true
	return true

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func jump_ex(je):
	if is_on_floor_ex() and je>0.0:
		velocity.y = jump_velocity*(je/jump_energy)
		antigrav_jump_available = 0.6

func regular_jump():
	if is_on_floor_ex():
		var je = current_energy
		if je > jump_energy:
			je = jump_energy
		current_energy -= je
		je/=jump_energy			
		velocity.y = jump_velocity*je
		antigrav_jump_available = 0.6

func pitiful_jump():
	jump_ex(20.0)
	
func jump_sound():
	$sounds/jump.get_children().pick_random().play()

func play_step():
	$Camera/Feet.position.x = -$Camera/Feet.position.x
	$Camera/Feet.get_children().pick_random().play()
	step_distance=0

func throw_object(obj):
	get_parent().add_child(obj)
	obj.global_transform = item_spawn.global_transform
	obj.linear_velocity = -obj.global_transform.basis.z.normalized()*throw_speed + velocity
	$sounds/throw.play()

var time_off_ground = 0.0

func is_on_floor_ex():
	return time_off_ground < 0.15

func _physics_process(delta):
	if controls_locked:
		return
		
	if is_on_floor():
		time_off_ground = 0.0
	else:
		time_off_ground += delta
	
	if global_position.y < chamber_bottom - 100.0:
		_player_dead(velocity, 2)	
	
	var energy_restoring = true
		
	var sclose = $SporeDetector.get_overlapping_areas().size()
	spores_close = spores_close*0.9 + sclose*0.1
	if spores_close > 100.0:
		spores_close = 100.0
	spores_intensity = log(spores_close + 1.0)
	$sounds/spores01.volume_db = spores_intensity*13.0 - 80.0
	$sounds/spores02.volume_db = spores_intensity*11.0 - 75.0
	$sounds/spores03.volume_db = spores_intensity*9.0 - 70.0
		
	dodge_timeout-=delta
	if dodge_timeout<0.0:
		dodge_timeout=0.0
		
	dodge_cooldown-=delta
	if dodge_cooldown<0.0:
		dodge_cooldown=0.0
		
	if touching_spores > 0:
		spores_on_player += delta/(spore_resistance + 0.3*level_strength)
		if spores_on_player >= 1.0:
			_player_dead(velocity, 0)
	else:
		spores_on_player -= delta
		if spores_on_player < 0.0:
			spores_on_player = 0.0
	
	$Camera/SporesOverlay.set_progress(spores_on_player*0.99)
	
	
	if not timer_paused:
		time_passed += delta
	label_time.text = format_time(time_passed)
	label_energy.text = "{0}/{1}".format({0:int(current_energy), 1:max_energy})
	velocity += Vector3(0.0,-20.0,0.0)*delta
		
	label_consumables.text = "{0} Antigrav / {1} Tele / {2} Ward".format({0:int(antigrav_charges), 1:teleporter_charges, 2:ward_charges})
	var game = get_game_root()
	if game:
		label_debug.text = "Spores in chamber {0}, spread period {1}, total {2}, close {3}".format({0:game.current_chamber_spore, 
		1:int(game.spore_timer_adjusted()*10000.0), 2:get_parent().total_spores, 3:spores_close})
		label_dead.text = "Chamber {0}".format({0:current_chamber})
		
	if info_timeout > 0.0:
		info_timeout -= delta
		if info_timeout <= 0.0:
			info_message.visible = false
	
	$sounds/breath.set_volume_db((tanh(current_energy-100)+1)*(-1000))
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_strafe_left", "player_strafe_right", "player_forward", "player_reverse")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	hud.set_energy_percent(current_energy/max_energy)
	hud.set_grav_bonus(antigrav_charges)
	hud.set_teleport_bonus(teleporter_charges)
	hud.set_ward_bonus(ward_charges)
	# Add the gravity.
	if not is_on_floor():
		energy_restoring = false
		jump_energy_built=0.0
		velocity.y -= gravity * delta
		step_distance = 0
		if dodge_buffer:
			velocity += transform.basis * dodge_buffer
			dodge_buffer = Vector3(0.0,0.0,0.0)
	else: 		
		if direction:	
			var vel = velocity
			vel.y = 0.0
			step_distance += delta * velocity.length() * 0.3
			if step_distance>1.0:
				play_step()
		if old_velocity.y < -(fatal_velocity + level_strength*1.0):
			if perk_fall1:
				if energy_boost > 0.0:
					antigrav_protection = true
			if antigrav_charges > 0 and not antigrav_protection:
				if perk_boots1:
					antigrav_charges-=1
					antigrav_protection=true
					$sounds/jump_boots.play()
			if not antigrav_protection:
				label_dead.text = "v = {0}".format({0:snapped(old_velocity.y,0.01)})	
				_player_dead(old_velocity, 1)
		elif old_velocity.y < -1.0:
			play_step()
		antigrav_protection = false
	
	old_velocity = velocity

	# Handle Jump.
	antigrav_jump_available -= delta
	if antigrav_jump_available < 0.0:
		antigrav_jump_available = 0.0
		
	if Input.is_action_just_pressed("player_jump") and !is_on_floor():
		if antigrav_jump_available > 0.0:
			if antigrav_charges > 0:
				velocity.y += jump_velocity_antigrav
				antigrav_charges -= 1
				$sounds/jump_boots.play()
				antigrav_protection = true
				antigrav_jump_available = 0.0
		
	if jump_type == 1:
		if Input.is_action_just_released("player_jump"):
			regular_jump()
				
	if jump_type == 0:
		if Input.is_action_just_pressed("player_jump"):
			regular_jump()
			
	if jump_type == 2:
		if Input.is_action_pressed("player_jump"):
			var ed = 300.0*delta
			if ed > current_energy:
				ed = current_energy
			jump_energy_built += ed
			if jump_energy_built > jump_energy:
				ed -= (jump_energy_built - jump_energy)
				jump_energy_built = jump_energy
			current_energy-=ed
			energy_restoring = false
		if Input.is_action_just_released("player_jump"):
			jump_ex(jump_energy_built)
			jump_energy_built = 0.0
			
	if jump_type == 3:
		if Input.is_action_pressed("player_jump") and jump_energy_limit > 0.0:
			var ed = 400.0*delta
			if ed > current_energy:
				ed = current_energy
			jump_energy_limit -= ed
			if jump_energy_limit < 0.0:
				ed += jump_energy_limit
				jump_energy_limit = 0.0
			current_energy -= ed
			velocity.y += jump_velocity * 0.8 * ed/jump_energy
		if Input.is_action_just_pressed("player_jump"):
			if is_on_floor_ex():
				pitiful_jump()
				jump_sound()
				jump_energy_limit = jump_energy
		if Input.is_action_just_released("player_jump"):
			jump_energy_limit = 0.0
			
	
	#Handle crouch
	var crouch_test = Input.is_action_pressed("player_crouch")
	if $head_bumper.has_overlapping_bodies():
		#var b = $head_bumper.get_overlapping_bodies()
		crouch_test = true
	#if $head_bumper.has_overlapping_areas():
	#	crouch_test = true
	if crouch_test:
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
			

	
	if is_on_floor():
		var acc_vector = direction
		var dir_correction = 1.0
		if !direction:
			acc_vector = -Vector3(velocity.x,0.0,velocity.z).normalized()
		else:
			dir_correction = abs(direction.dot(Vector3(velocity.x, 0.0, velocity.z).normalized()))
			if dir_correction < 0.1:
				dir_correction = 0.1
		var max_speed = SPEED*speed_coef*(1.0-spores_on_player)*dir_correction
		
		if Input.is_action_pressed("player_run") and direction:
			energy_restoring = false
			if current_energy > 0:
				max_speed *= 1.5
				current_energy-=delta*60
		var nv = Vector3(velocity.x, 0.0, velocity.z)
		var na = acc_vector * acceleration * delta
		if !direction and na.length_squared() > nv.length_squared():
			nv = Vector3(0.0,0.0,0.0)
		else:
			nv += na
		var spd = nv.length()
		if spd > max_speed:
			nv = max_speed*nv.normalized()
		velocity.x = nv.x
		velocity.z = nv.z
	elif direction:
		var vair = Vector3(velocity.x, 0.0, velocity.z)
		var d = vair.dot(direction)
		var dv = clamp(exp(-d*aircontrol_damp),0.0, aircontrol_limit)
		dv *= SPEED * air_control
		velocity.x += direction.x * dv * delta
		velocity.z += direction.z * dv * delta
		
		
	if energy_restoring:
		current_energy = min(max_energy,current_energy + delta * energy_regain_speed)
		
	if energy_boost > 0.0 or infinite_energy_cheat:
		energy_boost-=delta
		if energy_boost < 0.0:
			hud.set_infinite_energy(false)
		current_energy = max_energy
	
	move_and_slide()

func _input(event):
	if controls_locked:
		return
	var act = Vector2i(0,0)
	if event.is_action_pressed("player_strafe_left"):
		act = Vector2i(-1,0)
	if event.is_action_pressed("player_strafe_right"):
		act = Vector2i(1,0)
	if event.is_action_pressed("player_forward"):
		act = Vector2i(0,-1)
	if event.is_action_pressed("player_reverse"):
		act = Vector2i(0,1)
	
	if not act==Vector2i(0,0):
		if act != last_strafe or dodge_timeout <= 0.0 or dodge_cooldown > 0.0:
			last_strafe = act
			dodge_timeout = 0.2
		else:
			if is_on_floor_ex():
				var je = current_energy
				if je > dodge_energy:
					je = dodge_energy
				current_energy -= je
				je /= dodge_energy			
				velocity.y += dodge_velocity_vertical*je
				jump_sound()
				dodge_buffer = Vector3(act.x, 0.0, act.y)*dodge_velocity_horizontal*je
				#antigrav_jump_available = 0.6
				last_strafe = Vector2i(0,0)
				dodge_timeout = 0.0
				dodge_cooldown = 0.6
				time_off_ground = 0.5
			
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q:
			if ward_charges > 0:
					ward_charges -= 1
					var ward = null
					if perk_ward2:
						ward = exward_scene.instantiate()
					else:
						ward = ward_scene.instantiate()
					if perk_ward1:
						ward.lockpick = true
					if perk_ward3:
						ward.slowdown = 0.5
					ward.lifetime = 10.0 + level_ward*0.5
					throw_object(ward)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg_to_rad(event.relative.x * -camera_sensitivity * mouse_sens))
		camera.rotate_x(deg_to_rad(event.relative.y * -camera_sensitivity * mouse_sens))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -70, 70)
		camera.rotation_degrees.z = 0.0
		camera.rotation_degrees.y = 0.0
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if teleporter_charges > 0:
					teleporter_charges -= 1
					hud.tele_created()
					if teleporter!=null:
						teleporter.player = null
						teleporter.queue_free()
					teleporter = teleporter_scene.instantiate()
					teleporter.deploy_speed = 0.5 + level_teleport*0.2
					teleporter.player = self
					throw_object(teleporter)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if teleporter!=null:
					if teleporter.engaged:
						var bs = basis
						teleporter.activate(bs)
						$FX/Teleport.run()
						$sounds/teleport.play()
						teleporter = null
				elif perk_tele2 and teleporter_locstack.size()>0 and teleporter_charges >= 2:
					var bs = basis
					$FX/Teleport.run()
					$sounds/teleport.play()
					teleporter_charges -= 2
					await get_tree().create_timer(1.0).timeout
					global_position = teleporter_locstack.front()
					velocity = Vector3.ZERO
					basis = bs
					
					
					
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


func _on_area_3d_area_entered(area):
	if area.get_collision_layer_value(20):
		_player_dead(velocity, 2)
	if area.get_collision_layer_value(25):
		_player_dead(velocity, 10)
	if area.get_collision_layer_value(3):
		var game = get_game_root()
		if game and game.do_spores_kill():
			touching_spores+=1

func _on_area_3d_area_exited(area):
	if area.get_collision_layer_value(3):
		var game = get_game_root()
		if game and game.do_spores_kill():
			touching_spores-=1

#only to be deferred called
func roll_head(death_velocity):
	var dead_body = dead_player_scene.instantiate()
	get_parent().add_child(dead_body)
	dead_body.global_transform = self.global_transform
	dead_body.linear_velocity = death_velocity	
	remove_child(camera)
	dead_body.add_child(camera)
	var sounds = $sounds
	remove_child(sounds)
	dead_body.add_child(sounds)	
	queue_free()

func _player_dead(death_velocity, cause):
	dead = true
	_show_menu()
	
	var chambers_left = Global.total_chambers - current_chamber
	death_screen.find_child("info").text = "{0} chambers away from the emergency exit".format({0:chambers_left})
	$Camera/Soundtrack.set_state("dead")
	
	if cause==0:
		death_screen.find_child("cause_spores").show()
		$sounds/death.get_children().pick_random().play()
	if cause==1:
		death_screen.find_child("cause_crashed").show()
		$sounds/death.get_children().pick_random().play()
	if cause==2:
		death_screen.find_child("cause_fell").show()
		$sounds/death_fall.play()		
		
	#victory
	if cause==10:
		death_screen.find_child("info").text = "You've cleared the facility in {0} ".format({0:format_time(time_passed)})
		death_screen.find_child("cause_victory").show()
		$sounds/victory.play()		

	call_deferred("roll_head", death_velocity)

func _on_breath_finished():
	$sounds/breath.play()
	
func _show_menu():		
	death_screen.show()
	restart_button.activate()
	menu_button.activate()
	hud_sprite.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _hide_menu():
	hud_sprite.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	death_screen.hide()
	restart_button.deactivate()
	menu_button.deactivate()	



func _on_every_sec_timeout():
	if is_on_floor():
		teleporter_locstack.push_back(global_position)
		if teleporter_locstack.size() > 5:
			teleporter_locstack.pop_front()
