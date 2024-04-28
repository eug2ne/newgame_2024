extends Area2D
class_name Icon

var in_area: bool = false

signal _icon_clicked(mouse_pos)

var interact: Callable = func():
	pass
	
func _input(event):
	if event.is_action_pressed("move") and in_area:
		# emit _icon_clicked signal
		var mouse_pos = get_global_mouse_position()
		emit_signal("_icon_clicked", mouse_pos)

func _on_mouse_entered():
	in_area = true

func _on_mouse_exited():
	in_area = false
