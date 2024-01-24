extends Node3D

func _ready():
	var ch = get_children().duplicate()
	var sel = ch.pick_random()
	for c in ch:
		if c!=sel:
			c.queue_free()

