extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready() -> void:
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("controls", "move_forward", "axis_1_-1.00")
		config.set_value("controls", "move_back", "axis_1_1.00")
		config.set_value("controls", "move_left", "axis_0_-1.00")
		config.set_value("controls", "move_right", "axis_0_1.00")
		config.set_value("controls", "aim_up","axis_3_-1.00")
		config.set_value("controls", "aim_down","axis_3_1.00")
		config.set_value("controls", "aim_left","axis_2_-1.00")
		config.set_value("controls", "aim_right","axis_2_1.00")
		config.set_value("controls", "jump","button_0")
		config.set_value("controls", "shoot","button_2")
		config.set_value("controls", "select","button_3")
	else:
		config.load(SETTINGS_FILE_PATH)

func save_controls(action: StringName, event: InputEvent) -> void:
	"""
	Ajoute une nouvelle entrée dans la section controls du fichier config
	Dictionnaire : 
		key : action:StringName, une action du jeu
		value : event_str:String, la commande pour réaliser cette action
	"""
	var event_str
	if event is InputEventJoypadButton:
		event_str = "button_" + str(event.get_button_index())
	elif event is InputEventJoypadMotion:
		event_str = "axis_" + str(event.get_axis()) + "_" + str(event.get_axis_value())
	config.set_value("controls", action, event_str)
	config.save(SETTINGS_FILE_PATH)

func load_controls() -> Dictionary:
	"""
	Crée un dictionnaire à partir du fichier config et le retourne
	Dictionnaire : 
		keys : String
		values : InputEvent
	"""
	var controls = {}
	var keys = config.get_section_keys("controls")
	for k in keys:
		var input_event
		var event_str = config.get_value("controls", k)
		
		if event_str.contains("button_"):
			input_event = InputEventJoypadButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		elif event_str.contains("axis_"):
			input_event = InputEventJoypadMotion.new()
			input_event.axis = int(event_str.split("_")[1])
			input_event.axis_value = float(event_str.split("_")[2])
		
		controls[k] = input_event
	return controls
