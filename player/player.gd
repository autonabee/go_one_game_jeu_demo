extends CharacterBody3D

var move_speed := 4.0
var acceleration := 5.0
var rotation_speed := 2.0
var jump_impulse := 12.0

var x_dampening := 0.2

var last_movement_direction := Vector3.BACK
var gravity := -30.0
var spawn_position:= Vector3.ZERO # Position ou le joueur réapparaît après une chute

@onready var _skin:  SophiaSkin = %SophiaSkin
@onready var _cam_pivot: Node3D = %CameraPivot
@onready var _cam: Camera3D = %Camera3D
@onready var _gun_pivot: Node3D = %GunPivot

func _ready() -> void:
	spawn_position = position # Initie spawn_position a la position de départ

func _physics_process(delta: float) -> void:
	"""
	Fonction appelée à chaque frame, traite les processus physiques
	On l'utilise pour déplacer le joueur
	"""
	## Deplacements 
	#  Le joueur doit se déplacer relativement à la caméra
	var raw_input := Input.get_vector("move_left","move_right","move_forward","move_back")
	var forward := _cam.global_basis.z
	var right := _cam.global_basis.x
	
	# Créer un vecteur de direction selon la base de la caméra
	var move_direction := forward * raw_input.y + right * raw_input.x * x_dampening # Diminuer la sensibilité sur l'axe x
	move_direction.y = 0.0 # Annuler les déplacements sur l'axe y
	move_direction = move_direction.normalized()
	
	var y_velocity := velocity.y # Récupérer valeur pour les chutes
	velocity.y = 0.0 # Pas de déplacement selon l'axe y
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta) # prend la valeur progressivement
	
	## Chute
	velocity.y = y_velocity + gravity * delta 
	
	# Ramener sur le plateau avant chute
	if is_on_floor():
		spawn_position = position # Recupère position si le joueur est sur le sol
	elif position.y <= -15.0:
		position = spawn_position # Replace à position avant chute
		velocity.y = 0.0
	
	## Sauter
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	
	move_and_slide()
	
	## Rotation
	if move_direction.length() > 0.2:
		# Vérifie que le joueur est en mouvement et recupère le dernier déplacement
		last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(last_movement_direction, Vector3.UP) # Angle entre le dernier déplacement et le déplacement actuel
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta) # Rotation progressive vers l'angle visé
	_cam_pivot.global_rotation.y = lerp_angle(_cam_pivot.rotation.y, target_angle, 2*delta) # Rotation de la camera
	
	## Collision avec un obstacle
	collision_with_obstacle()
	
	## Orienter le pistoler
	var aim_input := Input.get_vector("aim_right", "aim_left", "aim_up", "aim_down")
	_gun_pivot.rotation.x = lerp_angle(_gun_pivot.rotation.x,aim_input.y, rotation_speed*delta)
	_gun_pivot.rotation.y = lerp_angle(_gun_pivot.rotation.y,aim_input.x, rotation_speed*delta)
	_gun_pivot.rotation.x = clamp(_gun_pivot.rotation.x, -PI/6, PI/6)
	_gun_pivot.rotation.y = clamp(_gun_pivot.rotation.y, -PI/4, PI/4)
	
	## Tirer
	if Input.is_action_just_pressed("shoot"):
		shoot_bullet()
	
	play_animation()


func play_animation() -> void:
	"""
	Joue les animations de mouvement adaptées
	"""
	# Vérifie si le joueur tombe
	if not is_on_floor() and velocity.y < 0: 
		_skin.fall()
	
	elif is_on_floor():
		var ground_speed := velocity.length()
		# Vérifie si le joueur est en mouvement ou pas et joue les animations dans chaque cas
		if ground_speed > 0.0: 
			_skin.move()
		else:
			_skin.idle() 

func jump()->void:
	"""
	Sauter et jouer l'animation
	"""
	velocity.y += jump_impulse 
	_skin.jump()

func collision_with_obstacle() -> void:
	"""
	Repousse le joueur quand il heurte un obstacle
	""" 
	# Parcourt toutes les collisions qui se sont produites au cours de cette frame
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		
		# Vérifie l'objet heurté
		if collision.get_collider() == null:
			continue
		# Si c'est un obstacle, le joueur est repoussé
		if collision.get_collider().is_in_group("obstacle"):
			var normal = collision.get_normal()
			# Vérifie si joueur vient de dessus l'obstacle et si oui le repousse en arrière
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				velocity =  (normal + _cam.global_basis.z*0.5) * move_speed
			else:
				velocity = normal * move_speed
			
			break

func shoot_bullet() -> void:
	"""
	Ajouter une nouvelle balle au niveau du pistolet
	Jouer l'animation du pistolet
	"""
	const BULLET_3D = preload("res://player/gun/bullet_3d.tscn")
	var new_bullet = BULLET_3D.instantiate()
	%Marker3D.add_child(new_bullet)
	new_bullet.global_transform = %Marker3D.global_transform
	
	$SophiaSkin/GunPivot/gun_model/AnimationPlayer.play("recoil")

func start(pos : Vector3) -> void:
	"""
	Initialise le joueur a la position voulue
	Rend la node visible
	"""
	position = pos
	show()
