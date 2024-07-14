extends Node
class_name State

@export var anim_key: String
# reference to parent
var parent: CharacterBody2D
var anim: AnimationPlayer

var next_state: State
signal Transition

# physics property
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var SPEED = 100

const DEFAULT_SPEED = 100
const FAST_SPEED = 180
const ROLL_DISTANCE = 90
const JUMP_VELOCITY = -180

func _on_enter():
	# play state animation
	anim.play(anim_key)
	
func _on_exit():
	# define next_state
	pass
	
func _update_physics(current_direction: Vector2i, next_direction: Vector2i, current_path: Array[Vector2i]):
	pass
	
func _update_input(event):
	pass
