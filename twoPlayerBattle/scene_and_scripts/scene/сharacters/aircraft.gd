extends Node2D

var Positions = [1, -1]
var Colors = ["air_red", "air_blue"]
var Actions = ["player1", "player2"]

@export var speed = 30.0
@export var gravity = 700
@export var flap_force = 400

@onready var planes = [$Red, $Blue]

func _ready():
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
