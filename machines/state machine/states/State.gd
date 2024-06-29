extends Node
class_name State

var character: CharacterBody2D
var anim: AnimationPlayer
@export var anim_key: String
@export var fast_anim_key: String

var next_state: State

# physics property
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var SPEED = 100


const DEFAULT_SPEED = 130
const FAST_SPEED = 180
const ROLL_DISTANCE = 90
const JUMP_VELOCITY = -300

func _on_enter():
	pass
	
func _on_exit():
	pass

func play_animation(fast: bool = false):
	# play state animation
	if fast:
		anim.play(fast_anim_key)
	else:
		anim.play(anim_key)

func _physics_process(_delta):
	pass
