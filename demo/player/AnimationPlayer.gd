extends AnimationPlayer


func _on_animation_finished(anim_name):
	if anim_name == "roll_start":
		self.play("roll_repeat")
