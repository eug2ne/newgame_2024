extends TileMap

var astar: AStarGrid2D = AStarGrid2D.new()
var zero: Vector2i = Vector2(22,25)
var current_path: Array[Vector2i]

# TODO: create icon on scene
# TODO: create icon script (on click add tile to navigation layer)

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
				astar.set_point_solid(coord)
