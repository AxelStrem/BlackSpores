extends AudioStreamPlayer

var free = true
var t_target = 0.0
var fade = 0.0
const fade_speed = 25.0
const fadeout_speed = 5.0

var b_fade_in = false
var b_fade_out = false
var target_vol = 0.0

func update_vol():
	volume_db = target_vol + log(fade)*2.0

func fade_in(from):
	b_fade_in = true
	fade = 0.0
	update_vol()
	play(from)

func try_play(from, to, vol = 0.0):
	if not free:
		return false
	t_target = to
	target_vol = vol
	fade_in(from)
	free = false
	return true

func _process(delta):
	if not free:
		if b_fade_in:
			fade += delta*fade_speed
			if fade>=1.0:
				fade=1.0
				b_fade_in = false
			update_vol()
		if b_fade_out:
			fade-=delta*fadeout_speed
			if fade<=0.0:
				fade = 0.0
				b_fade_out = false
				stop()
				free=true
			update_vol()
		elif get_playback_position()>=t_target:
			b_fade_out=true
