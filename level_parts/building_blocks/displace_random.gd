extends Node3D

@export var displace = Vector3(0.0,0.0,0.0)
# Called when the node enters the scene tree for the first time.
func _ready():
	var dx = (randf()-0.5)*2.0*displace.x
	var dy = (randf()-0.5)*2.0*displace.y
	var dz = (randf()-0.5)*2.0*displace.z
	position += Vector3(dx,dy,dz)
