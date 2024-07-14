extends State

@onready var tile_map: TileMap = get_node("/root/Main/%tile_map")

var fast: bool = false
@export var fast_anim_key: String

@export var idle_state: State
@export var climb_state: State
@export var slide_state: State
@export var roll_state: State

func _on_enter():
	if SPEED == DEFAULT_SPEED:
		anim.play(anim_key)
	else:
		anim.play(fast_anim_key)
	# set default next_state
	next_state = idle_state

func _on_exit():
	if next_state:
		if next_state == climb_state:
			# do not reset speed
			return
	else:
		push_warning("WARNING: next_state not defined after move-state.")
		# set next_state to idle-state
		next_state = idle_state
	
	# reset speed
	SPEED = DEFAULT_SPEED
	
func _update_input(event):
	if event.is_action_pressed("ui_mouseclick_left"):
		if event.double_click:
			# handle double-click event
			SPEED = FAST_SPEED
			anim.play(fast_anim_key)
		else:
			# new target-position
			# reset speed + anim
			SPEED = DEFAULT_SPEED
			anim.play(anim_key)
	
func _update_physics(current_direction: Vector2i, next_direction: Vector2i, current_path: Array[Vector2i]):
	if current_direction == Vector2i(0,0) && next_direction == Vector2i(0,0):
		if !current_path.is_empty():
			# wait for nav_machine.process sync
			return
		
		# exit move-state
		emit_signal("Transition")
		return
	
	if current_direction.x == 0 && next_direction.x == 0 && current_direction.y * next_direction.y > 0:
		# climb up/down
		# set next_state to climb-state
		next_state = climb_state
		# exit move-state
		emit_signal("Transition")
	elif current_path.is_empty() && is_on_edge():
		if SPEED == FAST_SPEED:
			# slide
			# set next_state to slide-state
			next_state = slide_state
			# exit move-state
			emit_signal("Transition")
	else:
		# default move
		parent.velocity = current_direction * SPEED
		
		if !parent.is_on_floor() && parent.velocity.y >= 0:
			# apply gravity
			parent.velocity.y = GRAVITY
	
func is_on_edge():
	# detect player on edge
	var parent_coord = tile_map.local_to_map(parent.global_position)
	var tile_coord = Vector2i(parent_coord.x, parent_coord.y+1)
	
	var is_edge = false
	if tile_map.get_cell_tile_data(0, tile_coord):
		is_edge = tile_map.get_cell_tile_data(0, tile_coord).get_custom_data("edge")
	var tile_pos = tile_map.map_to_local(tile_coord)
	
	if is_edge:
		var e_direction = tile_map.get_cell_tile_data(0, tile_coord).get_custom_data("e_direction")
		return e_direction * (parent.global_position.x - tile_pos.x) < 0
	
	return false
