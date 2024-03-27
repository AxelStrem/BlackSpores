extends RigidBody3D

var engaged = false
var deploying = 0
var prog = 0.0
var lifetime = 0.0
var start_lifetime = 0.0
var zscale = 1.0
var game = null
var lockpick = false
var slowdown = 1.0

var spore_destructible_scene = preload("res://spore_destructible.tscn")

@export var radius = 10.0

var speed = 0.2

var pistons_in_contact = {}

var crot = Vector3(0.0,0.0,0.0)
var last_contact = null

@onready var pikes = [
	[$box/pikes/PistonPike04, Vector3(1.0,1.0,1.0)],
	[$box/pikes/PistonPike01, Vector3(1.0,1.0,-1.0)],
	[$box/pikes/PistonPike02, Vector3(-1.0,1.0,-1.0)],
	[$box/pikes/PistonPike03, Vector3(-1.0,1.0,1.0)],
	[$box/pikes/PistonPike05, Vector3(1.0,-1.0,1.0)],
	[$box/pikes/PistonPike06, Vector3(1.0,-1.0,-1.0)],
	[$box/pikes/PistonPike07, Vector3(-1.0,-1.0,-1.0)],
	[$box/pikes/PistonPike08, Vector3(-1.0,-1.0,1.0)]
]

var pikes_ext = 0.0

func _ready():
	angular_damp = 1.0
	linear_damp = 0.5

func lock_and_freeze():
	sleeping = true
	freeze = true
	
	for p in pistons_in_contact:
		p._on_piston_body_ext_lock()
	
	if last_contact!=null:
		if last_contact.is_in_group("piston_body"):
			last_contact.lock_extended()
		#var gt = global_transform
		#var p = get_parent()
		#p.remove_child(self)
		#last_contact.add_child(self)
		#global_transform = gt
		
	
	for p in $box/pistons.get_children():
		p.enable_extension()
	

func register_piston(p):
	pistons_in_contact[p]=true
	
func unregister_piston(p):
	pistons_in_contact.erase(p)

func _process(delta):
	
	if deploying==0 and linear_velocity.length_squared()<0.1:
		deploying = 1
				
		for p in $box/pistons.get_children():
			p.deploy(speed)
	
	if deploying==1:
		pikes_ext += delta*speed*5.0
		if pikes_ext > 1.0:
			deploying = 2
			pikes_ext = 1.0
		for pp in pikes:
			pp[0].position = pikes_ext * pp[1] * 1.5
		$CollisionShape3D.scale = Vector3.ONE * (0.703 + pikes_ext*0.7)
			
	if deploying==2 and linear_velocity.length_squared()<0.1:
		call_deferred("lock_and_freeze")
		deploying = 3
		


func _on_body_entered(body):
	if not Global.is_an_ancestor(body, self):
		last_contact = body
	if deploying < 2:
		$thump.pitch_scale = 0.8 + randf()*0.3
		$thump.volume_db = -10.0-randf()*5.0
		$thump.play()
