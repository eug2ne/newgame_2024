extends CharacterBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var hit_area: CollisionShape2D = $PlayerHitArea
@onready var speech_bubble: MarginContainer = $SpeechBubble
@onready var timer: Timer = $Timer
@onready var tile_map: TileMap = get_node("%tile_map")

@onready var state_machine: StateMachine = $StateMachine

var target_position: Vector2
var directionX: int
var current_path: Array[Vector2i] = []

var STATE: Dictionary = {
	"roll": false,
	"move_up": false,
	"move_down": false,
	"climb_up": false,
	"climb_down": false
}

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var SPEED = 100


const DEFAULT_SPEED = 130
const FAST_SPEED = 180
const ROLL_DISTANCE = 90
const JUMP_VELOCITY = -300

func _ready():
	# assign tile_map to state-machine
	state_machine.tile_map = tile_map
	
	floor_constant_speed = true # movement speed constant on slopes
	target_position = global_position # reset target_position
	anim.play("idle")
	
func _input(event):
	if event.is_action_pressed("ui_mouseclick_left"):
		# set movement speed
		SPEED = DEFAULT_SPEED
		if event.double_click:
			# TODO: add cool time to mouse-click-left to prevent run disabling run state accidentally
			SPEED = FAST_SPEED # fast speed

	if event.is_action_pressed("ui_mouseclick_right"):
		# set roll speed + direction
		directionX = (get_global_mouse_position().x - global_position.x) / abs(get_global_mouse_position().x - global_position.x)
		target_position.x += directionX * ROLL_DISTANCE
		SPEED = DEFAULT_SPEED
		hit_area.disabled = true # disable hit-area during roll
		
		# flip player direction
		if directionX < 0:
			get_node("AnimatedSprite2D").flip_h = true
		else:
			get_node("AnimatedSprite2D").flip_h = false
		
		# start roll
		STATE.roll = true
		anim.play("roll")
		timer.start(0.9)

func _physics_process(_delta):
	var current_tile_coord = tile_map.local_to_map(global_position)
	
	if current_path.is_empty():
		if not is_on_floor():
			# apply gravity
			velocity.y = GRAVITY
			
		directionX = (target_position.x - global_position.x) / abs(target_position.x - global_position.x)
		if STATE.roll:
			# player roll
			velocity.x = directionX * SPEED
		elif is_on_edge():
			print(directionX)
			# enter edge tile
			# update target_position
			var player_coord = tile_map.local_to_map(global_position)
			var tile_pos = tile_map.map_to_local(player_coord)
			target_position.x = tile_pos.x + directionX * 10
			
			if SPEED == FAST_SPEED:
				# adjust horizontal velocity
				velocity.x = directionX * SPEED / 12
				# play slide animation
				anim.play("slide")
			
		move_and_slide()
		
		if target_position.x - global_position.x < 3:
			tile_map.update_astar(false, global_position) # reset tile_map navigation + update map icon
			velocity = Vector2(0,0) # reset velocity
			hit_area.disabled = false # reset hit-area
			anim.play("idle")
			
		return
	
	if current_tile_coord == current_path.front():
		current_path.pop_front()
		
		if current_path.is_empty():
			return
	
	var next_direction = current_path.front() - current_tile_coord

	# flip player direction
	if next_direction.x < 0:
		get_node("AnimatedSprite2D").flip_h = true
	else:
		get_node("AnimatedSprite2D").flip_h = false
	
	# adjust velocity.x
	if next_direction.y > 0 and next_direction.x != 0:
		velocity.x = next_direction.x * SPEED
		STATE.move_down = true
	elif next_direction.y > 0 and STATE.move_down:
		# down fall >> gradually decline velocity.x
		if velocity.x == 0:
			# velocity.x reach 0
			pass
		else:
			velocity.x -= next_direction.x * SPEED / 8
	
	else:
		velocity.x = next_direction.x * SPEED
		STATE.move_up = false # set state to default
	# adjust velocity.y >> apply gravity + jump velocity
	if next_direction.y < 0:
		# apply jump velocity
		velocity.y = JUMP_VELOCITY
		STATE.move_up = true # set state to move_up
	elif next_direction.y == 0 and STATE.move_up:
		# jump mid-air
		velocity.y -= JUMP_VELOCITY / 10 # gradually decline jump velocity
	
	else:
		# apply gravity
		velocity.y = GRAVITY
		STATE.move_up = false # set state to default

	# apply player animation
	if velocity.y != 0 && velocity.x == 0:
		anim.play("climb")
	elif SPEED == FAST_SPEED:
		anim.play("run")
	else:
		anim.play("walk")
	
	move_and_slide()
	
# internally called functions
func is_on_edge():
	# detect player on edge
	var player_coord = tile_map.local_to_map(global_position)
	var tile_coord = Vector2i(player_coord.x, player_coord.y+1)
	var is_edge = false
	if tile_map.get_cell_tile_data(0, tile_coord):
		is_edge = tile_map.get_cell_tile_data(0, tile_coord).get_custom_data("edge")
	var tile_pos = tile_map.map_to_local(tile_coord)
	
	if is_edge:
		var e_direction = tile_map.get_cell_tile_data(0, tile_coord).get_custom_data("e_direction")
		return e_direction * (global_position.x - tile_pos.x) > 0
	
	return false

# externally called functions
func _show_speech_bubble(display_text):
	speech_bubble._display_text(display_text)

func _on_timer_timeout():
	# reset role
	STATE.roll = false
	velocity = Vector2(0,0) # reset velocity
	target_position = global_position # reset target-position
	hit_area.disabled = false # reset hit-area
	anim.play("idle")
