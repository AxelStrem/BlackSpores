extends Node3D

@export var complexity = 3.0
@export var door_speed = 1.5
@export var slide_speed = 1.0
@export var locks_destructible = true
# Called when the node enters the scene tree for the first time.
func _ready():
	$silo_door.speed = door_speed
	$silo_door.slide_speed = slide_speed
	$digital_lock.update_complexity(complexity)
	$digital_lock2.update_complexity(complexity)
	$digital_lock3.update_complexity(complexity)
	$digital_lock4.update_complexity(complexity)
	if not locks_destructible:
		$digital_lock.find_child("SporeDestructible").queue_free()
		$digital_lock2.find_child("SporeDestructible").queue_free()
		$digital_lock3.find_child("SporeDestructible").queue_free()
		$digital_lock4.find_child("SporeDestructible").queue_free()
	
