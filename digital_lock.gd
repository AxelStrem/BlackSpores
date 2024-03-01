extends Node3D

var state = 0
var speed = 0.0
var openers = 0
@export var target : Node3D = null
@export var complexity = 5.0
var beep_interval = 0.0
var target_scale = 0.0
var init_comp = 0.0


func init():
	var level = Global.get_level_root(self)
	init_comp *= (level.level_difficulty / 10.0)
	complexity = init_comp 

func _ready():
	target_scale = $ScreenProgress/MeshInstance3D.scale.x
	init_comp = complexity
	if target:
		target.register_lock(self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state==1:
		complexity -= speed*delta
		beep_interval -= speed*delta
		if beep_interval < 0.0:
			beep_interval = 0.2
			$beeps.get_children().pick_random().play()
		$ScreenProgress/MeshInstance3D.scale.x = lerp(target_scale, 0.0, complexity/init_comp)
		if complexity < 0.0:
			if target!=null:
				target.unlock()
			$lock_open.play()
				
func force_unlock():
	state = 2
	update_state()
				
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
	openers+=1
	speed += body.get_lockpick_skill()
	if state!=2:
		state = 1
		update_state()


func _on_player_exited(body):
	openers-=1
	speed -= body.get_lockpick_skill()
	if openers == 0:
		if state==1:
			state = 0
			speed = 0.0
			update_state()


func _on_spore_destructible_spore_hit():
	if target!=null:
		target.unlock()
