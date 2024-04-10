extends CharacterBody2D

@onready var anim: AnimationPlayer = get_node("AnimationPlayer")
@onready var hit_area: CollisionShape2D = get_node("PlayerHitArea")
var target_position: Vector2
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var SPEED = 150
const POS_BUFFER = 3
const ROLL_DISTANCE = 75
const JUMP_VELOCITY = -400

func _ready():
	# set current position to target_position
	target_position = position
	anim.play("idle")
	
func _input(event):
	# update target_position & set speed on mouse-click event
	if event.is_action_pressed("move"):
		target_position = get_global_mouse_position()
		SPEED = 150 # default speed
		if event.double_click:
			SPEED = 220 # fast speed
	if event.is_action_pressed("roll") and is_on_floor():
		var roll_dir = get_global_mouse_position().x - position.x
		target_position.x += (roll_dir/abs(roll_dir)) * ROLL_DISTANCE
		SPEED = 150 # default speed

func _physics_process(delta):
	# add gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	var directionX = target_position.x - position.x
	var directionY = target_position.y - position.y
		
	if abs(directionX) > POS_BUFFER and position.x != target_position.x:
		# flip player direction
		if directionX < 0:
			get_node("AnimatedSprite2D").flip_h = true
		else:
			get_node("AnimatedSprite2D").flip_h = false
		
		# move player to target position
		if Input.is_action_pressed("move"):
			velocity.x = (directionX/abs(directionX)) * SPEED
			anim.play("run")
		elif Input.is_action_pressed("roll"):
			velocity.x = (directionX/abs(directionX)) * SPEED
			anim.play("roll_start")
			# disable hit-area during roll
			hit_area.disabled = true
	else:
		velocity.x = 0 # reset velocity
		hit_area.disabled = false # reset hit-area
		anim.play("idle")
	
	if velocity.y > 0:
		anim.play("fall")
	
	move_and_slide()
