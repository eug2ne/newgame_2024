extends CharacterBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var hit_area: CollisionShape2D = $PlayerHitArea
@onready var speech_bubble: MarginContainer = $SpeechBubble
@onready var timer: Timer = $Timer
@onready var tile_map: TileMap = get_node("%tile_map")

var target_position: Vector2
var directionX: int
var current_path: Array[Vector2i] = []

var STATE: Dictionary = {
	"roll": false,
	"move_up": false,
	"move_down": false
}

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var SPEED = 150
const ROLL_DISTANCE = 75
const JUMP_VELOCITY = -200


enum TileType {
	RUN = 1,
	JUMP = 2,
	CLIMB = 4,
	UP = 8,
	DOWN = 16
}

func _ready():
	floor_constant_speed = true # movement speed constant on slopes
	target_position = global_position # reset target_position
	anim.play("idle")
	
func _input(event):
	if event.is_action_pressed("ui_mouseclick_left"):
		# set movement speed
		SPEED = 150 # default speed
		if event.double_click:
			SPEED = 220 # fast speed

	if event.is_action_pressed("ui_mouseclick_right"):
		# set roll speed + direction
		directionX = (get_global_mouse_position().x - global_position.x) / abs(get_global_mouse_position().x - global_position.x)
		target_position.x += directionX * ROLL_DISTANCE
		SPEED = 150 # default speed
		hit_area.disabled = true # disable hit-area during roll
		
		# flip player direction
		if directionX < 0:
			get_node("AnimatedSprite2D").flip_h = true
		else:
			get_node("AnimatedSprite2D").flip_h = false
		
		# start roll
		STATE.roll = true
		anim.play("roll_start")
		timer.start(0.5)

func _physics_process(_delta):
	var current_tile_coord = tile_map.local_to_map(global_position)
	
	if current_path.is_empty():
		if not is_on_floor():
			# apply gravity
			velocity.y = GRAVITY
			move_and_slide()
		
		if STATE.roll or abs(target_position.x - global_position.x) > 3:
			# (player roll) xor (adjust player toward target-position)
			directionX = (target_position.x - global_position.x) / abs(target_position.x - global_position.x)
			
			if is_on_edge():
				velocity.x = -1 * directionX * SPEED / 2
				# update target_position
				var player_coord = tile_map.local_to_map(global_position)
				var tile_pos = tile_map.map_to_local(player_coord)
				target_position.x = tile_pos.x + directionX * 4
				
				# TODO: add slide animation
			else:
				velocity.x = directionX * SPEED
			
			move_and_slide()
		
		else:
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
	
	# apply player animation
	anim.play("run")
	# adjust velocity.x
	if next_direction.y > 0 and next_direction.x != 0:
		velocity.x = next_direction.x * SPEED
		STATE.move_down = true
	elif next_direction.y > 0 and STATE.move_down:
		# down fall >> gradually decline velocity.x
		if velocity.x == 0:
			# velocity.x reach 0
			pass
		elif velocity.x > 0:
			velocity.x -= SPEED / 8
		else:
			velocity.x += SPEED / 8
	
	else:
		velocity.x = next_direction.x * SPEED
		STATE.move_up = false # set state to default
	# adjust velocity.y >> apply gravity + jump velocity
	if next_direction.y < 0:
		# apply jump velocity
		velocity.y = JUMP_VELOCITY
		STATE.move_up = true # set state to move_up
	elif next_direction.y == 0 and STATE.move_up:
		# jump mid-air >> gradually decline jump velocity
		velocity.y -= JUMP_VELOCITY / 4
	
	else:
		# apply gravity
		velocity.y = GRAVITY
		STATE.move_up = false # set state to default

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
		if e_direction == 1:
			# player on edge (left)
			return tile_pos.x - global_position.x > 5
		else:
			# player on edge (right)
			return tile_pos.x - global_position.x < -5
	
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
