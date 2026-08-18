extends Node2D

# Exporta a propriedade para selecionar a cena do inimigo pelo Inspector
@export var enemy_scene: PackedScene

# Exporta os limites da área onde os inimigos podem surgir
@export var spawn_area_min: Vector2 = Vector2(0, 0)
@export var spawn_area_max: Vector2 = Vector2(1000, 600)

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	# Conecta o sinal 'timeout' do Timer à função de spawn
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	# Verifica se a cena do inimigo foi configurada
	if enemy_scene == null:
		push_warning("Nenhuma cena de inimigo foi atribuída ao Spawner!")
		return
	
	# Instancia a cena do inimigo
	var enemy = enemy_scene.instantiate()
	
	# Gera uma posição aleatória dentro dos limites definidos
	var random_x = randf_range(spawn_area_min.x, spawn_area_max.x)
	var random_y = randf_range(spawn_area_min.y, spawn_area_max.y)
	enemy.global_position = Vector2(random_x, random_y)
	
	# Adiciona o inimigo à cena atual
	get_parent().add_child(enemy)
