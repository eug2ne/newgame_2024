extends Node2D

var mouse_particle_PS: PackedScene = preload("res://particle/mouse_particle.tscn")
@onready var tile_map: TileMap = $tile_map
@onready var player: CharacterBody2D = $Player
@onready var path: Node2D = $Path

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			# get mouse_click position
			var mouse_pos = get_local_mouse_position() 
			# create mouse_particle
			var particle = mouse_particle_PS.instantiate()
			add_child(particle)
			particle.set_position(mouse_pos)
			
			# get path to mouse_pos
			var player_path = tile_map._get_current_path(player.global_position, mouse_pos)
			print(player_path)
			
			# pass path, target_position to player
			player.current_path = player_path
			player.target_position = mouse_pos
			
			if player_path.is_empty():
				# show message
				player._show_speech_bubble("I can't go there.")
