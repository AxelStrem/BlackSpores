extends Node3D

var active_spores = -1
@export var no_top = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if no_top:
		remove_child($MeshInstance3D)

func activate_spore(_s):
	if active_spores<0:
		active_spores=1
	else:
		active_spores+=1
		
func deactivate_spore(_s):
	active_spores-=1
	if active_spores<=0:
		queue_free()
