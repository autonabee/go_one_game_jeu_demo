extends Control

@onready var input_button_scene = preload("res://ui/controls_settings/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var remap_delay_frames

var input_actions = {
	"move_forward" : "Move forward",
	"move_back" : "Move back",
	"move_left" : "Move left",
	"move_right" : "Move right",
	"aim_up" : "Aim up",
	"aim_down" : "Aim down",
	"aim_left" : "Aim left",
	"aim_right" : "Aim right",
	"shoot" : "Shoot",
	"jump" : "Jump",
	"select" : "Select"
	}

var events_name = {
	"Joypad Motion on Axis 1 (Left Stick Y-Axis, Joystick 0 Y-Axis) with Value -1.00" : "STICK1 UP",
	"Joypad Motion on Axis 1 (Left Stick Y-Axis, Joystick 0 Y-Axis) with Value 1.00" : "STICK1 DOWN",
	"Joypad Motion on Axis 0 (Left Stick X-Axis, Joystick 0 X-Axis) with Value -1.00" : "STICK1 LEFT",
	"Joypad Motion on Axis 0 (Left Stick X-Axis, Joystick 0 X-Axis) with Value 1.00" : "STICK1 RIGHT",
	"Joypad Motion on Axis 3 (Right Stick Y-Axis, Joystick 1 Y-Axis) with Value -1.00" : "STICK2 UP",
	"Joypad Motion on Axis 3 (Right Stick Y-Axis, Joystick 1 Y-Axis) with Value 1.00" : "STICK2 DOWN",
	"Joypad Motion on Axis 2 (Right Stick X-Axis, Joystick 1 X-Axis) with Value -1.00" : "STICK2 LEFT",
	"Joypad Motion on Axis 2 (Right Stick X-Axis, Joystick 1 X-Axis) with Value 1.00" : "STICK2 RIGHT",
	"Joypad Button 0 (Bottom Action, Sony Cross, Xbox A, Nintendo B)" : "Bottom action",
	"Joypad Button 1 (Right Action, Sony Circle, Xbox B, Nintendo A)" : "Right action",
	"Joypad Button 2 (Left Action, Sony Square, Xbox X, Nintendo Y)" : "Left action",
	"Joypad Button 3 (Top Action, Sony Triangle, Xbox Y, Nintendo X)" : "Top action"
	
	
#compléter avec autres inputs
	}

func _ready() -> void:
	_load_controls_from_settings()
	_create_action_list()
	$BackButton.grab_focus()

func _load_controls_from_settings():
	"""
	Récupère le dictionnaire avec la correspondance action-commande
	Efface kes anciennens commandes et les remplace par les nouvelles
	"""
	var controls = ConfigFileHandler.load_controls()
	for action in controls.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action,controls[action])


func _set_focus(enabled:bool) -> void:
	"""
	Activerdésactive le focus
	"""
	for button in action_list.get_children():
		button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE

func _create_action_list() -> void:
	"""
	Crée et ajoute les InputButtons des différentes actions et leur commande correspondante
	"""
	for item in action_list.get_children():
		item.queue_free()
		
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("ActionLabel")
		var input_label = button.find_child("InputLabel")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:			
			var event_key = events[0].as_text()
			if events_name.has(event_key):
				input_label.text = events_name[event_key]
			else:
				input_label.text = event_key
		else:
			input_label.text = ""
		
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action)) # passe l'instance d'InputButton et son action en argument

func _on_input_button_pressed(button, action):
	"""
	Fonction reliée au signal pressed des InputButtons
	Active le mode de remapping d'une action
	"""
	if !is_remapping:
		is_remapping = true
		action_to_remap = action # ancienne action
		remapping_button = button # InputButton en train d'être remappé
		button.find_child("InputLabel").text = "..."
		
		remap_delay_frames = 1 # définir un temps d'attente
		_set_focus(false)
		accept_event()

func _input(event: InputEvent) -> void:
	if is_remapping:
		if remap_delay_frames > 0:
			remap_delay_frames -= 1 # attendre une frame avant d'attribuer l'input à une action
			return
		if event is InputEventJoypadButton || event is InputEventJoypadMotion:
			if event is InputEventJoypadMotion:
				if abs(event.axis_value) < 0.9:
					return  # ignorer les mouvements parasites
				event.axis_value = 1.0 if event.axis_value > 0 else -1.0 # arrondir la valeur à 1.0 ou -1.0
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			ConfigFileHandler.save_controls(action_to_remap,event)
			
			_update_action_list(remapping_button, event)
			
			_set_focus(true)
			remapping_button.grab_focus()
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null

func _update_action_list(button: Button,event: InputEvent) -> void:
	"""
	Met à jour les labels de l'InputButton concerné
	Paramètres : 
		button: Button : l'InputButton en train d'être remappé
		event: InputEvent : la nouvelle commande attribuée à cette action
	"""
	var event_key = event.as_text()
	if events_name.has(event_key):
		button.find_child("InputLabel").text = events_name[event_key]
	else:
		button.find_child("InputLabel").text = event_key

func _on_back_button_pressed() -> void:
	"""
	Fonction reliée au signal pressed du BackButton
	Ramène au menu principal
	"""
	get_tree().change_scene_to_file("res://main.tscn")

func _on_default_button_pressed() -> void:
	"""
	Fonction reliée au signal pressed du DefaultButton
	Réinitialise les paramètres par défaut en  récupérant l'InputMap dans les paramètres du projet  et recrée les InputButtons
	"""
	InputMap.load_from_project_settings()
	for action in input_actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			ConfigFileHandler.save_controls(action, events[0])
	_create_action_list()
