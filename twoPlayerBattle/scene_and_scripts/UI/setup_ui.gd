extends CanvasLayer

var bg_blue: ColorRect
var bg_red: ColorRect
var btn_blue: TouchScreenButton
var btn_red: TouchScreenButton
var victory_label: Label
var btn_size = Vector2(250, 200)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Чтобы UI работал при паузе

	# === Синяя кнопка (Левый нижний угол) - Игрок 2 ===
	bg_blue = ColorRect.new()
	bg_blue.color = Color(0.2, 0.4, 0.9, 0.8) # Приятный синий цвет (полупрозрачный)
	bg_blue.size = btn_size
	add_child(bg_blue) # Добавляем цветной фон
	
	btn_blue = TouchScreenButton.new()
	var shape_blue = RectangleShape2D.new()
	shape_blue.size = btn_size
	btn_blue.shape = shape_blue
	btn_blue.action = "player2"
	add_child(btn_blue)
	
	# === Красная кнопка (Правый верхний угол) - Игрок 1 ===
	bg_red = ColorRect.new()
	bg_red.color = Color(0.9, 0.2, 0.2, 0.8) # Приятный красный цвет (полупрозрачный)
	bg_red.size = btn_size
	add_child(bg_red) # Добавляем цветной фон
	
	btn_red = TouchScreenButton.new()
	var shape_red = RectangleShape2D.new()
	shape_red.size = btn_size
	btn_red.shape = shape_red
	btn_red.action = "player1"
	add_child(btn_red)
	
	# === Надпись ПОБЕДА ===
	victory_label = Label.new()
	victory_label.add_theme_font_size_override("font_size", 100)
	victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_label.add_theme_constant_override("outline_size", 15)
	victory_label.add_theme_color_override("font_outline_color", Color.BLACK)
	victory_label.hide()
	add_child(victory_label)

	update_ui_layout()
	get_viewport().size_changed.connect(update_ui_layout)

func update_ui_layout():
	var size = get_viewport().get_visible_rect().size

	bg_blue.position = Vector2(20, size.y - btn_size.y - 20)
	btn_blue.position = bg_blue.position + btn_size / 2.0

	bg_red.position = Vector2(size.x - btn_size.x - 20, 20)
	btn_red.position = bg_red.position + btn_size / 2.0

	victory_label.size = size
	victory_label.position = Vector2(0, 0)

func show_victory(winner_index: int):
	if winner_index == 0:
		victory_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2)) # Красный
		victory_label.text = "КРАСНЫЙ ПОБЕДИЛ!"
	else:
		victory_label.add_theme_color_override("font_color", Color(0.2, 0.4, 1)) # Синий
		victory_label.text = "СИНИЙ ПОБЕДИЛ!"
	
	victory_label.show()

func hide_victory():
	if victory_label:
		victory_label.hide()

func _process(delta):
	# Показываем кнопки управления только во время самой игры, чтобы они не висели в главном меню
	if get_tree().current_scene:
		visible = (get_tree().current_scene.name == "MainLevel")
