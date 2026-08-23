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

# Enums de Estado e Direção
enum PlayerState { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

# Variáveis de Movimento
var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 0)
var is_moving = false
var percent_moved_to_next_tile = 0.0

func _ready() -> void:
	initial_position = position
	respawn_position = global_position
	current_health = max_health

	# Inicialização segura do AnimationTree
	if has_node("AnimationTree"):
		anim_tree = $AnimationTree
		anim_tree.active = true
		anim_state = anim_tree.get("parameters/playback")
		if anim_state == null:
			print("AVISO: O Root Node do AnimationTree precisa ser um AnimationNodeStateMachine.")
	else:
		print("ERRO: Nó 'AnimationTree' não foi encontrado como filho do Player.")

func _physics_process(delta: float) -> void:
	if player_state == PlayerState.TURNING:
		return
	elif is_moving == false:
		process_player_movement_input()
	elif input_direction != Vector2.ZERO:
		if anim_state:
			anim_state.travel("Walk")
		move(delta)
	else:
		if anim_state:
			anim_state.travel("Idle")
		is_moving = false

func process_player_movement_input() -> void:
	# Checa a tecla de ataque (Letra E mapeada como 'attack')
	if Input.is_action_just_pressed("attack"):
		attack_enemy()
		return

	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	if input_direction != Vector2.ZERO:
		if anim_tree:
			anim_tree.set("parameters/Idle/blend_position", input_direction)
			anim_tree.set("parameters/Walk/blend_position", input_direction)
			anim_tree.set("parameters/Turn/blend_position", input_direction)
		
		if need_to_turn():
			player_state = PlayerState.TURNING
			if anim_state:
				anim_state.travel("Turn")
		else:
			initial_position = position
			is_moving = true
	else:
		if anim_state:
			anim_state.travel("Idle")

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
	
	facing_direction = new_facing_direction
	return false

func finished_turning() -> void:
	player_state = PlayerState.IDLE

func move(delta: float) -> void:
	percent_moved_to_next_tile += walk_speed * delta
	
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * input_direction)
		percent_moved_to_next_tile = 0.0
		is_moving = false
	else:
		position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)

func attack_enemy() -> void:
	var attack_vector = Vector2.ZERO
	match facing_direction:
		FacingDirection.LEFT: attack_vector = Vector2.LEFT
		FacingDirection.RIGHT: attack_vector = Vector2.RIGHT
		FacingDirection.UP: attack_vector = Vector2.UP
		FacingDirection.DOWN: attack_vector = Vector2.DOWN

	var target_position = global_position + (attack_vector * TILE_SIZE)

	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(target_position) < (TILE_SIZE / 2.0):
			if enemy.has_method("take_damage"):
				enemy.take_damage(attack_damage)
				print("Player atacou o inimigo!")

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Player recebeu dano! Vida restante: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Player morreu! Executando respawn...")
	respawn()

func respawn() -> void:
	is_moving = false
	percent_moved_to_next_tile = 0.0
	input_direction = Vector2.ZERO
	player_state = PlayerState.IDLE
	if anim_state:
		anim_state.travel("Idle")
	
	current_health = max_health
	global_position = respawn_position
	initial_position = respawn_position
