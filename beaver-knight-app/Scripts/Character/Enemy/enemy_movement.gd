extends CharacterBody2D

@export var move_speed: float = 2.0  # Passos por segundo
const TILE_SIZE: int = 16

var player: Node2D = null
var initial_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var percent_moved: float = 0.0
var target_direction: Vector2 = Vector2.ZERO

@onready var ray_cast: RayCast2D = $RayCast2D

func _ready() -> void:
	initial_position = position
	
	# Se o RayCast2D não existir na cena, cria dinamicamente por segurança
	if not has_node("RayCast2D"):
		ray_cast = RayCast2D.new()
		ray_cast.name = "RayCast2D"
		add_child(ray_cast)
	
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
	if player == null:
		return
		
	var diff = player.global_position - global_position
	
	if diff.length() < TILE_SIZE / 2.0:
		return
		
	# Define a direção prioritária
	var primary_dir = Vector2.ZERO
	var secondary_dir = Vector2.ZERO

	if abs(diff.x) > abs(diff.y):
		primary_dir = Vector2(sign(diff.x), 0)
		secondary_dir = Vector2(0, sign(diff.y)) if diff.y != 0 else Vector2.ZERO
	else:
		primary_dir = Vector2(0, sign(diff.y))
		secondary_dir = Vector2(sign(diff.x), 0) if diff.x != 0 else Vector2.ZERO

	# Tenta andar na direção principal; se houver colisão, tenta a secundária
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
