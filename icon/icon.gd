extends Area2D
class_name Icon

# TODO: need easier way to register tile data to icon
@onready var sprite: Sprite2D = $Sprite2D
var in_area: bool = false

signal _icon_clicked(mouse_pos)

var interact: Callable = func():
	pass

func switch_image(player_pos: Vector2):
	# switch image of icon
	if player_pos.y > global_position.y:
		sprite.frame = 0
	else:
		sprite.frame = 1

func _on_mouse_entered():
	in_area = true

func _on_mouse_exited():
	in_area = false
