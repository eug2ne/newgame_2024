extends TileMap

@onready var icons = get_tree().get_nodes_in_group("Icons")
var astar: AStarGrid2D = AStarGrid2D.new()
var zero: Vector2i = Vector2(22,25)
var current_coord: Vector2
var current_path: Array[Vector2i]

var target_pos: Vector2:
	set = _set_target_pos,
	get = _get_target_pos
var target_coord: Vector2i:
	set = _set_target_coord,
	get = _get_target_coord

func _ready():
	# register navigation area
	var tilemap_size = get_used_rect().end - get_used_rect().position
	var tilemap_rect = Rect2i(Vector2i.ZERO, tilemap_size)
	var tile_size = tile_set.tile_size
	
	astar.region = tilemap_rect
	astar.cell_size = tile_size
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar.update()
	
	for x in tilemap_size.x:
		for y in tilemap_size.y:
			var coord = Vector2i(x,y)
			var tile_navigatable = get_cell_tile_data(1, coord) # get navigation layer tile
			if !tile_navigatable:
				# disable path-finding
				astar.set_point_solid(coord)

# setter, getter
func _set_target_pos(click_pos: Vector2) -> void:
	target_pos = click_pos
	
func _get_target_pos() -> Vector2:
	return target_pos

func _set_target_coord(click_coord: Vector2i) -> void:
	# convert target_coord to naivgation-tile coord
	if get_cell_tile_data(0, click_coord).get_collision_polygons_count(0) == 1:
		# click on background tile
		click_coord.y -= 1
		target_coord = click_coord
		return
	
	
	# check icon click
	var icon = check_icon_click()
	var search_tiles = [
		click_coord,
		Vector2i(click_coord.x-1, click_coord.y),
		Vector2i(click_coord.x+1, click_coord.y)
	]
	# search closest navigation-tile
	var tile_navigatable = search_tiles.any(func(coord): return get_cell_tile_data(1, coord))
	while !tile_navigatable:
		if icon:
			if current_coord.y > click_coord.y:
				# player move up
				click_coord.y -= 1
			else:
				# player move down
				click_coord.y += 1
		else:
			click_coord.y += 1
		
		search_tiles = [
			click_coord,
			Vector2i(click_coord.x-1, click_coord.y),
			Vector2i(click_coord.x+1, click_coord.y)
		] # update search-tiles
		tile_navigatable = search_tiles.any(func(coord): return get_cell_tile_data(1, coord))
		
	search_tiles = search_tiles.filter(func(coord): return get_cell_tile_data(1, coord))
	click_coord = search_tiles[0]
	
	if icon:
		if current_coord.y > click_coord.y:
			# player move up
			click_coord += icon.destination_up
		else:
			# player move down
			click_coord += icon.destination_down
			
		# update target_pos
		var click_pos_update = map_to_local(click_coord)
		_set_target_pos(click_pos_update)
	
	target_coord = click_coord
	
func _get_target_coord() -> Vector2i:
	return target_coord

# internally called functions
func update_astar(navigatable: bool, player_pos: Vector2):
	var tilemap_size = get_used_rect().end - get_used_rect().position
	for x in tilemap_size.x:
		for y in tilemap_size.y:
			var coord = Vector2i(x,y)
			if navigatable:
				# enable path-finding on navigatable cells
				if get_cell_tile_data(2, coord):
					astar.set_point_solid(coord, false)
			
			else:
				# disable path-finding on navigatable cells
				if get_cell_tile_data(2, coord) and not get_cell_tile_data(1, coord):
					# disable navigatable cells exclusively
					astar.set_point_solid(coord)
				
				# switch icon image according to player_pos
				get_tree().call_group("Icons", "switch_image", player_pos)

func check_icon_click():
	for i in icons:
		# check click_pos within icon area
		if i.in_area:
			return i
			
	return false

# externally called functions
func _pos_accessible(click_pos) -> bool:
	# check accessibility of position
	var click_coord = local_to_map(click_pos)
	var accessible = astar.is_in_bounds(click_coord.x, click_coord.y)
	
	return accessible

func _get_current_path(current_pos, click_pos) -> Array[Vector2i]:
	current_coord = local_to_map(current_pos)
	var click_coord = local_to_map(click_pos)
	# set target_pos to click_pos
	_set_target_pos(click_pos)
	
	# convert click_pos to closest navigation-tile position
	_set_target_coord(click_coord)
	target_coord = _get_target_coord()
	
	if target_coord.y != current_coord.y:
		# update navigation map
		update_astar(true, current_coord)
	
	
	var nav_pos = map_to_local(target_coord)
	var path = astar.get_id_path(
			local_to_map(current_pos),
			local_to_map(nav_pos)
		).slice(1)
	if path.is_empty():
		# update navigation map
		update_astar(true, current_coord)
		path = astar.get_id_path(
			local_to_map(current_pos),
			local_to_map(nav_pos)
		).slice(1)
		
	return path
