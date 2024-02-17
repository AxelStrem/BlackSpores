extends Node3D

var mouse_in = false
var button_pressed = false
@export var text = ""
@export var active = false
@export var color : Color = Color.WHITE
@export var hover_color : Color = Color.RED
@export var inactive_color : Color = Color.DIM_GRAY
@export var background = false
@export var background_width = 1.0
@export var background_color : Color = Color.DIM_GRAY
@export var background_hover : Color = Color.DIM_GRAY
@export var background_inactive : Color = Color.DIM_GRAY

var background_material = null

signal button_clicked
signal button_mouse_in
signal button_mouse_out

func set_text(txt):
	text = txt
	$Label3D.text=txt
	

func update():
	$Label3D.text=text
	$Label3D.modulate = color
	if background:
		$Background.show()
		background_material = $Background.get_active_material(0).duplicate()
		$Background.material_override = background_material
		background_material.albedo_color = background_color
		$Background.scale.x = background_width
		$Area3D.scale.x = background_width
	else:
		$Background.hide()

func _ready():
	update()

func activate():
	$Area3D.input_ray_pickable = true
	active = true
	if mouse_in:
		$Label3D.modulate = hover_color
		if background:
			background_material.albedo_color = background_hover
	else:
		$Label3D.modulate = color
		if background:
			background_material.albedo_color = background_color

func deactivate():
	$Area3D.input_ray_pickable = false
	active = false
	$Label3D.modulate = inactive_color
	if background:
		background_material.albedo_color = background_inactive
	

func _input(event):
	if !active:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			if self.mouse_in:
				button_pressed = true
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			if self.mouse_in and button_pressed:
				button_clicked.emit()
			button_pressed = false

func _on_area_3d_mouse_entered():
	mouse_in = true
	if active:
		$Label3D.modulate = hover_color
		if background:
			background_material.albedo_color = background_hover
	emit_signal("button_mouse_in")


func _on_area_3d_mouse_exited():
	mouse_in = false
	if active:
		$Label3D.modulate = color
		if background:
			background_material.albedo_color = background_color
	emit_signal("button_mouse_out")
