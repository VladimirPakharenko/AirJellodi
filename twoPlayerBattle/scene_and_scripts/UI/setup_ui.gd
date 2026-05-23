extends CanvasLayer

var victory_label: Label

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Чтобы UI работал при паузе
	
	var btn_size = Vector2(250, 200) # Размер наших прямоугольных кнопок
	
	# === Синяя кнопка (Левый нижний угол) - Игрок 2 ===
	var bg_blue = ColorRect.new()
	bg_blue.color = Color(0.2, 0.4, 0.9, 0.8) # Приятный синий цвет (полупрозрачный)
	bg_blue.size = btn_size
	bg_blue.position = Vector2(20, 800 - btn_size.y - 20)
	add_child(bg_blue) # Добавляем цветной фон
	
	var btn_blue = TouchScreenButton.new()
	var shape_blue = RectangleShape2D.new()
	shape_blue.size = btn_size
	btn_blue.shape = shape_blue
	# Для TouchScreenButton позиция выставляется по центру RectangleShape2D
	btn_blue.position = bg_blue.position + btn_size / 2.0 
	btn_blue.action = "player2"
	add_child(btn_blue)
	
	# === Красная кнопка (Правый верхний угол) - Игрок 1 ===
	var bg_red = ColorRect.new()
	bg_red.color = Color(0.9, 0.2, 0.2, 0.8) # Приятный красный цвет (полупрозрачный)
	bg_red.size = btn_size
	bg_red.position = Vector2(1088 - btn_size.x - 20, 20)
	add_child(bg_red) # Добавляем цветной фон
	
	var btn_red = TouchScreenButton.new()
	var shape_red = RectangleShape2D.new()
	shape_red.size = btn_size
	btn_red.shape = shape_red
	btn_red.position = bg_red.position + btn_size / 2.0
	btn_red.action = "player1"
	add_child(btn_red)
	
	# === Надпись ПОБЕДА ===
	victory_label = Label.new()
	victory_label.add_theme_font_size_override("font_size", 100)
	victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_label.size = Vector2(1088, 800)
	victory_label.position = Vector2(0, 0)
	victory_label.add_theme_constant_override("outline_size", 15)
	victory_label.add_theme_color_override("font_outline_color", Color.BLACK)
	victory_label.hide()
	add_child(victory_label)

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
