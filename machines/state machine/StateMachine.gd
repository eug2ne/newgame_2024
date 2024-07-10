extends Node
class_name StateMachine

@onready var label: Label = $Label
@export var nav_machine: NavigationMachine

var states: Dictionary = {}
@export var current_state: State

# imported from parent
var tile_map: TileMap
@export var parent: CharacterBody2D

var current_direction: Vector2i
var next_direction: Vector2i

const DEFAULT_SPEED = 130
const FAST_SPEED = 180
const ROLL_DISTANCE = 90
const JUMP_VELOCITY = -300

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			# assign state variable
			child.parent = parent
			child.anim = parent.get_node("AnimationPlayer")
		else:
			push_warning("WARNING: " + child.name + " is not State.")
	
	if current_state:
		current_state._on_enter()
		
func _input(event):
	#if event.is_action_pressed("ui_mouseclick_left"):
		#current_state.SPEED = current_state.DEFAULT_SPEED
		#if event.double_click:
			#current_state.SPEED = current_state.FAST_SPEED
	if current_state:
		current_state._update_input(event)
	
func _process(_delta):
	# DEBUG
	label.text = "State: " + current_state.name

func _physics_process(_delta):
	current_direction = nav_machine.current_direction
	next_direction = nav_machine.next_direction
	
	if current_state:
		current_state._update_physics(current_direction, next_direction, nav_machine.current_path)
	
func _set_current_state(state_key: String = ""):
	# prevent redundancy
	if current_state.name == state_key:
		return
	
	print("state change")
	# exit current_state
	current_state._on_exit()
	
	# get new_state
	var new_state: State
	if state_key:
		new_state = states.get(state_key)
	else:
		new_state = current_state.next_state
	print(current_state.name, " ", new_state.name)
	
	# assign new state
	current_state = new_state
	current_state._on_enter()
	
func _get_current_state():
	return current_state
