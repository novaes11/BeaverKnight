extends CharacterBody2D

# Configurações de Vida
@export var max_health: int = 50
var current_health: int

@export var move_speed: float = 2.0
@export var attack_cooldown: float = 1.0
const TILE_SIZE: int = 16

# Referências de Animação
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

var player: Node2D = null
var initial_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_attacking: bool = false
var percent_moved: float = 0.0
var target_direction: Vector2 = Vector2.ZERO
var can_attack: bool = true

func _ready() -> void:
	anim_tree.active = true
	initial_position = position
	current_health = max_health
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
		anim_state.travel("Walk")
		move_to_next_tile(delta)
	else:
		anim_state.travel("Idle")
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

	# Calcula o eixo de maior distância
	if abs(diff.x) > abs(diff.y):
		target_direction = Vector2(sign(diff.x), 0)
	else:
		target_direction = Vector2(0, sign(diff.y))
		
	# Atualiza a direção no AnimationTree (Idle, Walk e Turn)
	update_animation_direction(target_direction)
	
	initial_position = position
	is_moving = true

func update_animation_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", direction)
		anim_tree.set("parameters/Walk/blend_position", direction)
		anim_tree.set("parameters/Turn/blend_position", direction)

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

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Inimigo recebeu dano! HP restante: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Inimigo derrotado!")
	queue_free()
