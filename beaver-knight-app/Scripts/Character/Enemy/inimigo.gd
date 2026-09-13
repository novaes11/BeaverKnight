extends CharacterBody2D

# Configurações de Vida
@export var max_health: int = 50
var current_health: int

@export var move_speed: float = 2.0
@export var attack_cooldown: float = 1.0
const TILE_SIZE: int = 16

# Referências de Animação
@onready var anim_tree: AnimationTree = $AnimationTree
var anim_state: AnimationNodeStateMachinePlayback

# Referência de Colisão em Grid
@onready var ray_cast: RayCast2D = $RayCast2D

var player: Node2D = null
var initial_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_attacking: bool = false
var percent_moved: float = 0.0
var target_direction: Vector2 = Vector2.DOWN
var can_attack: bool = true

@export var sfx_morte: AudioStream

func _ready() -> void:
	initial_position = position
	current_health = max_health

	# Inicialização segura do RayCast2D
	if not has_node("RayCast2D"):
		ray_cast = RayCast2D.new()
		ray_cast.name = "RayCast2D"
		add_child(ray_cast)

	# Inicialização segura do AnimationTree
	if has_node("AnimationTree"):
		anim_tree = $AnimationTree
		anim_tree.active = true
		anim_state = anim_tree.get("parameters/playback")
		if anim_state:
			anim_state.start("slime")
	else:
		print("ERRO: Nó 'AnimationTree' não foi encontrado no Inimigo.")

	find_player()

func find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	if player == null:
		find_player()
		return

	# Garante que a animação 'slime' permaneça ativa
	if anim_state:
		anim_state.travel("slime")

	if is_moving:
		move_to_next_tile(delta)
	else:
		decide_next_move()

func decide_next_move() -> void:
	if player == null or is_attacking:
		return
		
	var diff = player.global_position - global_position
	var distance = diff.length()
	
	if distance <= TILE_SIZE:
		if can_attack:
			attack_player()
		return

	# Calcula os eixos de prioridade de movimento
	var primary_dir = Vector2.ZERO
	var secondary_dir = Vector2.ZERO

	if abs(diff.x) > abs(diff.y):
		primary_dir = Vector2(sign(diff.x), 0)
		secondary_dir = Vector2(0, sign(diff.y)) if diff.y != 0 else Vector2.ZERO
	else:
		primary_dir = Vector2(0, sign(diff.y))
		secondary_dir = Vector2(sign(diff.x), 0) if diff.x != 0 else Vector2.ZERO

	if can_move_in_direction(primary_dir):
		start_move(primary_dir)
	elif secondary_dir != Vector2.ZERO and can_move_in_direction(secondary_dir):
		start_move(secondary_dir)

func can_move_in_direction(dir: Vector2) -> bool:
	ray_cast.target_position = dir * TILE_SIZE
	ray_cast.force_raycast_update()
	return not ray_cast.is_colliding()

func start_move(dir: Vector2) -> void:
	target_direction = dir
	initial_position = position
	is_moving = true

func move_to_next_tile(delta: float) -> void:
	percent_moved += move_speed * delta
	
	if percent_moved >= 1.0:
		position = initial_position + (target_direction * TILE_SIZE)
		percent_moved = 0.0
		is_moving = false
	else:
		position = initial_position + (target_direction * TILE_SIZE * percent_moved)

func attack_player() -> void:
	is_attacking = true
	can_attack = false
	
	var diff = player.global_position - global_position
	if abs(diff.x) > abs(diff.y):
		target_direction = Vector2(sign(diff.x), 0)
	else:
		target_direction = Vector2(0, sign(diff.y))
	
	if player.has_method("take_damage"):
		player.take_damage(10)
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	is_attacking = false

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Inimigo recebeu dano! HP restante: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Inimigo derrotado!")
	var death_posi = global_position
	AudioManager.play_sfx_2d(sfx_morte, death_posi, -7.0)
	queue_free()
