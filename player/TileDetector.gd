extends Area2D
class_name TileDetector

signal _tile_entered(tile_type)

var current_tilemap: TileMap
var current_tile_type: int

func _process_tilemap_collision(body, body_rid):
	current_tilemap = body
	
	var current_tile_coord = current_tilemap.get_coords_for_body_rid(body_rid)
	
	for index in current_tilemap.get_layers_count():
		var tile_data = current_tilemap.get_cell_tile_data(index, current_tile_coord)
		if !tile_data is TileData:
			continue
		current_tile_type = tile_data.get_custom_data("animation_state") # animation_state layer
		emit_signal("_tile_entered", current_tile_type)
		break

func _on_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	if body is TileMap:
		_process_tilemap_collision(body, body_rid)
