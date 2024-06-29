extends State

#@onready var timer: Timer = character.get_node("/Timer")


func _on_enter():
	# start roll
	play_animation() # play roll animation
	# handle hit-area
	#timer.start(0.9) # start roll-timer
	pass
	
func _on_exit():
	# handle hit-area
	pass

func handle_hit_area(hit_area: CollisionShape2D, disable: bool = true):
	if disable:
		# disable hit-area (default)
		hit_area.disabled = true
	else:
		hit_area.disabled = false
