class_name util

# bitmask for modifier keys
enum bitmod {
	alt = 1,
	shift = 2,
	control = 4,
	meta = 8
}

# objects
static func quit(tree):
#	TODO: save state
	print("exiting game")
	tree.quit()

static func save_keybinds(profile):
#	TODO: save temp bindings? or save backup on individual changes?
	profile.controls.clear()
	for action in InputMap.get_actions():
		if !profile.controls.has(action): 
			profile.controls[action] = {"keybinds": [], "mousebinds": [], "joypadbinds": [], "touchbinds": []}
		for event in InputMap.get_action_list(action):
			var modifier_mask = 0
			if event is InputEventWithModifiers:
				if event.alt: modifier_mask |= bitmod.alt
				if event.shift: modifier_mask |= bitmod.shift
				if event.control: modifier_mask |= bitmod.control
				if event.meta: modifier_mask |= bitmod.meta
				
			if event is InputEventKey:
				var iek = {"modifiers": modifier_mask, "scancode": event.scancode}
				profile.controls[action].keybinds.append(iek)
			elif event is InputEventMouseButton:
				var iebm = {"modifiers": modifier_mask, "button_index": event.button_index, "doubleclick": event.doubleclick}
				profile.controls[action].mousebinds.append(iebm)
			elif event is InputEventJoypadButton:
				var iejb = {"button_index": event.button_index}
				profile.controls[action].joypadbinds.append(iejb)

static func load_keybinds(profile):
#	clear out existing bindings
	for action in InputMap.get_actions():
		InputMap.action_erase_events(action)
		InputMap.erase_action(action)

#	load bindings from profile
	for action in profile.controls.keys():
#		add action if it doesn't exist
		if !InputMap.has_action(action): InputMap.add_action(action)
		
#		add events to action
		for bind in profile.controls[action].keybinds:
			var event = InputEventKey.new()
			event.scancode = bind.scancode
			event.alt = int(bind.modifiers) & bitmod.alt > 0
			event.shift = int(bind.modifiers) & bitmod.shift > 0
			event.control = int(bind.modifiers) & bitmod.control > 0
			event.meta = int(bind.modifiers) & bitmod.meta > 0
			InputMap.action_add_event(action, event)
		for bind in profile.controls[action].mousebinds:
			var event = InputEventMouseButton.new()
			event.button_index = bind.button_index
			event.doubleclick = bind.doubleclick
			event.alt = int(bind.modifiers) & bitmod.alt > 0
			event.shift = int(bind.modifiers) & bitmod.shift > 0
			event.control = int(bind.modifiers) & bitmod.control > 0
			event.meta = int(bind.modifiers) & bitmod.meta > 0
			InputMap.action_add_event(action, event)
		for bind in profile.controls[action].joypadbinds:
			var event = InputEventJoypadButton.new()
			event.button_index = bind.button_index
			InputMap.action_add_event(action, event)

static func save_config(config, path):
	print("saving file: %s" % [path])
#	print(config)
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_line(to_json(config))
	file.close()

static func load_config(path, plaintext = false):
	var file = File.new()
	var contents = ""
	if file.file_exists(path): 
		print("file exists: %s" % [path])
	elif file.file_exists("user://" + path):
		path = "user://" + path
		print("user file exists: %s" % [path])
	elif file.file_exists("res://" + path): 
		path = "res://" + path
		print("resource file exists: %s" % [path])
	else: 
		print("%s doesn't exist" % [path])
		return null

	var err = file.open(path, file.READ)
	if err != OK: 
		print("error loading %s: %s" % [path, err])
		return null
	else:
		print("loaded file: %s" % [file.get_path()])
		contents = file.get_as_text()
#		print(contents)
		file.close()
	
	if plaintext: return contents
	
	var parse = JSON.parse(contents)
	if parse.error != OK: 
		print("error loading config: ./%s\nerror: %s\nline: %s\nstring: %s" % 
		[path, parse.error, parse.error_line, parse.error_string])
	return parse.result

static func read_config(config, key, default = null):
	config[key] = config.get(key, default)
	return config[key]

static func get_ref(obj):
	if obj == null: 
		return null
	else:
		return obj.get_ref()

static func find_ref(ref, list):
	for r in list:
		if get_ref(r) == get_ref(ref):
			return get_ref(r)

static func find_ref_index(ref, list):
	var i = 0
	for r in list:
		if get_ref(r) == get_ref(ref):
			return i
		i += 1
	return -1

static func deep_copy(obj):
	var copy = {}
	for v in obj:
		copy[v] = obj[v]
	return copy

# strings
static func join(array, separator = ""):
	var s = ""
	for c in array:
		s += str(c) + separator
	return s.rstrip(separator)

static func decimal_binary(number, width = 4):
	var b = ""
	var c = 0
	while (pow(2, c) <= number):
		b = ("1" if 1 & number >> c else "0") + b
		c += 1
	var padding = max(width - b.length(), 0)
	for _i in range(padding):
		b = "0" + b
#	print("b: %s, num: %d, c: %d, w: %d, c&n: %s" % [b, number, c, width, c & number])
	return b

static func binary_decimal(binary_string):
	var d = 0
	var i = binary_string.length() - 1
	for c in binary_string:
		if c == "1":
			d += pow(2, i)
		i -= 1
	return d

# numbers
# isn't this the same as lerp?
static func attract(value: float, target: float, delta: float):
	if value - delta >= target:
		value -= delta
	elif value + delta <= target:
		value += delta
	else:
		value = target
	return value

static func attract2D(value: Vector2, target: Vector2, delta: float):
	var a = Vector2()
	a.x = attract(value.x, target.x, delta)
	a.y = attract(value.y, target.y, delta)
	return a

static func attract3D(value: Vector3, target: Vector3, delta: float):
	var a = Vector3()
	a.x = attract(value.x, target.x, delta)
	a.y = attract(value.y, target.y, delta)
	a.z = attract(value.z, target.z, delta)
	return a

static func normalize(value, min_val, max_val):
	if max_val == min_val:
		return 0
		
	var ratio = (value - min_val) / (max_val - min_val)
	return ratio

static func rand_vector3(size : float, normal : Vector3 = Vector3.ZERO):
#	print("rand vec 3: size: %s, norm: %s" % [size, normal])
	return Vector3(
		rand_vec(size, normal.x), 
		rand_vec(size, normal.y), 
		rand_vec(size, normal.z))

static func rand_vector2(size : float, normal : Vector2 = Vector2.ZERO):
	return Vector2(
		rand_vec(size, normal.x), 
		rand_vec(size, normal.y))

static func rand_vec(size : float, normal : float = 0):
#	print("rand vec: size: %s, norm: %s" % [size, normal])
	return rand_range(-size, size) if abs(normal) != 1.0 else 0.0


static func get_input_dir():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		).clamped(1.0)

static func get_global_dir(local_dir, basis):
	return local_dir.x * basis.x + local_dir.y * basis.y + local_dir.z * basis.z

static func get_angle2D(a : Vector2, b : Vector2):
	return atan2(b.y, b.x) - atan2(a.y, a.x)

static func get_angle3D(a : Vector3, b : Vector3):
	return atan2(b.z, b.x) - atan2(a.z, a.x)

# shapes


