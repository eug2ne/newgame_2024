extends Node2D

var mouse_particle_PS: PackedScene = preload("res://particle/mouse_particle.tscn")
@onready var tile_map: TileMap = $tile_map
@onready var player: CharacterBody2D = $Player

const ROLL_DISTANCE = 90

func _input(event):
	if event.is_action_pressed("ui_mouseclick_left") || event.is_action_pressed("ui_mouseclick_right"):
		# get mouse_click position
		var mouse_pos = get_global_mouse_position() 
		# create mouse_particle
		var particle = mouse_particle_PS.instantiate()
		add_child(particle)
		particle.set_position(mouse_pos)
