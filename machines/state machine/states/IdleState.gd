extends State

func _on_enter():
	# play idle animation
	play_animation()
	
func _on_exit():
	pass
	
func _physics_process(_delta):
	if !character.is_on_floor():
		# apply gravity
		character.velocity.y = GRAVITY
	else:
		# reset chracter velocity
		character.velocity = Vector2(0,0)
