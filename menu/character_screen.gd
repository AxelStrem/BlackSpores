extends MeshInstance3D

var entries = []
var perks = []

var lv_dist = []
var perk_dist = []
var research_points = 0

func _ready():
	entries.append($PanelSpeed)
	entries.append($PanelStamina)
	entries.append($PanelHacking)
	entries.append($PanelTeleporter)
	entries.append($PanelWard)
	entries.append($PanelStrength)

	perks.append($PerkBoots1)
	perks.append($PerkStamina1)
	perks.append($PerkHacking1)
	perks.append($PerkTele1)
	perks.append($PerkWard1)
	
	$"../button_character".visible = !Global.first_run
	
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
		game.save_character(research_points, lv_dist, perk_dist)
	update_points()
		
func update_points():
	for i in range(lv_dist.size()):
		entries[i].set_points(lv_dist[i], research_points, get_price(lv_dist[i]))
	for i in range(perk_dist.size()):
		var p = perk_dist[i]
		if p >= 1:
			perks[i].enable()
			if p == 1:
				perks[i].disengage()
		perks[i].update_rp(research_points)
	$RP.text = "{0} Researh Points".format({0:research_points})

func set_points(rp, lvs, prks):
	research_points = rp
	lv_dist = lvs.duplicate()
	perk_dist = prks.duplicate()
	update_points()
	

func buy_perk(index):
	var game = Global.get_game_root(self)
	research_points -= perks[index].price
	perk_dist[index] = 2
	perks[index].enable()
	if game != null:
		game.save_character(research_points, lv_dist, perk_dist)
	update_points()
	
func disengage_perk(index):
	var game = Global.get_game_root(self)
	perk_dist[index] = 1
	perks[index].disengage()
	if game != null:
		game.save_character(research_points, lv_dist, perk_dist)
	update_points()
	
func engage_perk(index):
	var game = Global.get_game_root(self)
	perk_dist[index] = 2
	perks[index].disengage()
	if game != null:
		game.save_character(research_points, lv_dist, perk_dist)
	update_points()
