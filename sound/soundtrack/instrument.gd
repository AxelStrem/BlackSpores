extends Node


const bpm = 88.0
const bar = 8.0*60.0/bpm
const eps = 0.05

const bar_death = [[0,1]]
const bar_wait = [[1,2]]
const bar_l1 = [[2,4],[4,6],[6,8],[8,10]]
const bar_c1 = [[10,12]]

@export var volume = 0.0

var bar_now = 0
var bar_next = 0
var bar_counter = 0
var int_now = [-1,0]

var state = 2
var intensity = 0.0
var t = 0.0
var t_target = 0.0
var t_target2 = 0.0

var p1 : AudioStreamPlayer = null
var p2 : AudioStreamPlayer = null

var playing = false
var beat_timer = 0.0

signal beat

func get_pos(b):
	return b*bar

func bass_get_int():
	if bar_counter >= 12:
		bar_counter = 0
	if bar_counter < 8:
		return bar_l1.pick_random()
	else:
		return bar_c1.pick_random()

func _ready():
	p1 = $Player01
	p2 = $Player02

func set_state(s):
	if s == "dead":
		state = 1
	if s == "run":
		state = 0

func select_bar():
	if state == 0:
		bar_next = bar_now + 1
		bar_counter += 1
		if bar_next >= int_now[1]:
			int_now = bass_get_int()
			bar_next = int_now[0]
	if state == 1:
		bar_next = 0
		state = 2
		return
	if state == 2:
		bar_next = 1
		return
		

func reset_players():
	select_bar()
	bar_now = bar_next
	$Player01.volume_db = volume
	$Player02.volume_db = -9999.0
	p1 = $Player01
	p2 = $Player02

func play():
	reset_players()
	var t_start = get_pos(bar_now)
	t_target = t_start + bar
	p1.play(t_start)
	playing = true
	t = -bar
	beat_timer = 0.0


var trans = false
var zbar = false

func _process(delta):
	if playing:
		var p = p1.get_playback_position()
		t = p - t_target
		beat_timer -= delta
		if beat_timer < 0.0:
			emit_signal("beat", -beat_timer)
			beat_timer += bar/32.0
	if t > -eps and not trans:
		trans = true
		select_bar()
		if bar_next == 0:
			zbar = true
		else:
			var t_start2 = get_pos(bar_next)+t
			t_target2 = t_start2 + bar
			p2.play(t_start2)
			p2.volume_db = -99999.0
	if zbar and trans and t>=0.0:
			var t_start2 = t
			t_target2 = t_start2 + bar
			p2.play(t_start2)
			p2.volume_db = -99999.0
			zbar = false
	if t > eps and trans:
		if beat_timer < bar/128.0:
			emit_signal("beat", t)
		beat_timer = bar/32.0 - t
		trans = false
		p1.stop()
		p1.volume_db = -99999.0
		var pt = p1
		p1 = p2
		p2 = pt
		t -= bar
		t_target = t_target2
	if trans and not zbar:
		var dt = (t + eps)/(2.0*eps)
		p1.volume_db = log(1.0 - dt) + volume
		p2.volume_db = log(dt) + volume
		bar_now = bar_next
