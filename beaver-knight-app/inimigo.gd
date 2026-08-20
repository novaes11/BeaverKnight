extends CharacterBody2D

# Configurações de Vida do Inimigo
@export var max_health: int = 50
var current_health: int

@export var move_speed: float = 2.0
@export var attack_cooldown: float = 1.0
const TILE_SIZE: int = 16

var player: Node2D = null
var initial_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_attacking: bool = false
var percent_moved: float = 0.0
var target_direction: Vector2 = Vector2.ZERO
var can_attack: bool = true

func _ready() -> void:
	initial_position = position
	current_health = max_health # Inicializa o HP do inimigo
	find_player()

func find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	if player == null:
		find_player()
		return

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

	if abs(diff.x) > abs(diff.y):
		target_direction = Vector2(sign(diff.x), 0)
	else:
		target_direction = Vector2(0, sign(diff.y))
		
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
	
	if player.has_method("take_damage"):
		player.take_damage(10)
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	is_attacking = false

# FUNÇÃO NOVA: Inimigo recebe dano e morre
func take_damage(amount: int) -> void:
	current_health -= amount
	print("Inimigo recebeu dano! HP restante: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Inimigo derrotado!")
	queue_free() # Remove o nó do inimigo da árvore de cena
