extends Node3D

var active_spores = -1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func activate_spore():
	if active_spores<0:
		active_spores=1
	else:
		active_spores+=1
		
func deactivate_spore():
	active_spores-=1
	if active_spores<=0:
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
