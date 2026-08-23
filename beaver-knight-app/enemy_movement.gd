extends CharacterBody2D

@export var move_speed: float = 2.0  # Passos por segundo
const TILE_SIZE: int = 16

var player: Node2D = null
var initial_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var percent_moved: float = 0.0
var target_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	initial_position = position
	# Procura o Player assim que o inimigo entra na árvore
	find_player()

func find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	# Se ainda não encontrou o player, tenta buscar de novo
	if player == null:
		find_player()
		return

	if is_moving:
		move_to_next_tile(delta)
	else:
		decide_next_move()

func decide_next_move() -> void:
	if player == null:
		return
		
	var diff = player.global_position - global_position
	
	# Se já está na mesma casa do player, aguarda
	if diff.length() < TILE_SIZE / 2.0:
		return
		
	# Trava a movimentação apenas para 1 eixo por vez (grid de tiles)
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
