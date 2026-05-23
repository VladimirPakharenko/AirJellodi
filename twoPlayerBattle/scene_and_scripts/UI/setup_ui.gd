extends CanvasLayer

var victory_label: Label

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Чтобы UI работал при паузе

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
	# Показываем победную надпись только во время игры
	if get_tree().current_scene:
		var is_main_level = (get_tree().current_scene.name == "MainLevel")
		visible = is_main_level
		
		# Синхронизируем нажатия красивых кнопок из CanvasLayer с действиями player1/player2
		if is_main_level:
			var canvas = get_tree().current_scene.get_node_or_null("CanvasLayer")
			if canvas:
				var red = canvas.get_node_or_null("red")
				var red2 = canvas.get_node_or_null("red2")
				
				# Красная кнопка (Игрок 1)
				if red:
					if red.is_pressed() and not Input.is_action_pressed("player1"):
						Input.action_press("player1")
					elif not red.is_pressed() and Input.is_action_pressed("player1"):
						Input.action_release("player1")
						
				# Синяя кнопка (Игрок 2)
				if red2:
					if red2.is_pressed() and not Input.is_action_pressed("player2"):
						Input.action_press("player2")
					elif not red2.is_pressed() and Input.is_action_pressed("player2"):
						Input.action_release("player2")
