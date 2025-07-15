extends Button


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select") and has_focus():
		self.pressed.emit()
