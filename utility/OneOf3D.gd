@tool 
extends Node3D

@export var scenes : Array[PackedScene] = []
@export var probabilities : Array[float] = []
@export var keep : int = 1

var t = 1.0

func init_nodes():
	if scenes.size() > 0:
		var s = scenes.pick_random()
		var n = s.instantiate()
		add_child(n)

func _ready():
	if not Engine.is_editor_hint():
		init_nodes()


func _process(delta):
	if Engine.is_editor_hint():
		t-=delta
		if t < 0.0:
			for n in get_children():
				remove_child(n)
				return
			t = 1.0
			init_nodes()
			
