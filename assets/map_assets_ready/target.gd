extends Area3D

signal target_hit(val:int)

@export var value : int = 100

func _ready() -> void:
	$SubViewport/ValueLabel.text = str(value) # affiche la valeur de la cible

## Signal
func _on_area_entered(area: Area3D) -> void:
	"""
	Fonction reliée au signal area_entered de la cible
	Si l'area est une balle, la balle est supprimée et la fonction hit appelée
	"""
	if area.is_in_group("bullet"):
		area.queue_free()
		hit()

## Autre
func hit() -> void :
	"""
	Fonction appelée quand la cible est touchée
	Lance l'animation, supprime la cible et émet le signal target_hit
	"""
	$AnimationPlayer.play("target_hit")
	await $AnimationPlayer.animation_finished
	queue_free()
	target_hit.emit(value)
