extends Node3D

var energyBar
var infiniteBar
var antigravDots
var teleportDots
var vardDots

# Called when the node enters the scene tree for the first time.
func _ready():
	energyBar = $EnergyBar
	infiniteBar = $InfiniteBar	
	energyBar.visible = true
	infiniteBar.visible = false
	antigravDots = [$BonusFrame/Dot1,$BonusFrame/Dot2,$BonusFrame/Dot3,$BonusFrame/Dot4,$BonusFrame/Dot5,$BonusFrame/Dot6,$BonusFrame/Dot7,$BonusFrame/Dot8,$BonusFrame/Dot9,$BonusFrame/Dot10]
	teleportDots  = [$BonusFrame2/Dot1,$BonusFrame2/Dot2,$BonusFrame2/Dot3,$BonusFrame2/Dot4,$BonusFrame2/Dot5,$BonusFrame2/Dot6,$BonusFrame2/Dot7,$BonusFrame2/Dot8,$BonusFrame2/Dot9,$BonusFrame2/Dot10]
	vardDots  = [$BonusFrame3/Dot1,$BonusFrame3/Dot2,$BonusFrame3/Dot3,$BonusFrame3/Dot4,$BonusFrame3/Dot5,$BonusFrame3/Dot6,$BonusFrame3/Dot7,$BonusFrame3/Dot8,$BonusFrame3/Dot9,$BonusFrame3/Dot10]
	lightDots(antigravDots,0)
	lightDots(teleportDots,0)
	lightDots(vardDots,0)

func set_infinite_energy(value):
	if value:
		energyBar.visible = false
		infiniteBar.visible = true
	else:
		energyBar.visible = true
		infiniteBar.visible = false
		

func set_energy_percent(value):
	energyBar.position.x = 1.85*(1.0 - value)
	
func lightDots(dots, number):
	for n in 10:
		if n<number:
			dots[n].visible = true
		else:
			dots[n].visible = false

func set_grav_bonus(number):
	lightDots(antigravDots, number)
	
func set_teleport_bonus(number):
	lightDots(teleportDots, number)
	
func set_ward_bonus(number):
	lightDots(vardDots, number)
