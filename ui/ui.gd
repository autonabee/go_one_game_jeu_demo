extends CanvasLayer

signal start_level # signal pour lancer une nouvelle partie
signal next_level # signal pour passer au niveau suivant
signal retry_level # signal pour recharger le niveau

func _on_start_button_pressed() -> void:
	"""
	Fonction reliée au signal pressed de StartButton
	Cache le bouton et le texte, émet le signal start_game
	"""
	game_screen()
	start_level.emit()

func _on_next_button_pressed() -> void:
	"""
	Fonction reliée au signal pressed de NextButton
	Cache le bouton et le texte, émet le signal start_game
	"""
	start_screen()
	next_level.emit()

func _on_retry_button_pressed() -> void:
	start_screen()
	retry_level.emit()

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main.tscn")

func start_screen() -> void:
	"""
	Fonction montrant les éléments de l'écran de début et cachant les autres
	"""
	$UIControl/StartButton.show()
	$UIControl/MenuButton.show()
	
	$UIControl/FinishLabel.hide()
	$UIControl/NextButton.hide()
	$UIControl/RetryButton.hide()
	$UIControl/BestScoreLabel.hide()
	$UIControl/ScoreLabel.hide()
	$UIControl/TimerLabel.hide()
	
	$UIControl/StartButton.grab_focus()
	
	$Background.hide()

func game_screen() -> void:
	"""
	Fonction montrant les éléments de l'écran pendant la partie et cachant les autres
	"""
	$UIControl/ScoreLabel.show()
	$UIControl/TimerLabel.show()
	
	$UIControl/FinishLabel.hide()
	$UIControl/NextButton.hide()
	$UIControl/RetryButton.hide()
	$UIControl/BestScoreLabel.hide()
	$UIControl/StartButton.hide()
	$UIControl/MenuButton.hide()
	
	$Background.hide()

func game_over_screen(win : bool, score : int) -> void:
	"""
	Fonction affichant l'écran de fin
	Arg :
		win : bool, true si le joueur finit le niveau avant la fin du timer, false sinon
		score : int, score du joueur
	"""
	$UIControl/MenuButton.show()
	$UIControl/StartButton.hide()
	$UIControl/ScoreLabel.hide()
	$UIControl/TimerLabel.hide()
	
	if win :
		$UIControl/FinishLabel.text = "Level \nComplete"
		$UIControl/FinishLabel.show()
		
		var best_score = Main.get_best_score(score)
		$UIControl/BestScoreLabel.text = "Score\n%s\nBest score\n%s" % [score, best_score]
		$UIControl/BestScoreLabel.show()
		
		$UIControl/RetryButton.hide()
		
		$UIControl/NextButton.show()
		$UIControl/NextButton.grab_focus()
	else :
		$UIControl/FinishLabel.text = "Game \nOver"
		$UIControl/FinishLabel.show()
		
		var best_score = Main.get_best_score(0)
		$UIControl/BestScoreLabel.text = "Score\n%s\nBest score\n%s" % [0, best_score]
		$UIControl/BestScoreLabel.show()
		
		$Background.show()
		$AnimationPlayer.play("game_over")
		await $AnimationPlayer.animation_finished
		
		$UIControl/RetryButton.show()
		$UIControl/RetryButton.grab_focus()
		get_tree().paused = true
