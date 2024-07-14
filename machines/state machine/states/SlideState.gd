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
	nav_machine._update_target(tile_pos + Vector2(current_direction.x * 10, 0), [])
	
	# adjust horizontal velocity
	parent.velocity.x = current_direction.x * SPEED / 12


func _on_animation_finished(anim_name):
	if anim_name == anim_key:
		# exit slide-state
		emit_signal("Transition")
