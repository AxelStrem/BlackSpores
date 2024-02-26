extends Node3D

var energyBar
var energyLight
var infiniteBar
var antigravDots
var teleportDots
var wardDots

var show_boots = false
var show_tele = false
var show_ward = false
var tele_alive = false
var tele_pts = 0

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
	lightDots(antigravDots,0)
	lightDots(teleportDots,0)
	lightDots(wardDots,0)

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

func update_hud():
	var pos_z = 0.0
	if show_boots:
		$BonusFrame.show()
		$BonusFrame.position.z = pos_z
		pos_z += 0.32
	else:
		$BonusFrame.hide()
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
