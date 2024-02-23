extends Node


var b = 0
var th = 0.5

const beat_len = 60.0/88.0
const drum_kick = [0.0, 1.0]
const drum_snare = [1.0, 2.0]
const drum_hat = [2.0, 3.0]
const drum_crash = [3.0, 4.0]

var vol_crash = 0.0
var vol_kick = 3.0
var vol_snare = 2.0
var vol_hat = 5.0

var intro = 0
var playing = false

var drum_prob = [
	[1.0, 0.25, 0.5, 0.1],
	[0.1, 0.0, 0.5, 0.1],
	[0.25, 0.3, 0.5, 0.1],
	[0.1, 0.15, 0.5, 0.1],
	
	[0.5, 1.0, 0.5, 0.1],
	[0.1, 0.15, 0.5, 0.1],
	[0.25, 0.3, 0.5, 0.1],
	[0.1, 0.15, 0.5, 0.1],
	
	[1.0, 0.25, 0.5, 0.1],
	[0.1, 0.15, 0.5, 0.1],
	[0.25, 0.3, 0.5, 0.1],
	[0.1, 0.15, 0.5, 0.1],
	
	[0.5, 1.0, 0.5, 0.3],
	[0.1, 0.15, 0.5, 0.1],
	[0.25, 0.3, 0.5, 0.3],
	[0.1, 0.15, 0.5, 0.1],
]

var drum_dist = []

func play():
	intro = 4
	playing = true
	pass
	
func set_state(s):
	if s=="dead":
		vol_crash = -9999.0
		vol_hat = -9999.0
		vol_snare = -9999.0

func gen_beat(i):
	for j in range(4):
		var d = drum_prob[i][j]
		var r = randf()*0.6 + 0.2
		drum_dist[i][j] = d*r + randf()*0.2

func gen_dist():
	drum_dist = drum_prob.duplicate()
	for i in range(16):
		gen_beat(i)
		
			
func mutate_dist():
	var i = randi_range(0, 15)
	gen_beat(i)

# Called when the node enters the scene tree for the first time.
func _ready():
	gen_dist()



func play_drum(ft, t, v = 0.0):
	var from = ft[0]
	var to = ft[1]
	for c in get_children():
		if c.try_play(from*beat_len + t,to*beat_len, v):
			return

func beat(t):
	b += 1
	if b>=16:
		b = 0		
		if intro > 0:
			intro-=1
			if intro==0:
				play_drum(drum_kick,t, vol_kick)
				play_drum(drum_crash,t, vol_crash+0.5)
			return
		mutate_dist()
	if intro > 0:
		return
	var dd = drum_dist[b]
	if dd[0]>th:
		play_drum(drum_kick, t, log(dd[0])*5.0 + vol_kick)
	if dd[1]>th:
		play_drum(drum_snare, t, log(dd[1])*10.0 + vol_snare)
	if dd[2]>0.1:
		play_drum(drum_hat, t, log(dd[2])*20.0 + vol_hat)
	if dd[3]>th:
		play_drum(drum_crash, t, log(dd[3])*5.0 + vol_crash)
	
	
