extends Label3D

var tm = 1.0

func _process(delta):
	tm-=delta*1.8
	if tm > 0.0:
		show()
	else:
		hide()
	if tm < -1.0:
		tm=1.0
