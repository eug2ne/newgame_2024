extends State

@onready var tile_map: TileMap = get_node("/root/Main/%tile_map")

@export var move_state: State

func _on_enter():
	super()
	# align parent position with tile
	var parent_coord = tile_map.local_to_map(parent.global_position)
	var tile_pos = tile_map.map_to_local(parent_coord)
	
	parent.global_position.x = tile_pos.x
	
func _on_exit():
	next_state = move_state
	
func _update_physics(current_direction: Vector2i, next_direction: Vector2i, current_path: Array[Vector2i]):
	if current_direction.x != 0:
		# exit climb-state
		emit_signal("Transition")
	else:
		parent.velocity = current_direction * SPEED
