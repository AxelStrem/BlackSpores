extends Node3D

var instruments = []

func _ready():
	#instruments = [$Bass]
	instruments = [$Ambient01]

func play():
	for i in instruments:
		i.play()

func set_state(s):
	for i in instruments:
		i.set_state(s)
		


func _on_bass_beat(_t):
	#$Drums.beat(t)
	pass
