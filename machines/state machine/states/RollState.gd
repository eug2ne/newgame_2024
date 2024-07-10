extends State

@onready var timer: Timer = $RollTimer

@export var idle_state: State

func _on_enter():
	super()
	# handle hit-area
	var hit_area: CollisionShape2D = parent.get_node("HitArea")
	hit_area.disabled = true
	# start roll-timer
	timer.start(0.9)
	
func _on_exit():
	# handle hit-area
	var hit_area: CollisionShape2D = parent.get_node("HitArea")
	hit_area.disabled = false
	# set next_state to idle-state
	next_state = idle_state
	print(next_state)
	
func _update_physics(current_direction: Vector2i, _next_direction: Vector2i, _current_path: Array[Vector2i]):
	parent.velocity.x = current_direction.x * SPEED
	
	if !parent.is_on_floor():
		# apply gravity
		parent.velocity.y = GRAVITY
	
func _on_roll_timer_timeout():
	# change to idle state
	emit_signal("Transition")
