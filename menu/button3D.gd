extends Node3D

var mouse_in = false
var button_pressed = false
@export var text = ""
@export var active = false
@export var color : Color = Color.WHITE
@export var hover_color : Color = Color.RED
signal button_clicked

func _ready():
	$Label3D.text=text
	$Label3D.modulate = color

func activate():
	$Area3D.input_ray_pickable = true
	active = true

func deactivate():
	$Area3D.input_ray_pickable = false
	active = false

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
	$Label3D.modulate = hover_color


func _on_area_3d_mouse_exited():
	mouse_in = false
	$Label3D.modulate = color
