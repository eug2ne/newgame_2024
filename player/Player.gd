extends CharacterBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var hit_area: CollisionShape2D = $PlayerHitArea
@onready var speech_bubble: MarginContainer = $SpeechBubble
@onready var tile_map: TileMap = get_node("%tile_map")
var target_position: Vector2
var direction: Vector2
var current_path: Array[Vector2i] = []

var STATE: Dictionary = {
	"move_up": false
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
	target_position = global_position # reset target_position
	anim.play("idle")
	
func _input(event):
	# set speed on mouse-click event
	if event.is_action_pressed("ui_mouseclick_left"):
		SPEED = 150 # default speed
		if event.double_click:
			SPEED = 220 # fast speed

	if event.is_action_pressed("ui_mouseclick_right") and is_on_floor():
		# TODO: create roll action
		print("roll")
		var roll_dir = get_global_mouse_position().x - position.x
		SPEED = 150 # default speed
		hit_area.disabled = true # disable hit-area during roll

# TODO: create speech bubble on scene

func _physics_process(_delta):
	var current_tile_coord = tile_map.local_to_map(global_position)
	
	if current_path.is_empty():
		if not is_on_floor():
			# apply gravity
			velocity.y = GRAVITY
		
		tile_map.update_astar(false, global_position) # reset tile_map navigation + update map icon
		velocity = Vector2(0,0) # reset velocity
		hit_area.disabled = false # reset hit-area
		anim.play("idle")
		return
	
	if current_tile_coord == current_path.front():
		current_path.pop_front()
		
		if current_path.is_empty():
			# end of path
			# TODO: after player entering last tile, adjust player toward target-position
			return
	
	var next_direction = current_path.front() - current_tile_coord

	# flip player direction
	if next_direction.x < 0:
		get_node("AnimatedSprite2D").flip_h = true
	else:
		get_node("AnimatedSprite2D").flip_h = false
	
	# apply player animation
	anim.play("run")
	# move player to next position
	velocity.x = next_direction.x * SPEED
	# apply gravity + jump velocity
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
	
func _show_speech_bubble(display_text):
	# TODO: if path unaccesible, show speech bubble
	# FIXME: current_path always return empty
	speech_bubble._display_text(display_text)

func _on_tile_detector__tile_entered(tile_type):
	# control player animation by tile_type
	match tile_type:
		TileType.RUN:
			anim.play("run")
		TileType.JUMP + TileType.UP:
			print("jump up")
			velocity.y = JUMP_VELOCITY
		TileType.JUMP + TileType.DOWN:
			print("jump down")
			
	if velocity.y > 0:
		anim.play("fall")
