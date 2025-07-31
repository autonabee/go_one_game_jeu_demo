extends Node

# Variables pour sauvegarde du jeu
var save_path : String = "res://savegame.game"
var best_scores : Dictionary
var unlocked_levels : Array = ["1"]

func _ready():
	load_save() # charge le fichier de sauvegarde

func get_map_number() -> int:
	"""
	Fonction retournant le numéro du niveau actuel
	"""
	var current_map_path := get_tree().current_scene.scene_file_path # Récupère le chemin du niveau actuel
	var split_path := current_map_path.split(".")
	var current_map_number := split_path[1].to_int()
	return current_map_number

func get_best_score(score: int) -> int:
	"""
	Fonction retournant le meilleur score du niveau après l'avoir mis à jour
	Arg :
		score (int) : score actuel du niveau
	"""
	var key := str(get_map_number())
	best_scores[key] = best_scores.get(key) if best_scores.get(key) else 0
	if score > best_scores[key]: 
		best_scores[key] = score
	return best_scores[key]

func load_next_map() -> void:
	"""
	Fonction chargeant le niveau suivant
	"""
	var current_map_path := get_tree().current_scene.scene_file_path # Récupère le chemin du niveau actuel
	var split_path := current_map_path.split(".")
	var next_map_number := split_path[1].to_int() + 1 
	split_path[1] = str(next_map_number).pad_zeros(3)
	var next_map_path := ".".join(split_path) # Chemin du niveau suivant
	
	# S'il n'y a pas de niveau suivant, on repasse sur le premier
	if not ResourceLoader.exists(next_map_path):
		split_path[1] = "001"
		next_map_path = ".".join(split_path)
	
	ResourceLoader.load_threaded_request(next_map_path)
	
	get_tree().paused = true # Pause le jeu
	get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(next_map_path)
	)  # Charge le niveau suivant
	get_tree().paused = false # Relance le jeu

func unlock_next_level() -> void:
	"""
	Fonction ajoutant le niveau suivant à la liste des niveaux débloqués s'il n'y est pas déjà
	"""
	var next_num = get_map_number() + 1
	var map = "res://maps/map." + str(next_num).pad_zeros(3) + ".tscn"
	if str(next_num) not in unlocked_levels and ResourceLoader.exists(map) :
		unlocked_levels.append(str(next_num))

func save_game() -> void:
	"""
	Fonction sauvegardant les données de sauvegarde (best_scores, unlocked_levels) de manière persistante.
	"""
	var save_file = FileAccess.open(save_path, FileAccess.WRITE) # Ouvre le fichier de sauvegarde ou le crée
	
	var best_scores_json = JSON.stringify(best_scores) # Transforme le dictionnaire au format Json
	save_file.store_line(best_scores_json) # Sauvegarde dans le fichier
	
	var unlocked_levels_json = JSON.stringify(unlocked_levels)
	save_file.store_line(unlocked_levels_json)

func load_save() -> void:
	"""
	Fonction chargeant la sauvegarde des meilleurs scores et niveaux débloqués
	"""
	if not FileAccess.file_exists(save_path):
		return # Erreur, le fichier de sauvegarde n'existe pas
	
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	
	var save = [] # liste pour stocker les données extraites du fichier
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line() # Retourne la ligne du fichier où se trouve le curseur
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		save.append(json.data)
	
	# Récupère les valeurs sauvegardées
	best_scores = save[0]
	unlocked_levels = save[1]
