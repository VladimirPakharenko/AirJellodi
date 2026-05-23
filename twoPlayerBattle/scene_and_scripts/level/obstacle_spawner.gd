extends Node2D

@export var rock_scene: PackedScene
@export var min_spawn_interval: float = 2.5
@export var max_spawn_interval: float = 4.5
@export var camera: Camera2D

var timer: float = 0.0
var next_spawn_time: float = 2.0

var rocks_bottom = [
	preload("res://assets/kenney_tappy-plane/PNG/rock.png"),
	preload("res://assets/kenney_tappy-plane/PNG/rockGrass.png")
]

var rocks_top = [
	preload("res://assets/kenney_tappy-plane/PNG/rockDown.png"),
	preload("res://assets/kenney_tappy-plane/PNG/rockGrassDown.png")
]

func _ready():
	next_spawn_time = randf_range(min_spawn_interval, max_spawn_interval)

func _process(delta):
	timer += delta
	if timer >= next_spawn_time:
		timer = 0
		next_spawn_time = randf_range(min_spawn_interval, max_spawn_interval)
		spawn_obstacle()

func spawn_obstacle():
	if not camera: return

	# Choose type: 0 = Bottom, 1 = Top, 2 = Both
	var type = randi() % 3

	if type == 0 or type == 2:
		create_rock(false) # Bottom
	if type == 1 or type == 2:
		create_rock(true) # Top

func create_rock(is_top: bool):
	var rock = rock_scene.instantiate()
	var textures = rocks_top if is_top else rocks_bottom
	var tex = textures[randi() % textures.size()]

	var sprite = rock.get_node("Sprite2D")
	sprite.texture = tex

	# Update collision shape to match the texture size exactly
	var shape_node = rock.get_node("CollisionShape2D")
	var new_shape = RectangleShape2D.new()
	new_shape.size = tex.get_size()
	shape_node.shape = new_shape

	# Randomly mirror the sprite for more variety
	sprite.flip_h = randi() % 2 == 0

	# Random scale and rotation to make them harder and more varied
	var s = randf_range(1.3, 1.9)
	rock.scale = Vector2(s, s * randf_range(0.9, 1.1))
	rock.rotation = randf_range(-0.25, 0.25)

	# Position: ahead of camera (camera is centered, screen width 1280)
	var spawn_x = camera.global_position.x + 800

	# Height variation for 16:9 (720 height)
	# Reduced offset to prevent "levitating" (rocks stay closer to edges)
	var spawn_y: float
	if is_top:
		spawn_y = randf_range(-30, 40)
	else:
		spawn_y = 720 - randf_range(-30, 40)

	rock.global_position = Vector2(spawn_x, spawn_y)

	# Add to level, not spawner, so it doesn't move with spawner if spawner is parented to camera
	get_parent().add_child(rock)

	# Basic cleanup: remove if far behind camera
	var cleanup_timer = get_tree().create_timer(10.0)
	cleanup_timer.timeout.connect(func(): if is_instance_valid(rock): rock.queue_free())
