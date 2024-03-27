extends Node3D

@export var index = 0
@export var trait_name = "Speed"
@export var alt = "Each level increases character base speed by 3%"
@export var cap_level = 20

var current_level = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	$LabelName.text = trait_name
	pass # Replace with function body.

func _on_button_3d_button_clicked():
	get_parent().level_increased(index)

func _on_bg_mouse_entered():
	get_parent().update_tip(alt)

func set_points(level, rp, price):
	current_level = level+1
	$LabelLevel.text = "Level {0}".format({0:level+1})
	$button3D.set_text("+ ({0} RP)".format({0:price}))
	if rp >= price:
		$button3D.activate()
	else:
		$button3D.deactivate()
	if current_level >= cap_level:
		$button3D.set_text("MAX")
		$button3D.deactivate()
