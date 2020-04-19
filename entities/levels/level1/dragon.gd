extends Sprite

export var favorite_snack = "princess"

var health_max = 100
var health = 20

var hunger_max = 100
var hunger = 100
var hunger_modifier = 5

func eat(treat):
	var satisfaction = hunger_modifier * treat.power
	if treat.type == favorite_snack:
		satisfaction *= 1.5
	
	if hunger > hunger_max - satisfaction: hunger = hunger_max
	else: hunger += satisfaction
	
	if treat.type == favorite_snack:
		if health > health_max - satisfaction: health = health_max
		else: health += satisfaction


func _process(delta):
	hunger -= delta
