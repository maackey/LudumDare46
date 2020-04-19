extends PanelContainer

var power
var image
var nickname
var minion_ref
var border_color

signal clicked

func init(minion):
	power = minion.power
	image = minion.texture
	nickname = minion.nickname
	minion_ref = weakref(minion)

func set_power(value, xp):
	power = value
	$v/power_level.text = str(value)
	$v/xp.value = xp

func clear_selection():
	get("custom_styles/panel").set("border_color", border_color)

func _ready():
	$v/power_level.text = str(power)
	$v/nickname.text = nickname
	$v/image.texture = image
	$v/xp.max_value = power
	$v/xp.value = 0
	set("custom_styles/panel", get("custom_styles/panel").duplicate())
	border_color = get("custom_styles/panel").get("border_color")


func _on_minion_card_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		emit_signal("clicked", self)
