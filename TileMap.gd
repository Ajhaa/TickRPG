extends TileMap


## Variables to be set when the node is ready


# Reference to a new AStar navigation grid node
onready var astar = AStar.new()

# Used to find the centre of a tile
onready var half_cell_size = cell_size / 2

# All tiles that can be used for pathfinding
onready var traversable_tiles = get_used_cells()

# The bounds of the rectangle containing all used tiles on this tilemap
onready var used_rect = get_used_rect()

var minim = Vector2(10000, 10000)
var maxim = Vector2(0, 0)


func _ready():

	# This would hide the navigation_map upon loading, but we'll keep
	# it commented for this demo - uncomment for your game, most likely
	# visible = false

	# Add all tiles to the navigation grid
	_add_traversable_tiles(traversable_tiles)

	# Connects all added tiles
	_connect_traversable_tiles(traversable_tiles)


## Private functions


# Adds tiles to the A* grid but does not connect them
# ie. They will exist on the grid, but you cannot find a path yet
func _add_traversable_tiles(traversable_tiles):
	# Loop over all tiles
	# print(used_rect.size)
	for tile in traversable_tiles:
		# print(tile)
		# Determine the ID of the tile
		var id = _get_id_for_point(tile)
		
		if tile.x > maxim.x:
			maxim.x = tile.x
		if tile.y > maxim.y:
			maxim.y = tile.y
		if tile.x < minim.x:
			minim.x = tile.x
		if tile.y < minim.y:
			minim.y = tile.y
		# Add the tile to the AStar navigation
		# NOTE: We use Vector3 as AStar is, internally, 3D. We just don't use Z.
		astar.add_point(id, Vector3(tile.x, tile.y, 0))


# Connects all tiles on the A* grid with their surrounding tiles
func _connect_traversable_tiles(traversable_tiles):
	# Loop over all tiles
	for tile in traversable_tiles:

		# Determine the ID of the tile
		var id = _get_id_for_point(tile)

		# Loops used to search around player (range(3) returns 0, 1, and 2)
		
		var l = [-1, 0, 1]
		
		for x in l:
			for y in l:
				if x != 0 && y != 0:
					if !check(tile, x, y):
						continue
				
				var target = tile + Vector2(x , y)
				if target.x < minim.x || target.x > maxim.x || target.y < minim.y || target.y > maxim.y:
					continue
				

				# Determines target ID
				var target_id = _get_id_for_point(target)
				# print(str(target) + " " + str(tile) + " " + str(target_id))

				# Do not connect if point is same or point does not exist on astar
				if tile == target or not astar.has_point(target_id):
					continue
				# Connect points
				astar.connect_points(id, target_id, false)

func check(tile, x, y):
	var st = astar.has_point(_get_id_for_point(tile + Vector2(x , 0)))
	var nd = astar.has_point(_get_id_for_point(tile + Vector2(0 , y)))
	return st && nd

# Determines a unique ID for a given point on the map
func _get_id_for_point(point):
	var x = point.x 
	var y = point.y

	# Returns the unique ID for the point on the map
	return x + y * used_rect.size.x


## Public functions

# Returns a path from start to end
# These are real positions, not cell coordinates
func get_path(start, end):

	# Convert positions to cell coordinates
	var start_tile = world_to_map(start)
	var end_tile = world_to_map(end)

	# Determines IDs
	var start_id = _get_id_for_point(start_tile)
	var end_id = _get_id_for_point(end_tile)

	# Return null if navigation is impossible
	#if not astar.has_point(start_id) or not astar.has_point(end_id):
		

	# Otherwise, find the map
	var path_map = astar.get_point_path(start_id, end_id)

	# Convert Vector3 array (remember, AStar is 3D) to real world points
	var path_world = []
	for point in path_map:
		var point_world = map_to_world(Vector2(point.x, point.y)) + half_cell_size
		path_world.append(point_world)
	return path_world