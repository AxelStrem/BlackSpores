extends Node3D

var state = 0
var speed = 0.0
@export var target : Node3D = null
@export var complexity = 5.0
var target_scale = 0.0
var init_comp = 0.0

func _ready():
	target_scale = $ScreenProgress/MeshInstance3D.scale.x
	init_comp = complexity
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state==1:
		complexity -= speed*delta
		$ScreenProgress/MeshInstance3D.scale.x = lerp(target_scale, 0.0, complexity/init_comp)
		if complexity < 0.0:
			state = 2
			update_state()
			if target!=null:
				target.unlock()
				
func update_state():
	if state == 0:
		$ScreenLocked.show()
		$ScreenUnlocked.hide()
		$ScreenProgress.hide()
	if state == 1:
		$ScreenLocked.hide()
		$ScreenUnlocked.hide()
		$ScreenProgress.show()
	if state == 2:
		$ScreenLocked.hide()
		$ScreenUnlocked.show()
		$ScreenProgress.hide()

func _on_player_entered(body):
	if state!=2:
		state = 1
		speed = body.lockpick_skill
		update_state()


func _on_player_exited(_body):
	if state==1:
		state = 0
		update_state()


func _on_spore_destructible_spore_hit():
	if target!=null:
		target.unlock()
