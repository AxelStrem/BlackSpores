extends Node3D

var enabled = false
var engaged = false

@export var index = 0
@export var tag = ""
@export var tip = ""
@export var price = 10

@export var condition_node : Node3D = null
@export var condition_level = 5

var research_points = 0
var tip_tag = ""

func enable():
	enabled = true
	engaged = true
	
func engage():
	engaged = true
	update()
	
func disengage():
	engaged = false
	update()
	
func update():
	tip_tag = tip
	if not enabled:
		$button3D.text = tag + "({0} RP)".format({0:price})		
		$button3D.background_color = Color(0.4,0.4,0.4)
		$button3D.background_hover = Color(0.6,0.6,0.6)
		$button3D.background_inactive = Color(0.2,0.2,0.2)
		var force_disable = false
		if condition_node != null:
			if condition_node.current_level < condition_level:
				force_disable = true
				tip_tag = "{0} level {1} required".format({0:condition_node.trait_name, 1:condition_level})
		if price <= research_points and not force_disable:
			$button3D.activate()
		else:
			$button3D.deactivate()
	else:
		if engaged:
			$button3D.text = tag + "ON"
			$button3D.background_color = Color(0.6,0.8,0.6)
			$button3D.background_hover = Color(0.8,1.0,0.8)
		else:
			$button3D.text = tag + "OFF"
			$button3D.background_color = Color(0.2,0.4,0.2)
			$button3D.background_hover = Color(0.3,0.6,0.3)
		$button3D.activate()
	$button3D.update()

func _ready():
	update()
	
func update_rp(rp):
	research_points = rp
	update()


func _on_button_3d_button_clicked():
	if not enabled:
		get_parent().buy_perk(index)
	else:
		if engaged:
			get_parent().disengage_perk(index)
		else:
			get_parent().engage_perk(index)


func _on_button_3d_button_mouse_in():
	get_parent().update_tip(tip_tag)
