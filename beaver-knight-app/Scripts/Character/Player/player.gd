extends CharacterBody2D

# Configurações de Vida
@export var max_health: int = 100
var current_health: int

# Configurações de Ataque
@export var attack_damage: int = 25
var respawn_position: Vector2 = Vector2.ZERO

# Configurações de Movimento (Atualizado para movimento livre)
@export var walk_speed: float = 100.0 # Ajustado para velocidade por pixels ao invés de grid
var direction : Vector2 = Vector2.ZERO
var can_move : bool = true
var is_moving : bool = false 

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

# Enums de Direção (Mantido para a sua lógica de ataque continuar funcionando)
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

# Função chamada pelo animationPlayer para tocar o efeito de passo
func tocar_SFXPasso():
	if is_moving:
		# Variação de tom para diminuir a repetição
		var pitch_var = randf_range(0.9, 1.1)
		AudioManager.play_sfx(sfx_andar, -36.0, pitch_var)
	
func _physics_process(_delta: float) -> void:
	# 1. Checa o botão de ataque
	if Input.is_action_just_pressed("attack") and can_move:
		attack_enemy()
		return

	# 2. Lógica de Movimentação Livre (Tutorial)
	if can_move:
		# get_vector captura as 4 direções e normaliza para não andar mais rápido na diagonal
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	# Calcula a velocidade final (direção * velocidade base)
	velocity = direction * walk_speed
	
	# Atualiza a direção das animações na árvore
	update_blend(direction)
	
	# Define se a animação vai ser Idle ou Walk
	movement_animation()
	
	# Aplica o movimento ao CharacterBody2D (substitui a matemática complexa de tiles)
	move_and_slide()

# --- NOVAS FUNÇÕES DE MOVIMENTAÇÃO ---

func update_blend(value: Vector2):
	if value == Vector2.ZERO:
		return
		
	# Converte a direção do movimento atual para a direção do ataque para não quebrar sua lógica
	update_facing_direction(value)
	
	# Atualiza o AnimationTree (substitua os nomes abaixo caso os seus se chamem diferente)
	anim_tree.set("parameters/idle/blend_position", value)
	anim_tree.set("parameters/walk/blend_position", value)
	anim_tree.set("parameters/attack_armed/blend_position", value)

func movement_animation():
	if not can_move:
		velocity = Vector2.ZERO
		is_moving = false
		return

	# is_zero_approx confere se a velocidade é quase 0 para trocar pro Idle
	if is_zero_approx(velocity.length()):
		is_moving = false
		if anim_state:
			anim_state.travel("idle")
	else:
		is_moving = true
		if anim_state:
			anim_state.travel("walk")

# Função auxiliar para manter a sua mecânica de dano apontada para o lado certo
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

# Função para destravar o jogador após o ataque
func set_move(value: bool = true):
	can_move = value


func attack_enemy() -> void:
	# Trava a movimentação durante o ataque
	can_move = false
	
	# Dispara a animação
	if anim_state:
		anim_state.travel("attack_armed") 
	
	var attack_vector = Vector2.ZERO
	match facing_direction:
		FacingDirection.LEFT: attack_vector = Vector2.LEFT
		FacingDirection.RIGHT: attack_vector = Vector2.RIGHT
		FacingDirection.UP: attack_vector = Vector2.UP
		FacingDirection.DOWN: attack_vector = Vector2.DOWN

	AudioManager.play_sfx(sfx_corte, -22.0)
	
	var attack_range = 16.0
	var target_position = global_position + (attack_vector * attack_range)

	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(target_position) < (attack_range / 2.0):
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
	is_moving = false
	direction = Vector2.ZERO
	can_move = true
	
	if anim_state:
		anim_state.travel("idle")
	
	current_health = max_health
	global_position = respawn_position
