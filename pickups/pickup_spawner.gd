extends Node3D

@export var spawn_probability = 0.2
@export var datapoint = true
@export var pill = true
@export var boots = true
@export var teleport = true
@export var ward = true
@export var box = true

var pickups = [preload("res://pickups/datapoint.tscn"),
 preload("res://pickups/speedboost.tscn"),
 preload("res://pickups/antigrav_boots.tscn"),
 preload("res://pickups/teleporter.tscn"),
 preload("res://pickups/ward.tscn"),
 preload("res://pickups/box.tscn")]

func _ready():
	if randf()>spawn_probability:
		return
	var vsc = []
	if datapoint:
		vsc.append(pickups[0])
	if pill:
		vsc.append(pickups[1])
	if boots:
		vsc.append(pickups[2])
	if teleport:
		vsc.append(pickups[3])
	if ward:
		vsc.append(pickups[4])
	if box:
		vsc.append(pickups[5])
	var pu = vsc.pick_random().instantiate()
	add_child(pu)	
	pu.global_basis = Basis.from_scale(Vector3.ONE*3.0)

