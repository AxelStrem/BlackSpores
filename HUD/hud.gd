extends Node3D

var blueBar
var violetBar

var antigrav_charges = 0
var ward_charges = 0
var teleport_charges = 0
var is_infinit_energy = false
var current_energy = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	blueBar = $MeshInstance3D/hud_basics/EnergyBarBlue
	blueBar.visible=true
	violetBar =  $MeshInstance3D/hud_basics/EnergyBarViolet
	violetBar.visible=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _set_infinit_energy(value):
	if value:
		violetBar.visible=true
		blueBar.visible=false
	else:
		blueBar.visible=true
		violetBar.visible=false

func _set_energy_percent(value):
	blueBar.position.x=1.8*(1-value)
