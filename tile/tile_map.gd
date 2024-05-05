extends TileMap

@onready var icons = get_tree().get_nodes_in_group("Icons")
var astar: AStarGrid2D = AStarGrid2D.new()
var zero: Vector2i = Vector2(22,25)
var current_path: Array[Vector2i]

func _ready():
	# disable physics on navigation layer
	
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
					
				# TODO: update icon image
				# switch icon image according to player_pos
				get_tree().call_group("Icons", "switch_image", player_pos)

func check_icon_click(click_pos):
	for i in icons:
		# check click_pos within icon area
		if i.in_area:
			return true
			
	return false

# externally called functions
func _get_current_path(current_pos, target_pos) -> Array[Vector2i]:
	var current_coord = local_to_map(current_pos)
	var target_coord = local_to_map(target_pos)
	
	# check icon click
	var icon_click = check_icon_click(target_pos)
	# convert target_pos to closest navigation-tile position
	var tile_navigatable = get_cell_tile_data(1, target_coord)
	while !tile_navigatable:
		if icon_click:
			if current_coord.y > target_coord.y:
				# player move up
				target_coord.y -= 1
			else:
				# player move down
				target_coord.y += 1
		else:
			target_coord.y += 1
		tile_navigatable = get_cell_tile_data(1, target_coord)
		
	if target_coord.y != current_coord.y:
		# update navigation map
		update_astar(true, current_coord)
		
		# convert target_pos to closest navigation-tile position
		tile_navigatable = get_cell_tile_data(1, target_coord)
		while !tile_navigatable:
			if target_pos.y < current_pos.y:
				# player moving up
				target_coord.y -= 1
			else:
				# player moving down
				target_coord.y += 1
			tile_navigatable = get_cell_tile_data(1, target_coord)
	
	
	var nav_pos = map_to_local(target_coord)
	var path = astar.get_id_path(
			local_to_map(current_pos),
			local_to_map(nav_pos)
		).slice(1)
		
	return path
