extends Node2D

@export var rock_scene: PackedScene
@export var min_spawn_interval: float = 2.0
@export var max_spawn_interval: float = 3.5
@export var camera: Camera2D

var timer: float = 0.0
var biome_timer: float = 0.0
var next_spawn_time: float = 2.0

var last_ground_x: float = 0.0
const GROUND_WIDTH: float = 800.0 # Approximate width of Kenney ground sprites

enum Biome { GRASS, ICE, DIRT }
var current_biome = Biome.GRASS

@onready var biome_data = {
	Biome.GRASS: {
		"ground": preload("res://assets/kenney_tappy-plane/PNG/groundGrass.png"),
		"top": [preload("res://assets/kenney_tappy-plane/PNG/rockGrassDown.png")],
		"bottom": [preload("res://assets/kenney_tappy-plane/PNG/rockGrass.png")]
	},
	Biome.ICE: {
		"ground": preload("res://assets/kenney_tappy-plane/PNG/groundIce.png"),
		"top": [preload("res://assets/kenney_tappy-plane/PNG/rockIceDown.png"), preload("res://assets/kenney_tappy-plane/PNG/rockSnowDown.png")],
		"bottom": [preload("res://assets/kenney_tappy-plane/PNG/rockIce.png"), preload("res://assets/kenney_tappy-plane/PNG/rockSnow.png")]
	},
	Biome.DIRT: {
		"ground": preload("res://assets/kenney_tappy-plane/PNG/groundDirt.png"),
		"top": [preload("res://assets/kenney_tappy-plane/PNG/rockDown.png")],
		"bottom": [preload("res://assets/kenney_tappy-plane/PNG/rock.png")]
	}
}

func _ready():
	last_ground_x = 0
	# Pre-spawn ground to cover more than one screen immediately
	for i in range(5):
		spawn_ground()
	next_spawn_time = randf_range(min_spawn_interval, max_spawn_interval)

func _process(delta):
	timer += delta
	biome_timer += delta

	# Change biome every 15 seconds
	if biome_timer >= 15.0:
		biome_timer = 0
		current_biome = (current_biome + 1) % 3

	# Spawn ground ahead of camera
	if camera.global_position.x + 1280 > last_ground_x:
		spawn_ground()

	if timer >= next_spawn_time:
		timer = 0
		next_spawn_time = randf_range(min_spawn_interval, max_spawn_interval)
		spawn_obstacle()

func spawn_ground():
	var data = biome_data[current_biome]
	var tex = data["ground"]
	var width = tex.get_width()

	# Bottom ground
	create_ground_piece(tex, last_ground_x, 720, false)
	# Top ground
	create_ground_piece(tex, last_ground_x, 0, true)

	last_ground_x += width

func create_ground_piece(tex: Texture, x: float, y: float, is_top: bool):
	var body = StaticBody2D.new()
	body.collision_layer = 8 # Separate layer for ground
	body.collision_mask = 0
	body.z_index = 5 # Middle ground depth

	var sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.centered = false
	body.add_child(sprite)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = tex.get_size()
	shape.shape = rect
	shape.position = tex.get_size() / 2
	body.add_child(shape)

	body.global_position = Vector2(x, y)

	if is_top:
		sprite.flip_v = true
	else:
		# Shift up by its height so it sits on the bottom edge
		body.global_position.y -= tex.get_height()

	get_parent().add_child.call_deferred(body)

	# Cleanup
	get_tree().create_timer(20.0).timeout.connect(func(): if is_instance_valid(body): body.queue_free())

func spawn_obstacle():
	if not camera: return
	var type = randi() % 3

	if type == 0:
		create_rock(false, randf_range(2.2, 3.0), randf_range(-10, 30))
	elif type == 1:
		create_rock(true, randf_range(2.2, 3.0), randf_range(-10, 30))
	else:
		var gate_shift = randf_range(-120, 120)
		create_rock(false, randf_range(1.3, 1.7), gate_shift)
		create_rock(true, randf_range(1.3, 1.7), gate_shift)

func create_rock(is_top: bool, custom_scale: float, y_offset: float):
	var rock = rock_scene.instantiate()

	# To ensure the rock matches the ground it spawns over,
	# we use the biome that is being used for ground at 'spawn_x'
	var data = biome_data[current_biome]
	var textures = data["top"] if is_top else data["bottom"]
	var tex = textures[randi() % textures.size()]

	var sprite = rock.get_node("Sprite2D")
	sprite.texture = tex

	# Automatic high-precision polygon generation from texture alpha
	var poly_node = rock.get_node("CollisionPolygon2D")
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(tex.get_image())
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, tex.get_size()), 2.0)

	if polygons.size() > 0:
		var offset = tex.get_size() / 2
		var points = polygons[0]
		for i in range(points.size()):
			points[i] -= offset
		poly_node.polygon = points

	sprite.flip_h = randi() % 2 == 0
	rock.scale = Vector2(custom_scale, custom_scale)

	# Randomize depth: some rocks behind ground, some in front
	# Ground is z_index 5.
	if randi() % 2 == 0:
		rock.z_index = 4 # Behind ground
	else:
		rock.z_index = 6 # In front of ground

	# 1100 is far enough ahead where we are already placing new ground pieces
	var spawn_x = camera.global_position.x + 1100
	var spawn_y = y_offset + (0 if is_top else 720)

	rock.global_position = Vector2(spawn_x, spawn_y)
	get_parent().add_child.call_deferred(rock)
	get_tree().create_timer(10.0).timeout.connect(func(): if is_instance_valid(rock): rock.queue_free())
