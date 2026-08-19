extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_area_min: Vector2 = Vector2(0, 0)
@export var spawn_area_max: Vector2 = Vector2(1000, 600)

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
	
	# 1. Instancia o inimigo
	var enemy = enemy_scene.instantiate() as Node2D
	
	# 2. Adiciona o inimigo na cena principal PRIMEIRO
	get_tree().current_scene.add_child(enemy)
	
	# 3. Sorteia e alinha a posição à grade de 16px DEPOIS
	var raw_x = randf_range(spawn_area_min.x, spawn_area_max.x)
	var raw_y = randf_range(spawn_area_min.y, spawn_area_max.y)
	
	var aligned_x = snapped(raw_x, TILE_SIZE)
	var aligned_y = snapped(raw_y, TILE_SIZE)
	
	enemy.global_position = Vector2(aligned_x, aligned_y)
