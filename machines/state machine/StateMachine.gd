extends Node
class_name StateMachine

@onready var label: Label = $Label

var states: Dictionary
@export var current_state: State

var tile_map: TileMap
@export var character: CharacterBody2D

var current_path: Array[Vector2i]
var current_direction: Vector2i
var next_direction: Vector2i

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			# assign state variable
			child.character = character
			child.anim = character.get_node("AnimationPlayer")
		else:
			push_warning("WARNING: " + child.name + " is not State.")
			
func _process(_delta):
	if current_path.is_empty() && current_state.name != "Roll":
		if is_on_edge():
			# slide state
			print("slide state")
		else:
			# idle state
			_set_current_state("Idle")
		return
	
	var current_tile_coord = tile_map.local_to_map(character.global_position)
	if current_tile_coord == current_path.front():
		current_path.pop_front()
		
		if current_path.is_empty():
			return
	
	# get current_direction + next_direction
	current_direction = current_path.front() - current_tile_coord
	if current_path.size() > 1:
		next_direction = current_path[1] - current_tile_coord
	else:
		next_direction = current_direction
		
	# flip character direction
	if current_direction.x < 0:
		character.get_node("AnimatedSprite2D").flip_h = true
	else:
		character.get_node("AnimatedSprite2D").flip_h = false
	
	# set state according to current_direction + next_direction
	if current_direction.y == 0 && next_direction.x * next_direction.y < 0:
		print("move-up state")
	elif current_direction.y == 0 && next_direction.x * next_direction.y > 0:
		print("move-down state")
	elif current_direction.y == 0 && next_direction.x == 0 && next_direction.y != 0:
		print("climb up/down start state")
	elif current_direction.x == 0 && next_direction.x == 0 && current_direction.x * next_direction.x != 0:
		print("climb up/down")
	else:
		print("default move")
		
func _physics_process(_delta):
	current_state._physics_process(_delta)
	
func _set_current_state(state_key: String):
	# exit current state
	if current_state != null:
		current_state._on_exit()
	# assign new state
	if current_state == null || current_state.name != state_key:
		current_state = states[state_key]
		current_state._on_enter()
	
func _get_current_state():
	return current_state
	
func is_on_edge():
	# detect player on edge
	var character_coord = tile_map.local_to_map(character.global_position)
	var tile_coord = Vector2i(character_coord.x, character_coord.y+1)
	var is_edge = false
	if tile_map.get_cell_tile_data(0, tile_coord):
		is_edge = tile_map.get_cell_tile_data(0, tile_coord).get_custom_data("edge")
	var tile_pos = tile_map.map_to_local(tile_coord)
	
	if is_edge:
		var e_direction = tile_map.get_cell_tile_data(0, tile_coord).get_custom_data("e_direction")
		return e_direction * (character.global_position.x - tile_pos.x) > 0
	
	return false
