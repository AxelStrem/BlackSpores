extends "res://spore_consumable.gd"

@export var level_in : Node3D = null
@export var level_out : Node3D = null
@export var next_level : Node3D = null

var level_in_pos : Vector3
var level_out_pos : Vector3

var level_number = 0

var b_spores_in = false
var b_spores_out = false

@export var level_test = 0

@export var spore_list = []
@export var spore_graph = {}


var full_node_list = []
var nl_semaphore : Semaphore

func _ready():
	nl_semaphore = Semaphore.new()
	
func init():
	level_in_pos = level_in.global_position
	level_out_pos = level_out.global_position
	$InitTimer.start()

func list_shapes():
	var nodes = Global.list_children_recursive(self)
	full_node_list = []
	for N in nodes:
		if N is Area3D:
			if N.get_collision_layer_value(2):
				var L=0
				if N.get_collision_layer_value(31):
					L+=1
				if N.get_collision_layer_value(32):
					L+=2
				if N.get_collision_layer_value(4):
					L=-1
				var shapes = N.get_children()
				if shapes.size() > 0:
					full_node_list.append([shapes[0], L])
	nl_semaphore.post()

func render_spores(game_node):
	call_deferred("list_shapes")
	nl_semaphore.wait()
	var nodes = full_node_list
	var block_list = []
	for N in nodes:
		if is_instance_valid(N[0]):
			if N[1]!=-1:
				game_node.spore_render_shape(N[0], N[1])
			else:
				block_list.append(N[0])
	for N in block_list:
		game_node.spore_render_shape(N,-1)
	game_node.spore_render_level_in(self, level_in_pos)
	game_node.spore_render_level_out(self, level_out_pos)
	
func spores_in(_p):
	if !b_spores_in:
		b_spores_in = true
	
func spores_out(_p):
	if !b_spores_out:
		b_spores_out = true
		$DestructTimer.start()

func player_N_levels_away(N):
	if N>=4:
		return
	if next_level == null:
		next_level = Global.generate_level(level_number+1)
		#print('LEVEL CREATED')
		if(next_level == null):
			return
		get_parent().add_child(next_level)
		var nl_in = next_level.level_in
		var nl_out = level_out
		var q1 = Quaternion(nl_out.global_basis)
		var q2 = Quaternion(nl_in.global_basis).inverse()
		next_level.global_basis = Basis(q1*q2)
		
		var sh = nl_out.global_position - nl_in.global_position
		next_level.global_position += sh
		next_level.init()
		#next_level.call_deferred('spore_render_level')
		#print('LEVEL ADDED')
	next_level.player_N_levels_away(N+1)
		

func _on_player_entered(player):
	player.current_chamber = level_number
	if level_number!=0:
		player.display_info("Entering chamber #{0}, T{1}".format({0:level_number, 1:level_test}))
	player_N_levels_away(0)


func _on_destruct_timer_timeout():
	queue_free()


func _on_init_timer_timeout():
	var game = Global.get_game_root(self)
	if game!=null:
		game.call_deferred('append_level', self)
