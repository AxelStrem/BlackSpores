@tool
extends Node3D

func _ready():
	#PhysicsServer3D.set_active(true)
	pass
	
func _physics_process(_delta):
	#print('X')
	pass

func _build():
	print('building level Z')
	return true
