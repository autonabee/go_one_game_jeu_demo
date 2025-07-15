extends Area3D

const SPEED := 5.0
const RANGE := 30.0

var travelled_distance := 0.0

func _physics_process(delta: float) -> void:
	position += transform.basis.z * SPEED * delta
	travelled_distance += SPEED * delta
	# si la balle dépasse une certaine distance, elle est supprimée
	if travelled_distance > RANGE :
		queue_free()
