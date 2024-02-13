extends Node3D

@export var silo_door : Node3D = null
@export var top = false

var locks = []

func unlock():
	if top:
		silo_door.unlock_u()
	else:
		silo_door.unlock_l()
	
	for l in locks:
		if l != null:
			l.force_unlock()

func register_lock(l):
	locks.append(l)
