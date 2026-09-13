extends CharacterBody2D

# Configurações de Vida
@export var max_health: int = 50
var current_health: int

# Configurações de Movimento Livre e Ataque
@export var move_speed: float = 70.0 # Velocidade em pixels por segundo
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0
@export var attack_range: float = 18.0
@export var knockback_resistance: float = 400.0 # Quão rápido se recupera de empurrões

# Variáveis do Inimigo
var player: Node2D = null
var is_moving: bool = false
var is_attacking: bool = false
var can_attack: bool = true
var target_direction: Vector2 = Vector2.DOWN

# Sistema de Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

# Referências de Animação
@onready var anim_tree: AnimationTree = $AnimationTree
var anim_state: AnimationNodeStateMachinePlayback

@export var sfx_morte: AudioStream


func _ready() -> void:
	current_health = max_health

	if has_node("AnimationTree"):
		anim_tree = $AnimationTree
		anim_tree.active = true
		anim_state = anim_tree.get("parameters/playback")
		if anim_state:
			anim_state.travel("slime")
	else:
		print("ERRO: Nó 'AnimationTree' não foi encontrado no Inimigo.")

	find_player()

func find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	# Processa dissipação do empurrão (Knockback)
	if knockback_velocity.length() > 10.0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_resistance * delta)
	else:
		knockback_velocity = Vector2.ZERO

	if player == null:
		find_player()
		velocity = knockback_velocity
		move_and_slide()
		return

	# Lógica principal de IA
	if not is_attacking:
		process_ai_behavior()

	# Aplica o movimento somando velocidade base com impactos externos
	move_and_slide()

func process_ai_behavior() -> void:
	var diff = player.global_position - global_position
	var distance = diff.length()
	
	if diff != Vector2.ZERO:
		target_direction = diff.normalized()
		update_animation_direction(target_direction)

	# Checa se está em alcance de ataque
	if distance <= attack_range:
		velocity = Vector2.ZERO + knockback_velocity
		is_moving = false
		if anim_state:
			anim_state.travel("slime")
			
		if can_attack:
			attack_player()
	else:
		# Persegue o Player
		is_moving = true
		velocity = (target_direction * move_speed) + knockback_velocity
		if anim_state:
			anim_state.travel("walk")

func update_animation_direction(direction: Vector2) -> void:
	if anim_tree and direction != Vector2.ZERO:
		anim_tree.set("parameters/slime/blend_position", direction)
		anim_tree.set("parameters/walk/blend_position", direction)

func attack_player() -> void:
	is_attacking = true
	can_attack = false
	
	# Leve avanço no momento do golpe
	velocity = target_direction * (move_speed * 0.5)

	if player and player.has_method("take_damage"):
		var current_distance = global_position.distance_to(player.global_position)
		if current_distance <= attack_range + 4.0:
			player.take_damage(attack_damage)

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	is_attacking = false

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Inimigo recebeu dano! HP restante: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	var death_posi = global_position
	AudioManager.play_sfx_2d(sfx_morte, death_posi, -7.0)
	queue_free()
