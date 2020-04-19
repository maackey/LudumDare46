extends Sprite

var pop = 15
var loot_time = 6
var loot = {
	"princess": {"power": 10, "chance": 0, "type": "princess"},
	"hero":     {"power": 8, "chance": 1, "type": "hero"},
	"villager": {"power": 4, "chance": 3, "type": "villager"},
	"cow":      {"power": 3, "chance": 5, "type": "cow"},
	"pig":      {"power": 2, "chance": 3, "type": "pig"},
	"sheep":    {"power": 2, "chance": 3, "type": "sheep"},
	"chicken":  {"power": 1, "chance": 2, "type": "chicken"},
	"fish":     {"power": 1, "chance": 1, "type": "fish"},
	"rat":      {"power": 1, "chance": 2, "type": "rat"},
	"nothing":  {"power": 0, "chance": 1, "type": "nothing"},
}
