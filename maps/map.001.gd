extends Node3D

var score: int
var timer: int 
var timeout_val: int = 10*60 # 90
var targets: Array[Node] # liste des cibles du niveau


func _ready() -> void:
	timer = timeout_val
	
	# Récupère les cibles dans le niveau pour les connecter au signal
	targets = get_tree().get_nodes_in_group("target")
	connect_map_signals()
	
	# Connecte le signal du timer
	$UI/UIControl/Timer.timeout.connect(_on_timer_timeout)

	# Cache l'interface
	$UI.start_screen()

	# Pause le jeu
	get_tree().paused = true


## Signaux
func _on_timer_timeout() -> void:
	"""
	Fonction connectée au signal timeout du timer
	Convertit les secondes en minutes et met à jour l'affichage du temps écoulé
	"""
	timer -= 1
	
	@warning_ignore("integer_division")
	var minute = str(timer / 60)
	var sec = str(timer % 60)
	minute = minute.pad_zeros(2)
	sec = sec.pad_zeros(2)
	$UI/UIControl/TimerLabel.text = "Timer\n%s:%s" % [minute,sec]
	
	if timer <= 0:
		$UI.game_over_screen(false,score)
		$UI/UIControl/Timer.stop()

func _on_target_target_hit(value: int) -> void:
	"""
	Fonction connectée au signal target_hit de chaque cible
	Récupère la valeur de la cible en argument
	Ajoute cette valeur au score et met à jour l'affichage
	"""
	score += value
	$UI/UIControl/ScoreLabel.text = "Score\n%s" % score

func _on_finish_area_body_entered(body: Node3D) -> void:
	"""
	Fonction reliée au signal body_entered de FinishArea
	Le signal est émis quand le joueur entre dans la zone qui marque la fin du niveau
	Affiche l'interface de fin en appelant la fonction game_over_screen
	"""
	# Vérifie que le corps détecté est un joueur
	if body.get_collision_layer() == 1:  
		$UI.game_over_screen(true, score)
		$UI/UIControl/Timer.stop()
		Main.unlock_next_level()
		Main.save_game()

func new_game(next: bool) -> void:
	"""
	Fonction reliée au signal start_game de l'UI
	Si l'argument next est vrai, charge le niveau suivant
	Sinon, réinitialise le niveau actuel
	"""
	if next : 
		Main.load_next_map()
	else :
		score = 0
		timer = timeout_val
		$Player.start($StartPosition.position)
		$UI.game_screen()
		$UI/UIControl/Timer.start()
		get_tree().paused = false

## Autres fonctions
func connect_map_signals() -> void:
	"""
	Connecte les éléments de la liste targets
	"""
	for t in targets:
		t.target_hit.connect(_on_target_target_hit)
	
	$UI.start_game.connect(new_game)
	$FinishArea.body_entered.connect(_on_finish_area_body_entered)
