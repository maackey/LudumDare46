extends Sprite

var nickname
var power = 2
var xp = 0
var base_speed = 80
var looting = 0
var loot = null
var target = null
var path = null
var card_ref = null

var names = [
	"giblet",
	"gibbon",
	"buffoo",
	"bufoon",
	"tosspot",
	"pisspot",
	"pot",
	"potty",
	"pant drip",
	"stain",
	"rotgut",
	"rot-face",
	"pimplerot",
	"wartroot",
	"warthog",
	"snotrot",
	"sir garbage",
	"gobbage",
	"gobbo",
	"sir stinky",
	"pug",
	"barf-face",
	"ugly",
	"warty",
	"gren",
	"snotface",
	"farty",
	"fartbag",
	"mc. fart",
	"sir fart",
	"fart-face",
	"gobble",
	"ug",
	"stink nug",
	"phlegm",
	"yo momma",
	"fatty",
	"pimple",
	"pus bag",
	"snot rag",
	"goop",
	"goopy",
	"leaky",
	"stank",
	"stanky",
	"janky",
	"mc. stank",
	"sir stank"
]

signal arrived

func levelup():
	loot = null
	
	xp += 1
	if xp >= power:
		power += 1
		xp = 0
	
	var card = util.get_ref(card_ref)
	card.set_power(power, xp)

func die():
	var card = util.get_ref(card_ref)
	card.queue_free()
	print("ack! I'm dead!")
	queue_free()

func _ready():
	nickname = "%s" % [names[rand_range(0, names.size() - 1)]]
	for n in get_parent().get_children():
		if n != self and n.nickname == nickname:
			nickname = "%s II"
	
	var r = rand_range(0, 1)
	if r > 0.5: texture = preload("res://entities/minions/goblin/goblin_64.png")
	else: texture = preload("res://entities/minions/goblin/goblin2_64.png")

func _process(delta):
	if looting > 0: 
		looting -= power * delta
		return
	
	if !path or path.size() == 0: 
		return
	
	var destination = path[0]
	
	var velocity = (destination - position).normalized() * (base_speed + power)
	position += velocity * delta
	
	if position.distance_to(destination) < 1:
#		print("close enough: %s - %s" % [position, destination])
		path.remove(0)
		if path.size() == 0:
			position = destination
			emit_signal("arrived", self, destination)
