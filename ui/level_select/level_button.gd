extends Button

@export var level_number: String = "1"
@export_file ("*.tscn") var level_scene_path: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if level_number in Main.unlocked_levels :
		# débloque le niveau
		self.disabled = false
		text = level_number # affiche le numéro du niveau
		icon = null 
	else :
		self.disabled = true
		text = ""
		icon = preload("res://assets/images/lock_64.png")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select") and has_focus():
		self.pressed.emit()

func _on_pressed() -> void:
	"""
	Fonction connectée au signal pressed
	Charge la scène du niveau associé au bouton
	"""
	if level_scene_path :
		get_tree().change_scene_to_file(level_scene_path)
	else : 
		print("No file path")

func load_scene_path() -> void : 
	"""
	Fonction qui attribue la scène du niveau correspondant au numéro du bouton, 
	si elle existe
	"""
	var path = "res://maps/map." + level_number.pad_zeros(3) + ".tscn"
	if ResourceLoader.exists(path):
		level_scene_path = path
	else:
		print("Map %s doesn't exist" % level_number)
	
