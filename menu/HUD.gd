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
	antigravDots = [$BonusFrame/Dot1,$BonusFrame/Dot2,$BonusFrame/Dot3,$BonusFrame/Dot4,$BonusFrame/Dot5,$BonusFrame/Dot6,$BonusFrame/Dot7,$BonusFrame/Dot8,$BonusFrame/Dot9,$BonusFrame/Dot10]
	teleportDots  = [$BonusFrame2/Dot1,$BonusFrame2/Dot2,$BonusFrame2/Dot3,$BonusFrame2/Dot4,$BonusFrame2/Dot5,$BonusFrame2/Dot6,$BonusFrame2/Dot7]
	wardDots  = [$BonusFrame3/Dot1,$BonusFrame3/Dot2,$BonusFrame3/Dot3,$BonusFrame3/Dot4,$BonusFrame3/Dot5]
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
