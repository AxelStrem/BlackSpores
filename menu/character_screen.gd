extends MeshInstance3D

var entries = []
var lv_dist = []
var research_points = 0

func _ready():
	entries.append($PanelSpeed)
	entries.append($PanelStamina)
	entries.append($PanelHacking)
	entries.append($PanelTeleporter)
	entries.append($PanelWard)
	var game = Global.get_game_root(self)
	if game != null:
		game.load_character(self)

func get_price(lv):
	return lv+1

func update_tip(text):
	$tip.text = text

func level_increased(idx):
	var game = Global.get_game_root(self)
	research_points -= get_price(lv_dist[idx])
	lv_dist[idx] += 1
	if game != null:
		game.save_character(research_points, lv_dist)
	update_points()
		
func update_points():
	for i in range(lv_dist.size()):
		entries[i].set_points(lv_dist[i], research_points, get_price(lv_dist[i]))
	$RP.text = "{0} Researh Points".format({0:research_points})

func set_points(rp, lvs):
	research_points = rp
	lv_dist = lvs.duplicate()
	update_points()
