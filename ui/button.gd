"""
Script attaché à tous les boutons de l'interface (sauf les boutons de sélection du niveau)
Permet de sélectionner un bouton avec la manette
"""

extends Button


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select") and has_focus():
		self.pressed.emit()
