extends Node2D

signal plane_hit_rock(plane_index)

var Positions = [1, -1]
var Colors = ["air_red", "air_blue"]
var Actions = ["player1", "player2"]

@export var speed = 200.0
@export var gravity = 700
@export var flap_force = 400

@onready var planes = [$Red, $Blue]

func _ready():
	SetupUI.hide_victory() # Скрываем надпись с прошлой игры
	for i in range(planes.size()):
		var sprite = planes[i].get_node("AnimatedSprite2D")
		sprite.play(Colors[i])
		if Positions[i] == -1:
			sprite.flip_v = true

func _physics_process(delta):
	for i in range(planes.size()):
		var plane = planes[i]
		var dir = Positions[i]
		
		plane.velocity.y += gravity * dir * delta
		
		if Input.is_action_just_pressed(Actions[i]):
			plane.velocity.y = -flap_force * dir
		
		plane.velocity.x = speed
		plane.move_and_slide()
		
		for j in range(plane.get_slide_collision_count()):
			var collision = plane.get_slide_collision(j)
			var collider = collision.get_collider()
			if collider.is_in_group("rocks"):
				plane_hit_rock.emit(i)
				game_over(i)
				
				break

func game_over(plane_index):
	var winner_index = 1 - plane_index # Если проиграл 0, выиграл 1 (и наоборот)
	SetupUI.show_victory(winner_index)
	get_tree().paused = true
	
	# Ожидаем 3 секунды. create_timer(3.0, true) работает даже во время паузы.
	await get_tree().create_timer(3.0).timeout
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene_and_scripts/UI/main_menu.tscn")
