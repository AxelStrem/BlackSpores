extends Node3D

var energyBar
var energyLight
var infiniteBar
var antigravDots
var teleportDots
var wardDots
var boxBar
var boxDots

var show_boots = false
var show_tele = false
var show_ward = false
var show_box = false
var tele_alive = false
var tele_pts = 0

var selected_frame = -1

signal hud_frame_selected

var mat_frames = preload("res://models/UI/frames.tres")
var mat_frames_selected = preload("res://models/UI/frames_selected.tres")

func update_frames():
	$BonusFrame.set_surface_override_material(0,mat_frames)
	$BonusFrame4.set_surface_override_material(0,mat_frames_selected if selected_frame == 0 else mat_frames)
	var mat2 = mat_frames_selected if selected_frame == 1 else mat_frames
	$BonusFrame2/BonusFrame_002.set_surface_override_material(0,mat2)
	$BonusFrame2/BonusFrame_003.set_surface_override_material(0,mat2)
	$BonusFrame2/BonusFrame_004.set_surface_override_material(0,mat2)
	var mat3 = mat_frames_selected if selected_frame == 2 else mat_frames
	$BonusFrame3/BonusFrame_001.set_surface_override_material(0,mat3)
	$BonusFrame3/BonusFrame_002.set_surface_override_material(0,mat3)
	$BonusFrame3/BonusFrame_003.set_surface_override_material(0,mat3)

func select_frame(frame, dir):
	var start_frame = frame
	var frame_check = [show_box, show_tele, show_ward]
	while true:
		if not frame_check[frame]:
			if dir==0:
				return
			frame = (frame+dir+3)%3
		else:
			selected_frame = frame
			hud_frame_selected.emit(selected_frame)
			update_frames()
			return
		if frame == start_frame:
			return
			

func input(event):
	if event.is_action_pressed("select_prev"):
		select_frame((selected_frame+4)%3,1)
	if event.is_action_pressed("select_next"):
		select_frame((selected_frame+2)%3,1)
	if event.is_action_pressed("select_1"):
		select_frame(0,0)
	if event.is_action_pressed("select_2"):
		select_frame(1,0)
	if event.is_action_pressed("select_3"):
		select_frame(2,0)
	
	#	kill_player()

# Called when the node enters the scene tree for the first time.
func _ready():
	energyBar = $EnergyBar
	energyLight = $EnergyBar/light
	infiniteBar = $InfiniteBar
	energyBar.visible = true
	infiniteBar.visible = false
	antigravDots = $BonusFrame/D1.get_children()
	teleportDots  = $BonusFrame2/D1.get_children()
	wardDots  = $BonusFrame3/D1.get_children()
	boxDots = $BonusFrame4/D1.get_children()
	lightDots(antigravDots,0)
	lightDots(teleportDots,0)
	lightDots(wardDots,0)
	lightDots(boxDots,0)

func set_infinite_energy(value):
	if value:
		energyBar.visible = false
		infiniteBar.visible = true
	else:
		energyBar.visible = true
		infiniteBar.visible = false
		

func set_energy_percent(value):
	energyBar.position.x = 1.85*(1.0 - value)
	energyLight.light_energy = 0.125*value
	
func lightDots(dots, number):
	for n in dots.size():
		if n<number:
			dots[n].visible = true
		else:
			dots[n].visible = false

func set_frame_style(frame, s):
	var dn = null		
	var do = null
	if s==1:
		dn = frame.find_child("D1")
		do = frame.find_child("D2")
	else:
		dn = frame.find_child("D2")
		do = frame.find_child("D1")
	do.hide()
	dn.show()
	return dn.get_children()
		

func set_style(s):
	antigravDots = set_frame_style($BonusFrame, s)
	teleportDots = set_frame_style($BonusFrame2, s)
	wardDots = set_frame_style($BonusFrame3, s)
	boxDots = set_frame_style($BonusFrame4, s)

func update_hud():
	var pos_z = 0.0
	if show_boots:
		$BonusFrame.show()
		$BonusFrame.position.z = pos_z
		pos_z += 0.32
	else:
		$BonusFrame.hide()
	if show_box:
		$BonusFrame4.show()
		$BonusFrame4.position.z = pos_z
		pos_z += 0.32
	else:
		$BonusFrame4.hide()
	if show_tele:
		$BonusFrame2.show()
		$BonusFrame2.position.z = pos_z
		pos_z += 0.32
	else:
		$BonusFrame2.hide()
	if show_ward:
		$BonusFrame3.show()
		$BonusFrame3.position.z = pos_z
		pos_z += 0.32
	else:
		$BonusFrame3.hide()
	
	
	

func set_grav_bonus(number):
	lightDots(antigravDots, number)
	show_boots = (number!=0)
	update_hud()
	
func set_teleport_bonus(number):
	lightDots(teleportDots, number)
	show_tele = ((number!=0) || tele_alive)
	tele_pts = number
	update_hud()
	
func set_ward_bonus(number):
	lightDots(wardDots, number)
	show_ward = (number!=0)
	update_hud()
	
func set_box_bonus(number):
	lightDots(boxDots, number)
	show_box = (number!=0)
	update_hud()
	
func tele_created():
	$BonusFrame2/t1.show()
	$BonusFrame2/t1/light_on.hide()
	$BonusFrame2/t1/light_off.hide()
	tele_alive = true
	show_tele = true
	update_hud()
	
func tele_online():
	$BonusFrame2/t1.show()
	$BonusFrame2/t1/light_on.show()
	$BonusFrame2/t1/light_off.hide()
	tele_alive = true
	show_tele = true
	update_hud()
	
func tele_destroyed():
	$BonusFrame2/t1.hide()
	$BonusFrame2/t1/light_on.hide()
	$BonusFrame2/t1/light_off.hide()
	tele_alive = false
	show_tele = (tele_pts != 0)
	update_hud()
