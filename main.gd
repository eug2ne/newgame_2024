extends Node2D

var mouse_particle_PS: PackedScene = preload("res://particle/mouse_particle.tscn")
@onready var tile_map: TileMap = $tile_map
@onready var player: CharacterBody2D = $Player

func _input(event):
	if event.is_action_pressed("ui_mouseclick_left"):
		# get mouse_click position
		var mouse_pos = get_local_mouse_position() 
		# create mouse_particle
		var particle = mouse_particle_PS.instantiate()
		add_child(particle)
		particle.set_position(mouse_pos)
		
		# check mouse_pos accessibility
		var accessible = tile_map._pos_accessible(mouse_pos)
		if not accessible:
			# show speech bubble
			player._show_speech_bubble("I can't go into unknown territory.")
			return
		
		# get path to mouse_pos
		var player_path = tile_map._get_current_path(player.global_position, mouse_pos)
		print(player_path)
		
		if player_path.is_empty():
			# show speech bubble
			player._show_speech_bubble("There is no way to get there.")
			return
		
		# pass path, target_position to player
		player.current_path = player_path
		player.target_position = mouse_pos
