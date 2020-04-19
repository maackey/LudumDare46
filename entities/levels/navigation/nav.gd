extends TileMap

onready var astar = AStar.new()
onready var bounding_area = get_used_rect()
onready var path_ray = get_parent().find_node("path_ray")

func _ready():
	var all_cells = get_used_cells()
	var blocked_cells = get_used_cells_by_id(1) + get_used_cells_by_id(5)
	var open_cells = []
	for c in all_cells:
		if !blocked_cells.has(c): open_cells.append(c)
	
	_add_tiles(open_cells)

func _add_tiles(tiles):
	for tile in tiles:
		astar.add_point(_get_point_id(tile), Vector3(tile.x, tile.y, 0))
		
# 	Connects all tiles on the A* grid with their surrounding tiles
	for tile in tiles:
		var id = _get_point_id(tile)
		# Loops used to search around player (range(3) returns 0, 1, and 2)
		for x in range(3):
			for y in range(3):
				# Determines target, converting range variable to -1, 0, and 1
				var target = tile + Vector2(x - 1, y - 1)
				var target_id = _get_point_id(target)
				
				# Do not connect if point is same or point does not exist on astar
				if tile == target or not astar.has_point(target_id):
					continue
					
				astar.connect_points(id, target_id, true)

func _get_point_id(point):
	# Offset position of tile with the bounds of the tilemap
	# This prevents ID's of less than 0, if points are behind (0, 0)
	var x = point.x - bounding_area.position.x
	var y = point.y - bounding_area.position.y
	return x + y * bounding_area.size.x

func _clean_path(path):
	var start = path.front()
	var target = path.back()
	var clean_path = [start]
	var last_clear = start
	
	path_ray.enabled = true
	path_ray.position = start
	for p in path:
		path_ray.cast_to = p - path_ray.position
		if !path_ray.is_colliding():
			last_clear = p
		else:
			print("hit? %s -> %s (%s)" % [path_ray.position, p, path_ray.get_collider().name])
			clean_path.append(last_clear)
			path_ray.position = last_clear
	
	clean_path.append(target)
	print("cleaned path: %s" % util.join(clean_path, ", "))
	return clean_path

# Returns a path from start to end
# These are real positions, not cell coordinates
func get_a_path(start, end):

	# Convert positions to cell coordinates
	var start_tile = world_to_map(start)
	var end_tile = world_to_map(end)

	# Determines IDs
	var start_id = _get_point_id(start_tile)
	var end_id = _get_point_id(end_tile)

	# Return null if navigation is impossible
	if not astar.has_point(start_id) or not astar.has_point(end_id):
		return null

	# Otherwise, find the map
	var path_map = astar.get_point_path(start_id, end_id)

	# Convert path array to real world points
	var path_world = []
	for point in path_map:
		var point_world = map_to_world(Vector2(point.x, point.y)) + cell_size / 2
		path_world.append(point_world)
	
#	remove all the pointless nodes in between clear straight path
#	var cleaned_path = _clean_path(path_world)
	
	return path_world
