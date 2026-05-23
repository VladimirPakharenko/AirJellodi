extends Camera2D

@export var player1: Node2D
@export var player2: Node2D
@export var follow_speed: float = 5.0
@export var horizontal_speed: float = 200.0

@onready var top_boundary = $Boundaries/Top
@onready var bottom_boundary = $Boundaries/Bottom
@onready var left_boundary = $Boundaries/Left
@onready var right_boundary = $Boundaries/Right
@onready var parallax_layer = get_node("../ParallaxBackground/Sky")
@onready var sky_sprite = get_node("../ParallaxBackground/Sky/Sprite2D")

func _ready():
	update_boundaries()
	update_background()
	get_viewport().size_changed.connect(update_boundaries)
	get_viewport().size_changed.connect(update_background)

func update_boundaries():
	var size = get_viewport_rect().size

	top_boundary.position.y = -size.y / 2
	bottom_boundary.position.y = size.y / 2
	left_boundary.position.x = -size.x / 2
	right_boundary.position.x = size.x / 2

func update_background():
	var size = get_viewport_rect().size
	# Adjust parallax mirroring and sprite region to viewport size
	parallax_layer.motion_mirroring.x = size.x
	sky_sprite.region_rect = Rect2(0, 0, size.x, size.y)
	sky_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	# Center camera vertically if needed
	position.y = size.y / 2

func _physics_process(delta):
	# Constant movement to the right, synced with planes
	position.x += horizontal_speed * delta

	# Vertical follow disabled for testing
	# if player1 and player2:
	#	var target_y = (player1.global_position.y + player2.global_position.y) / 2
	#	global_position.y = lerp(global_position.y, target_y, follow_speed * delta)
