extends Node3D

func run():
	$rings.emitting=true
	$Timer.start()

func _on_timer_timeout():
	$rings.emitting=false
