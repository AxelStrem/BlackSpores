extends Node3D

@export var silo_door : Node3D = null
@export var top = false

func unlock():
	if top:
		silo_door.unlock_u()
	else:
		silo_door.unlock_l()
