extends Node
class_name NavigationMachine

# imported from parent
var tile_map: TileMap
@export var parent: CharacterBody2D

var target_position: Vector2
var current_path: Array[Vector2i]
var current_direction: Vector2
var next_direction: Vector2

func _process(_delta):
	if current_path.is_empty():
		if target_position == parent.global_position:
			return
		
		if abs(target_position.x - parent.global_position.x) < 3:
			# end navigation
			# reset target_position
			_reset_target_position()
			# reset tile_map navigation + update map icon
			tile_map.update_astar(false, parent.global_position)
		else:
			# set current_direction
			current_direction = Vector2((target_position.x - parent.global_position.x) / abs(target_position.x - parent.global_position.x), 0)
		
		return
	
	var current_tile_coord: Vector2i = tile_map.local_to_map(parent.global_position)
	# update current_path
	if current_tile_coord == current_path.front():
		current_path.pop_front()
		
	# get current_direction
	if current_path.front():
		current_direction = current_path.front() - current_tile_coord
		
	# get next_direction
	if current_path.size() > 1:
		next_direction = current_path[1] - current_path.front()
	else:
		next_direction = Vector2(0,0)
	
func _update_target(new_target_position: Vector2, new_path: Array[Vector2i]):
	target_position = new_target_position
	current_path = new_path
	
func _reset_target_position():
	target_position = parent.global_position
	current_direction = Vector2(0,0)
	
func _follow_path():
	pass
