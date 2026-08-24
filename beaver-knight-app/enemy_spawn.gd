extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_area_min: Vector2 = Vector2(0, 0)
@export var spawn_area_max: Vector2 = Vector2(1000, 600)

# Limite máximo de inimigos simultâneos na cena
@export var max_enemies: int = 5 

const TILE_SIZE: int = 16

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	if enemy_scene == null:
		push_warning("Nenhuma cena de inimigo foi atribuída ao Spawner!")
		return
	
	# 1. Conta quantos inimigos do grupo "enemies" já existem na cena
	var current_enemies_count = get_tree().get_nodes_in_group("enemies").size()
	
	# 2. Se já atingiu ou passou do limite, interrompe a criação
	if current_enemies_count >= max_enemies:
		return
	
	# 3. Instancia o inimigo
	var enemy = enemy_scene.instantiate() as Node2D
	
	# 4. Garante que o novo inimigo faça parte do grupo "enemies"
	enemy.add_to_group("enemies")
	
	# 5. Adiciona o inimigo na cena principal
	get_tree().current_scene.add_child(enemy)
	
	# 6. Sorteia e alinha a posição à grade de 16px
	var raw_x = randf_range(spawn_area_min.x, spawn_area_max.x)
	var raw_y = randf_range(spawn_area_min.y, spawn_area_max.y)
	
	var aligned_x = snapped(raw_x, TILE_SIZE)
	var aligned_y = snapped(raw_y, TILE_SIZE)
	
	enemy.global_position = Vector2(aligned_x, aligned_y)
