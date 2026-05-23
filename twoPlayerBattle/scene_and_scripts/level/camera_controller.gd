extends Camera2D

@export var player1: Node2D
@export var player2: Node2D
@export var follow_speed: float = 5.0
@export var horizontal_speed: float = 200.0

func _process(delta):
	# Constant movement to the right
	position.x += horizontal_speed * delta

	# Vertical follow disabled for testing
	# if player1 and player2:
	#	var target_y = (player1.global_position.y + player2.global_position.y) / 2
	#	global_position.y = lerp(global_position.y, target_y, follow_speed * delta)
