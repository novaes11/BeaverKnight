extends CharacterBody2D

@export var move_speed: float = 2.0  # Passos por segundo
const TILE_SIZE: int = 16

## IDs de source no tipo_terreno que NÃO bloqueiam o movimento.
## Compartilhado com a lógica do Player — 5 = chão andável base.
const WALKABLE_TERRAIN_SOURCES: Array[int] = [5]

## Layer de terreno base — bloqueia água e tiles não-andáveis por source_id.
var _terrain_layer: TileMapLayer

## Layer de caminhos e pontes — presença de tile aqui libera o movimento
## mesmo que haja água no tipo_terreno abaixo (ex: atravessar uma ponte).
var _path_layer: TileMapLayer

## Todas as TileMapLayers bloqueadoras (construções, vegetação, etc.).
## Populado em _ready() iterando pelos filhos da cena raiz.
var _blocking_layers: Array[TileMapLayer] = []

var player: Node2D = null
var initial_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var percent_moved: float = 0.0
var target_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	initial_position = position
	# Procura o Player assim que o inimigo entra na árvore
	find_player()

	# Descobre os TileMapLayers da cena raiz usando a mesma lógica do Player.
	# O inimigo é adicionado via current_scene.add_child(), então get_parent()
	# retorna a cena raiz — onde os TileMapLayers também vivem.
	for child in get_parent().get_children():
		if not (child is TileMapLayer):
			continue
		var hint = child.name.to_lower()
		if "tipo" in hint:
			_terrain_layer = child as TileMapLayer
		elif "caminh" in hint:
			# Caminhos e pontes: presença de tile aqui LIBERA o movimento
			_path_layer = child as TileMapLayer
		else:
			# Construções, vegetação e demais layers bloqueiam o inimigo
			_blocking_layers.append(child as TileMapLayer)

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

## Decide o próximo tile a mover, verificando colisão antes de iniciar.
##
## Tenta a direção primária (eixo com maior diferença até o player).
## Se bloqueada, tenta a direção secundária (outro eixo).
## Se ambas estiverem bloqueadas, o inimigo aguarda no tile atual.
func decide_next_move() -> void:
	if player == null:
		return

	var diff = player.global_position - global_position

	# Se já está na mesma casa do player, aguarda
	if diff.length() < TILE_SIZE / 2.0:
		return

	# Determina direção primária (eixo dominante) e secundária (eixo alternativo).
	# Tentar o eixo dominante primeiro garante movimento mais direto ao player.
	var primary_dir: Vector2
	var secondary_dir: Vector2

	if abs(diff.x) > abs(diff.y):
		primary_dir   = Vector2(sign(diff.x), 0)
		secondary_dir = Vector2(0, sign(diff.y))
	else:
		primary_dir   = Vector2(0, sign(diff.y))
		secondary_dir = Vector2(sign(diff.x), 0)

	# Tenta mover na direção primária; se bloqueada, tenta a secundária.
	# Esse mecanismo permite contornar obstáculos simples (paredes, água).
	if can_move_to(position + primary_dir * TILE_SIZE):
		target_direction = primary_dir
	elif secondary_dir != Vector2.ZERO and can_move_to(position + secondary_dir * TILE_SIZE):
		target_direction = secondary_dir
	else:
		return  # Ambas as direções bloqueadas — aguarda sem mover

	initial_position = position
	is_moving = true

## Verifica se o inimigo pode entrar em um tile de destino.
##
## Lógica idêntica ao can_move_to() do Player:
##   0. Ponte (_path_layer): tile presente → LIBERA imediatamente (override).
##   1. Terreno base (_terrain_layer): source_id fora de WALKABLE_TERRAIN_SOURCES → BLOQUEIA.
##   2. Layers bloqueadoras (_blocking_layers): qualquer tile presente → BLOQUEIA.
##
## @param target_pos Vector2 — canto superior esquerdo do tile de destino.
## @return bool — true se livre; false se bloqueado.
func can_move_to(target_pos: Vector2) -> bool:
	## Centro do tile (+8px), evitando falsos positivos nas bordas entre tiles.
	var tile_center = target_pos + Vector2(8, 8)

	## 0. Ponte/caminho — override de maior prioridade.
	##    Tile de ponte libera o movimento mesmo sobre água.
	if _path_layer:
		var tile_coords = _path_layer.local_to_map(tile_center)
		if _path_layer.get_cell_source_id(tile_coords) != -1:
			return true

	## 1. Terreno base: bloqueia se source_id não for andável (ex: água).
	if _terrain_layer:
		var tile_coords = _terrain_layer.local_to_map(tile_center)
		var src = _terrain_layer.get_cell_source_id(tile_coords)
		if src != -1 and src not in WALKABLE_TERRAIN_SOURCES:
			return false

	## 2. Layers bloqueadoras: qualquer tile presente bloqueia o inimigo.
	for layer in _blocking_layers:
		var tile_coords = layer.local_to_map(tile_center)
		if layer.get_cell_source_id(tile_coords) != -1:
			return false

	## Nenhuma layer bloqueou → tile livre.
	return true

func move_to_next_tile(delta: float) -> void:
	percent_moved += move_speed * delta

	if percent_moved >= 1.0:
		position = initial_position + (target_direction * TILE_SIZE)
		percent_moved = 0.0
		is_moving = false
	else:
		position = initial_position + (target_direction * TILE_SIZE * percent_moved)

