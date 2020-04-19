extends Sprite

var nickname = "PleasantVille"
var hardships = 0
var last_birth = 10
var birth_delay = 1
var loot_time = 2
var loot = {
	"princess": {"power": 10, "chance": 0, "type": "princess"},
	"hero":     {"power": 8, "chance": 0, "type": "hero"},
	"villager": {"power": 4, "chance": 1, "type": "villager"},
	"cow":      {"power": 3, "chance": 0, "type": "cow"},
	"pig":      {"power": 2, "chance": 2, "type": "pig"},
	"sheep":    {"power": 2, "chance": 2, "type": "sheep"},
	"chicken":  {"power": 1, "chance": 4, "type": "chicken"},
	"fish":     {"power": 1, "chance": 3, "type": "fish"},
	"rat":      {"power": 1, "chance": 1, "type": "rat"},
	"nothing":  {"power": 0, "chance": 2, "type": "nothing"},
}

func _raid(minion):
	print("%s is looting %s" % [minion.nickname, nickname])
	var loot_type = "nothing"
	minion.looting = loot_time
	hardships += 1
	
#	get max range of loot types
	var max_roll = 0
	for type in loot.keys():
		max_roll += loot[type].chance
	
#	get random item based on weights
	var loot_drop = rand_range(0, max_roll)
#	print("loot drop %s out of %s" % [loot_drop, max_roll])
	var loot_chance = 0
	for type in loot.keys():
		loot_chance += loot[type].chance
#		print("chance for %s: drop:%s agg:%s raw:%s" % [type, loot_drop, loot_chance, village.loot[type].chance])
		if loot_drop < loot_chance:
#			attempt to steal item from village
			var power = loot[type].power
			if minion.power > power:
				loot[type].chance -= 1 if type != "nothing" else 0
				loot_type = type
				minion.loot = loot[type]
				break
			elif minion.power == power:
				print("%s(%s) got away!" % [type, power])
				minion.loot = loot["nothing"]
				return loot_type
			else:
				print("%s(%s) found %s(%s) and killed it!" % [type, power, minion.nickname, minion.power])
				minion.die()
				return "death"
	
#	return selected item
	return loot_type

func _new_birth():
	last_birth = 0
	if hardships > 0: hardships -= 1
	
	var total = 0
	for l in loot:
		pass

func _process(delta):
	if last_birth >= birth_delay + hardships:
		_new_birth()
