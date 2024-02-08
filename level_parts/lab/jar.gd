extends Node3D

var spore_scene = preload("res://black_spore.tscn")
@export var door : Node3D  =null
@export var screen1 : Node3D  =null
@export var screen2 : Node3D  =null

var state = 0
var jar_angle = 0.0

var rot_speed = 1.5
var timer = 1.0

func _ready():
	var nc : RigidBody3D = $nutella_cap
	nc.freeze = true
	call_deferred("render_spore_placement")

func render_spore_placement():
	var level = get_parent().get_parent()
	var game = Global.get_game_root(self)
	game.append_level(level)
	game.activate_pos(self.global_position)

func start_evac():
	var sp = spore_scene.instantiate()
	sp.state = 7
	add_child(sp)
	sp.global_transform = $Jar.global_transform
	sp.global_basis = Basis.IDENTITY
	
	door.unlock()

func start_sequence():
	if state==0:
		state = 1

func _process(delta):
	if state==1:
		jar_angle += delta*rot_speed
		rotate_x(-delta*rot_speed)
		if jar_angle>=(PI/2.0)*0.84:
			state = 2
			start_evac()
			var nc : RigidBody3D = $nutella_cap
			nc.freeze = false
			var gt = nc.global_transform
			remove_child(nc)
			get_parent().get_parent().get_parent().add_child(nc)
			nc.global_transform = gt
			nc.linear_velocity = Vector3.LEFT*3.0
	if state==2:
		timer-=delta
		if timer < 0.0:
			state=3
			screen1.hide()
			screen2.show()
			
		

func _on_start_game():
	get_parent().get_parent().get_parent().start_game()	
	start_sequence()
