extends Area3D

signal spore_hit

func _on_area_entered(_area):
	emit_signal("spore_hit")
	var p = get_parent()
	if p!=null:
		p.queue_free()
	else:
		queue_free()
