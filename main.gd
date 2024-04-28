extends Node2D

var mouse_particle_PS: PackedScene = preload("res://particle/mouse_particle.tscn")
@onready var player: CharacterBody2D = get_node("Player")

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			# get mouse_click position
			var mouse_pos = get_local_mouse_position() 
			# create mouse_particle
			var particle = mouse_particle_PS.instantiate()
			add_child(particle)
			particle.set_position(mouse_pos)
