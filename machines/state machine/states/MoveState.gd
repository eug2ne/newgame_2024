extends State

@onready var tile_map: TileMap = get_node("/root/Main/%tile_map")

var current_path: Array[Vector2i]
var target_position: Vector2

#var slide_state: State = preload("res://machines/state machine/states/SlideState.gd")
#var idle_state: State = preload("res://machines/state machine/states/IdleState.gd")

func _on_enter():
	# reset current_path + target_position
	pass

func _on_exit():
	#if is_on_edge():
		## set next_state to slide-state
		#next_state = slide_state
	#else:
		## set next_state to idle-state
		#next_state = idle_state
	pass
	
func is_on_edge():
	# detect player on edge
	var player_coord = tile_map.local_to_map(character.global_position)
	var tile_coord = Vector2i(player_coord.x, player_coord.y+1)
	var is_edge = false
	if tile_map.get_cell_tile_data(0, tile_coord):
		is_edge = tile_map.get_cell_tile_data(0, tile_coord).get_custom_data("edge")
	var tile_pos = tile_map.map_to_local(tile_coord)
	
	if is_edge:
		var e_direction = tile_map.get_cell_tile_data(0, tile_coord).get_custom_data("e_direction")
		return e_direction * (character.global_position.x - tile_pos.x) > 0
	
	return false
