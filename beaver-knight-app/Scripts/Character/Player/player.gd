extends CharacterBody2D

# Configurações de Vida
@export var max_health: int = 100
var current_health: int

# Configurações de Ataque
@export var attack_damage: int = 25
var respawn_position: Vector2 = Vector2.ZERO

# Configurações de Movimento Livre
@export var walk_speed: float = 100.0
var direction : Vector2 = Vector2.ZERO
var can_move : bool = true
var is_moving : bool = false 

# Referências de Animação
@onready var anim_tree: AnimationTree = $AnimationTree
var anim_state: AnimationNodeStateMachinePlayback

# Variáveis Sonoras
@export var sfx_dano: AudioStream
@export var sfx_corte: AudioStream
@export var sfx_andar: AudioStream
@export var sfx_respawn: AudioStream

# Enums de Direção
enum FacingDirection { LEFT, RIGHT, UP, DOWN }
var facing_direction = FacingDirection.DOWN


func _ready() -> void:
	respawn_position = global_position
	current_health = max_health

	if has_node("AnimationTree"):
		anim_tree = $AnimationTree
		anim_tree.active = true
		anim_state = anim_tree.get("parameters/playback")
		
		if anim_state == null:
			print("AVISO: O Root Node precisa ser um AnimationNodeStateMachine.")
		else:
			anim_state.travel("idle") 
	else:
		print("ERRO: Nó 'AnimationTree' não foi encontrado.")

# Função chamada pelo AnimationPlayer para tocar o efeito de passo
func tocar_SFXPasso():
	if is_moving:
		var pitch_var = randf_range(0.9, 1.1)
		AudioManager.play_sfx(sfx_andar, -36.0, pitch_var)
	
func _physics_process(_delta: float) -> void:
	# 1. Checa o botão de ataque
	if Input.is_action_just_pressed("attack") and can_move:
		attack_enemy()
		return

	# 2. Lógica de Movimentação Livre
	if can_move:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	velocity = direction * walk_speed
	
	update_blend(direction)
	movement_animation()
	move_and_slide()

# --- FUNÇÕES DE MOVIMENTAÇÃO E ANIMAÇÃO ---

func update_blend(value: Vector2):
	if value == Vector2.ZERO:
		return
		
	update_facing_direction(value)
	
	anim_tree.set("parameters/idle/blend_position", value)
	anim_tree.set("parameters/walk/blend_position", value)
	anim_tree.set("parameters/attack_armed/blend_position", value)

func movement_animation():
	if not can_move:
		velocity = Vector2.ZERO
		is_moving = false
		return

	if is_zero_approx(velocity.length()):
		is_moving = false
		if anim_state:
			anim_state.travel("idle")
	else:
		is_moving = true
		if anim_state:
			anim_state.travel("walk")

func update_facing_direction(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			facing_direction = FacingDirection.RIGHT
		else:
			facing_direction = FacingDirection.LEFT
	else:
		if dir.y > 0:
			facing_direction = FacingDirection.DOWN
		else:
			facing_direction = FacingDirection.UP

func set_move(value: bool = true):
	can_move = value

# --- ATAQUE MELHORADO ---

func attack_enemy() -> void:
	can_move = false
	
	if anim_state:
		anim_state.travel("attack_armed") 
	
	var attack_vector = Vector2.ZERO
	match facing_direction:
		FacingDirection.LEFT: attack_vector = Vector2.LEFT
		FacingDirection.RIGHT: attack_vector = Vector2.RIGHT
		FacingDirection.UP: attack_vector = Vector2.UP
		FacingDirection.DOWN: attack_vector = Vector2.DOWN

	AudioManager.play_sfx(sfx_corte, -22.0)
	
	# Configurações de alcance ajustadas
	var max_attack_distance: float = 28.0   # Alcance máximo do golpe
	var close_range_threshold: float = 12.0 # Inimigos colados acertam de qualquer ângulo
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var distance_to_enemy = global_position.distance_to(enemy.global_position)
		
		# 1. Acerta inimigos extremamente próximos (colados)
		if distance_to_enemy <= close_range_threshold:
			if enemy.has_method("take_damage"):
				enemy.take_damage(attack_damage)
				print("Player acertou inimigo próximo!")
			continue

		# 2. Acerta inimigos na frente dentro do cone de ataque
		if distance_to_enemy <= max_attack_distance:
			var dir_to_enemy = (enemy.global_position - global_position).normalized()
			var alignment = attack_vector.dot(dir_to_enemy)
			
			if alignment > 0.3: # Maior que 0.3 garante um cone de ~140 graus na frente
				if enemy.has_method("take_damage"):
					enemy.take_damage(attack_damage)
					print("Player acertou inimigo na frente!")

# --- DANO E MORTE ---

func take_damage(amount: int) -> void:
	current_health -= amount
	AudioManager.play_sfx(sfx_dano, -32.0)
	print("Player recebeu dano! Vida restante: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Player morreu! Executando respawn...")
	respawn()

func respawn() -> void:
	AudioManager.play_sfx(sfx_respawn, -6.0)
	is_moving = false
	direction = Vector2.ZERO
	can_move = true
	
	if anim_state:
		anim_state.travel("idle")
	
	current_health = max_health
	global_position = respawn_position
