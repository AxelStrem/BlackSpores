extends Node3D

@export var complexity = 3.0
# Called when the node enters the scene tree for the first time.
func _ready():
	$digital_lock.complexity = complexity
	$digital_lock2.complexity = complexity
	$digital_lock3.complexity = complexity
	$digital_lock4.complexity = complexity
