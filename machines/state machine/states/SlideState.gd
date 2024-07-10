extends State

@onready var nav_machine: NavigationMachine = get_parent().nav_machine
@onready var tile_map: TileMap = get_node("/root/Main/%tile_map")

@export var idle_state: State

func _on_enter():
	super()
	
func _on_exit():
	# set next_state to idle-state
	next_state = idle_state
	
func _update_physics(current_direction: Vector2i, next_direction: Vector2i, current_path: Array[Vector2i]):
	# update target_position
	var parent_coord = tile_map.local_to_map(parent.global_position)
	var tile_pos = tile_map.map_to_local(parent_coord)
	nav_machine._update_target(tile_pos.x + current_direction.x * 10, [])
	
	if SPEED == FAST_SPEED:
		print("slide")
		# adjust horizontal velocity
		parent.velocity.x = current_direction.x * SPEED / 12
