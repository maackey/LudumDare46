extends Node

export var edge_threshold = 10
export var cam_pan_speed = 10

onready var camera = $Camera2D
onready var hud = $CanvasLayer/hud
onready var castle = $castle
onready var towns = $towns
onready var minions = $minions
onready var monster_ref = weakref($dragon)
onready var health = find_node("health")
onready var hunger = find_node("hunger")
onready var lootchoice = $CanvasLayer2/lootchoice
onready var moneylabel = $CanvasLayer/hud/v/shop/money
onready var choicelabel = $CanvasLayer2/lootchoice/CenterContainer/VBoxContainer/lootchoicelabel
onready var tower_buy = find_node("tower_buy")
onready var wall_buy = find_node("wall_buy")
onready var ogre_buy = find_node("ogre_buy")
onready var orc_buy = find_node("orc_buy")
onready var goblin_buy = find_node("goblin_buy")
var selected_village = null
var selected_minions = []
var loot = null
var money = 0


func _update_money(value):
	money = value
	moneylabel.text = "Money: %s" % money
	_refresh_store()

func _refresh_store():
	tower_buy.disabled = true
	wall_buy.disabled = true
	ogre_buy.disabled = true
	orc_buy.disabled = true
	goblin_buy.disabled = true
	
	if money >= 1: wall_buy.disabled = false
	if money >= 2: goblin_buy.disabled = false
	if money >= 4: orc_buy.disabled = false
	if money >= 5: tower_buy.disabled = false
	if money >= 6: ogre_buy.disabled = false

func _choose(goblin):
	if goblin.loot.type == "nothing": return
	loot = goblin.loot
	choicelabel.text = "%s brought back a %s! \n What do you want to do with it?" % [goblin.nickname, goblin.loot.type]
	lootchoice.visible = true

func _get_closest_town(pos):
	var closest_town = towns.get_child(0)
	var distance = 90000
	for town in towns.get_children():
		var dist = pos.distance_to(town.position)
		if dist < distance: 
			closest_town = town
			distance = dist
	return closest_town

func _spawn_minion(type):
	var minion
	if type == "goblin":
		minion = load("res://entities/minions/goblin/goblin.tscn").instance()

	var card = load("res://entities/minions/minion_card.tscn").instance()
	minion.card_ref = weakref(card)
	minion.position = castle.position
	
	minions.add_child(minion)
	card.init(minion)
	hud.add_child(card)
	
	minion.connect("arrived", self, "_on_minion_arrived")
	card.connect("clicked", self, "_on_minion_card_clicked")

func _you_lose():
	util.quit(get_tree())

func _process(delta):
	var dragon = util.get_ref(monster_ref)
	health.value = dragon.health
	hunger.value = dragon.hunger
	if hunger.value <= 0: dragon.health -= delta
	
	if health.value <= 0:
		_you_lose()
#
#	if Input.is_action_pressed("ui_down") or get_viewport().get_mouse_position().y > get_viewport().size.y - edge_threshold:
#		camera.offset_v += cam_pan_speed * delta
#	if Input.is_action_pressed("ui_up") or get_viewport().get_mouse_position().y < edge_threshold:
#		camera.offset_v -= cam_pan_speed * delta
#	if Input.is_action_pressed("ui_left") or get_viewport().get_mouse_position().x < edge_threshold:
#		camera.offset_h -= cam_pan_speed * delta
#	if Input.is_action_pressed("ui_right") or get_viewport().get_mouse_position().x > get_viewport().size.x - edge_threshold:
#		camera.offset_h += cam_pan_speed * delta

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.is_pressed():
			var closest_town = _get_closest_town(event.position)
			for m in selected_minions:
				var path = $nav.get_a_path(m.position, closest_town.position)
				if !path or path.size() == 0: return
				path.remove(0) # remove starting node
				m.path = path
				var card = util.get_ref(m.card_ref)
				card.clear_selection()
			selected_minions = []
#		elif event.button_index == BUTTON_WHEEL_DOWN:
#			camera.zoom *= 1.1
#		elif event.button_index == BUTTON_WHEEL_UP:
#			camera.zoom *= 0.9

func _ready():
	OS.low_processor_usage_mode = true
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	lootchoice.visible = false
	_update_money(5)
	

func _on_minion_arrived(minion, target_pos):
	var town = _get_closest_town(target_pos)
	if minion.position.distance_to(castle.position) < 5:
		print("%s made it home" % minion.nickname)
		if minion.loot.type != "nothing":
			_choose(minion)
			minion.levelup()
			
	else:
		var minion_name = minion.nickname
		print("%s arrived at %s" % [minion_name, target_pos])
		var loot_type = town._raid(minion)
		if !loot_type == "death":
			print("%s stole a %s!" % [minion_name, loot_type])
			minion.path = $nav.get_a_path(minion.position, castle.position)
		else: print("%s died!" % minion_name)

func _on_minion_card_clicked(card):
	var minion = util.get_ref(card.minion_ref)
	if minion and !selected_minions.has(minion): 
		selected_minions.append(minion)
		card.get("custom_styles/panel").set("border_color", Color.white)
	print("minions: %s" % util.join(selected_minions, ","))


func _on_feed_pressed():
	var monster = util.get_ref(monster_ref)
	monster.eat(loot)
	loot = null
	lootchoice.visible = false


func _on_sacrifice_pressed():
	_update_money(money + loot.power)
	loot = null
	lootchoice.visible = false


func _on_goblin_buy_pressed():
	_update_money(money - 2)
	_spawn_minion("goblin")
