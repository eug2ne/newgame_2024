extends CharacterBody2D

@onready var anim: AnimationPlayer = get_node("AnimationPlayer")
@onready var hit_area: CollisionShape2D = get_node("PlayerHitArea")
@onready var nav_agent: NavigationAgent2D = get_node("Navigation/NavigationAgent2D")
@onready var tile_map: TileMap = get_node("%tile_map")
var current_path: Array[Vector2i]
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var SPEED = 150
const ROLL_DISTANCE = 75
const JUMP_VELOCITY = -400

enum TileType {
	RUN = 1,
	JUMP = 2,
	CLIMB = 4,
	UP = 8,
	DOWN = 16
}

func _ready():
	print(tile_map)
	anim.play("idle")
	
func _input(event):
	# update target_position & set speed on mouse-click event
	if event.is_action_pressed("ui_mouseclick_left"):
		var target_position = get_global_mouse_position()
		current_path = tile_map.astar.get_id_path(
			tile_map.local_to_map(global_position),
			tile_map.local_to_map(target_position)
		).slice(1)
		SPEED = 150 # default speed
		if event.double_click:
			SPEED = 220 # fast speed
	if event.is_action_pressed("ui_mouseclick_right") and is_on_floor():
		var roll_dir = get_global_mouse_position().x - position.x
		nav_agent.target_position.x += (roll_dir/abs(roll_dir)) * ROLL_DISTANCE
		SPEED = 150 # default speed
		hit_area.disabled = true # disable hit-area during roll

func _process(delta):
	if current_path.is_empty():
		return
		
	var next_position = tile_map.map_to_local(current_path.front())
	global_position = global_position.move_toward(next_position, 3)
	
	if global_position == next_position:
		current_path.pop_front()
		
	# TODO: apply player velocity + animation
	# TODO: create speech bubble on scene
	# TODO: if path unaccesible, show speech bubble

#func _physics_process(delta):
	#if nav_agent.is_navigation_finished():
		## add gravity
		#if not is_on_floor():
			#velocity.y = GRAVITY
		#else:
			#velocity = Vector2(0,0) # reset velocity
			#hit_area.disabled = false # reset hit-area
			#anim.play("idle")
	#else:
		#var direction = to_local(nav_agent.get_next_path_position()).normalized()
	#
		## flip player direction
		#if direction.x < 0:
			#get_node("AnimatedSprite2D").flip_h = true
		#else:
			#get_node("AnimatedSprite2D").flip_h = false
			#
		## move player to target position
		#velocity = direction * SPEED
	#
	#move_and_slide()

func _on_tile_detector__tile_entered(tile_type):
	print(tile_type)
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


func _on_timer_timeout():
	pass # Replace with function body.
