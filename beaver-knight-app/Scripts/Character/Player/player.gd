extends CharacterBody2D

# Configurações de Vida
@export var max_health: int = 100
var current_health: int

# Configurações de Ataque
@export var attack_damage: int = 25
var respawn_position: Vector2 = Vector2.ZERO

# Configurações de Movimento
@export var walk_speed: float = 4.0
const TILE_SIZE = 16

# Referências de Animação
@onready var anim_tree: AnimationTree = $AnimationTree
var anim_state: AnimationNodeStateMachinePlayback

# Referência de Colisão em Grid
@onready var ray_cast: RayCast2D = $RayCast2D

# Variáveis Sonoras
@export var sfx_dano: AudioStream
@export var sfx_corte: AudioStream
@export var sfx_andar: AudioStream
@export var sfx_respawn: AudioStream

# Enums de Estado e Direção
enum PlayerState { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

# Variáveis de Movimento
var initial_position = Vector2.ZERO
var input_direction = Vector2.ZERO
var move_direction = Vector2.ZERO
var is_moving = false
var percent_moved_to_next_tile = 0.0


func _ready() -> void:
	initial_position = position
	respawn_position = global_position
	current_health = max_health

	if not has_node("RayCast2D"):
		ray_cast = RayCast2D.new()
		ray_cast.name = "RayCast2D"
		add_child(ray_cast)

	if has_node("AnimationTree"):
		anim_tree = $AnimationTree
		anim_tree.active = true
		anim_state = anim_tree.get("parameters/playback")
		if anim_state == null:
			print("AVISO: O Root Node do AnimationTree precisa ser um AnimationNodeStateMachine.")
	else:
		print("ERRO: Nó 'AnimationTree' não foi encontrado como filho do Player.")

func tocar_SFXPasso():
	if is_moving:
		var pitch_var = randf_range(0.9, 1.1)
		AudioManager.play_sfx(sfx_andar, -36.0, pitch_var)
	
func _physics_process(delta: float) -> void:
	# Checa o ataque em paralelo em todo frame (não bloqueia o movimento)
	if Input.is_action_just_pressed("attack"):
		attack_enemy()

	if player_state == PlayerState.TURNING:
		return
		
	if is_moving:
		if anim_state:
			anim_state.travel("Walk")
		move(delta)
	else:
		process_player_movement_input()

func process_player_movement_input() -> void:
	input_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_direction.x = 1
	elif Input.is_action_pressed("ui_left"):
		input_direction.x = -1
	elif Input.is_action_pressed("ui_down"):
		input_direction.y = 1
	elif Input.is_action_pressed("ui_up"):
		input_direction.y = -1
	
	if input_direction != Vector2.ZERO:
		if anim_tree:
			anim_tree.set("parameters/Idle/blend_position", input_direction)
			anim_tree.set("parameters/Walk/blend_position", input_direction)
			anim_tree.set("parameters/Turn/blend_position", input_direction)
		
		if need_to_turn():
			player_state = PlayerState.TURNING
			if anim_state:
				anim_state.travel("Turn")
			get_tree().create_timer(0.15).timeout.connect(finished_turning)
		else:
			if can_move(input_direction):
				move_direction = input_direction
				initial_position = position
				is_moving = true
				player_state = PlayerState.WALKING
			else:
				reset_movement_state()
	else:
		reset_movement_state()

func can_move(dir: Vector2) -> bool:
	ray_cast.target_position = dir * TILE_SIZE
	ray_cast.force_raycast_update()
	return not ray_cast.is_colliding()

func need_to_turn() -> bool:
	var new_facing_direction = facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN

	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	
	return false

func finished_turning() -> void:
	if player_state == PlayerState.TURNING:
		player_state = PlayerState.IDLE

func move(delta: float) -> void:
	percent_moved_to_next_tile += walk_speed * delta
	
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * move_direction)
		reset_movement_state()
	else:
		position = initial_position + (TILE_SIZE * move_direction * percent_moved_to_next_tile)

func reset_movement_state() -> void:
	percent_moved_to_next_tile = 0.0
	is_moving = false
	move_direction = Vector2.ZERO
	player_state = PlayerState.IDLE
	if anim_state:
		anim_state.travel("Idle")

func attack_enemy() -> void:
	var attack_vector = Vector2.ZERO
	match facing_direction:
		FacingDirection.LEFT: attack_vector = Vector2.LEFT
		FacingDirection.RIGHT: attack_vector = Vector2.RIGHT
		FacingDirection.UP: attack_vector = Vector2.UP
		FacingDirection.DOWN: attack_vector = Vector2.DOWN

	AudioManager.play_sfx(sfx_corte, -22.0)
	
	# Calcula a posição do ataque com base no grid à frente do player
	var target_position = global_position + (attack_vector * TILE_SIZE)

	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(target_position) < (TILE_SIZE * 0.8):
			if enemy.has_method("take_damage"):
				enemy.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	current_health -= amount
	AudioManager.play_sfx(sfx_dano, -32.0)
	
	if current_health <= 0:
		die()

func die() -> void:
	respawn()

func respawn() -> void:
	AudioManager.play_sfx(sfx_respawn, -6.0)
	reset_movement_state()
	input_direction = Vector2.ZERO
	
	current_health = max_health
	global_position = respawn_position
	initial_position = respawn_position
