extends Area3D


func _on_area_entered(_area):
	var p = get_parent()
	if p!=null:
		p.queue_free()
	else:
		queue_free()
