extends CharacterBody2D

@onready var speech_bubble: MarginContainer = $SpeechBubble
@onready var tile_map: TileMap = get_node("%tile_map")

@onready var state_machine: StateMachine = $StateMachine
@onready var nav_machine: NavigationMachine = $NavigationMachine

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
const ROLL_DISTANCE = 90

func _ready():
	# assign tile_map to state-machine, nav_machine
	state_machine.tile_map = tile_map
	state_machine.nav_machine = nav_machine
	nav_machine.tile_map = tile_map
	
	floor_constant_speed = true # movement speed constant on slopes
	nav_machine._reset_target_position() # reset target_position
	
func _input(event):
	if event.is_action_pressed("ui_mouseclick_left"):
		# get global mouse_click position
		var mouse_pos = get_global_mouse_position()
		# check mouse_pos accessibility
		var accessible = tile_map._pos_accessible(mouse_pos)
		if not accessible:
			# show speech bubble
			_show_speech_bubble("I can't go into unknown territory.")
			return
		
		# get path to mouse_pos
		var player_path = tile_map._get_current_path(global_position, mouse_pos)
		print(player_path)
		
		if player_path.is_empty():
			# show speech bubble
			_show_speech_bubble("There is no way to get there.")
			return
		
		# update player target_position, path
		nav_machine._update_target(tile_map._get_target_pos(), player_path)
		# set player state
		state_machine._set_current_state("Move")
		
	if event.is_action_pressed("ui_mouseclick_right"):
		# get mouse_click direction
		var mouse_pos = get_local_mouse_position()
		var directionX = mouse_pos.x / abs(mouse_pos.x)
		var roll_target_position = global_position + Vector2(directionX * ROLL_DISTANCE, 0)
		
		# update player target_position, paths
		nav_machine._update_target(roll_target_position, [])
		# set player state
		state_machine._set_current_state("Roll")

func _physics_process(_delta):
	# adjust player sprite direction
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		
	move_and_slide()

# externally called functions
func _show_speech_bubble(display_text):
	speech_bubble._display_text(display_text)
