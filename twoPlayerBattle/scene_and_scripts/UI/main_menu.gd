extends Control

func _ready():
	# Находим кнопку "ИГРАТЬ" (TextureButton)
	var play_button = $MarginContainer/VBoxContainer/TextureButton
	play_button.pressed.connect(_on_play_pressed)
	
	# Находим кнопку "ВЫХОД" (TextureButton3)
	var exit_button = $MarginContainer/VBoxContainer/TextureButton3
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scene_and_scripts/level/main_level.tscn")

func _on_exit_pressed():
	get_tree().quit()
