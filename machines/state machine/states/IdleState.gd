extends State

@export var nav_machine: NavigationMachine

func _on_enter():
	super()

func _update_physics(_current_direction: Vector2i, _next_direction: Vector2i, _current_path: Array[Vector2i]):
	if !parent.is_on_floor():
		# apply gravity
		parent.velocity.y = GRAVITY
	else:
		# reset parent velocity
		parent.velocity = Vector2(0,0)
