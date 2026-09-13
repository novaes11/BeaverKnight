extends CharacterBody2D

# Configurações de Vida
@export var max_health: int = 100
var current_health: int

# Configurações de Ataque
@export var attack_damage: int = 25
var respawn_position: Vector2 = Vector2.ZERO

# Configurações de Movimento
@export var walk_speed: float = 4.0
const TILE_SIZE = 16

## IDs de tile source no tipo_terreno que NÃO bloqueiam o movimento.
## 5 = source_id do terreno base andável (confirmado pelo debug log).
## Qualquer outro source_id no tipo_terreno será tratado como bloqueador (ex: água).
const WALKABLE_TERRAIN_SOURCES: Array[int] = [5]

## Layer de terreno base — verificada separadamente com lógica de source_id.
var _terrain_layer: TileMapLayer

## Layer de caminhos e pontes (caminho_terreno).
## Tiles presentes aqui LIBERAM o movimento mesmo sobre água ou outro bloqueador,
## pois representam pontes, estradas e superfícies andáveis artificiais.
var _path_layer: TileMapLayer

## Todas as outras TileMapLayers bloqueadoras (construções, vegetação, etc.).
## Qualquer tile presente nessas layers bloqueia o movimento do player.
## Populado em _ready() iterando pelos filhos da cena raiz.
var _blocking_layers: Array[TileMapLayer] = []

# Referências de Animação
@onready var anim_tree: AnimationTree = $AnimationTree
var anim_state: AnimationNodeStateMachinePlayback

# Enums de Estado e Direção
enum PlayerState { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

# Variáveis de Movimento
var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 0)
var is_moving = false
var percent_moved_to_next_tile = 0.0

func _ready() -> void:
	initial_position = position
	respawn_position = global_position
	current_health = max_health

	# Descobre os TileMapLayers da cena raiz e os categoriza:
	# - "tipo"   → terreno base (chão/água), tratado com lógica de source_id
	# - "caminh" → caminhos e pontes, liberam passagem mesmo sobre água
	# - demais   → bloqueadores (construções, vegetação, etc.)
	# Usa comparação ASCII parcial para evitar falhas de encoding
	# com nomes contendo caracteres especiais (ç, ã, õ, etc.).
	for child in get_parent().get_children():
		if not (child is TileMapLayer):
			continue
		var hint = child.name.to_lower()
		if "tipo" in hint:
			_terrain_layer = child as TileMapLayer
		elif "caminh" in hint:
			# Pontes e estradas ficam nessa layer — liberam passagem sobre água
			_path_layer = child as TileMapLayer
		else:
			# Construções, vegetação e outras layers bloqueiam o movimento
			_blocking_layers.append(child as TileMapLayer)

	if _terrain_layer == null:
		print("AVISO: TileMapLayer de terreno ('tipo_terreno') não encontrado.")
	else:
		print("OK: _terrain_layer → ", _terrain_layer.name)
	if _path_layer == null:
		print("AVISO: TileMapLayer de caminhos ('caminho_terreno') não encontrado.")
	else:
		print("OK: _path_layer → ", _path_layer.name)
	print("OK: _blocking_layers → ", _blocking_layers.map(func(l): return l.name))

	# Inicialização segura do AnimationTree
	if has_node("AnimationTree"):
		anim_tree = $AnimationTree
		anim_tree.active = true
		anim_state = anim_tree.get("parameters/playback")
		if anim_state == null:
			print("AVISO: O Root Node do AnimationTree precisa ser um AnimationNodeStateMachine.")
	else:
		print("ERRO: Nó 'AnimationTree' não foi encontrado como filho do Player.")


func _physics_process(delta: float) -> void:
	if player_state == PlayerState.TURNING:
		return
	elif is_moving == false:
		process_player_movement_input()
	elif input_direction != Vector2.ZERO:
		if anim_state:
			anim_state.travel("Walk")
		move(delta)
	else:
		if anim_state:
			anim_state.travel("Idle")
		is_moving = false

func process_player_movement_input() -> void:
	# Checa a tecla de ataque (Letra E mapeada como 'attack')
	if Input.is_action_just_pressed("attack"):
		attack_enemy()
		return

	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	if input_direction != Vector2.ZERO:
		if anim_tree:
			anim_tree.set("parameters/Idle/blend_position", input_direction)
			anim_tree.set("parameters/Walk/blend_position", input_direction)
			anim_tree.set("parameters/Turn/blend_position", input_direction)
		
		if need_to_turn():
			player_state = PlayerState.TURNING
			if anim_state:
				anim_state.travel("Turn")
		else:
			## Pré-verificação de colisão por tile:
			## Antes de autorizar o movimento, calcula onde o player chegaria
			## no próximo tile (posição atual + direção * tamanho do tile).
			## Se can_move_to() detectar um colisor nessa posição, o movimento
			## simplesmente não é iniciado — sem precisar desfazer nenhum passo.
			var target_pos = position + (TILE_SIZE * input_direction)
			if can_move_to(target_pos):
				## Posição salva como ponto de origem da interpolação de movimento.
				initial_position = position
				is_moving = true
	else:
		if anim_state:
			anim_state.travel("Idle")

func need_to_turn() -> bool:
	var new_facing_direction = facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN

	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	
	facing_direction = new_facing_direction
	return false

func finished_turning() -> void:
	player_state = PlayerState.IDLE

## Verifica se o player pode se mover para um determinado tile.
##
## Ordem de checagem (prioridade decrescente):
##   0. Ponte/caminho (_path_layer): se houver tile aqui, LIBERA imediatamente o
##      movimento — pontes sobrepõem a água no terreno base.
##   1. Terreno base (tipo_terreno): bloqueia se source_id não estiver em
##      WALKABLE_TERRAIN_SOURCES (ex: água = source != 5).
##   2. Layers bloqueadoras (construções, vegetação, etc.): bloqueia se
##      qualquer tile estiver presente na posição alvo.
##
## @param target_pos Vector2 — canto superior esquerdo do tile de destino.
## @return bool — true se o tile está livre; false se bloqueado.
func can_move_to(target_pos: Vector2) -> bool:
	## Centro do tile alvo (+8px). Evita falsos positivos nas bordas entre tiles.
	var tile_center = target_pos + Vector2(8, 8)

	## 0. Verifica ponte/caminho — override de maior prioridade.
	##    Se houver um tile de ponte ou estrada na posição destino, o movimento
	##    é liberado imediatamente, independente do que houver nas camadas abaixo.
	if _path_layer:
		var tile_coords = _path_layer.local_to_map(tile_center)
		if _path_layer.get_cell_source_id(tile_coords) != -1:
			return true  # Ponte detectada → passa mesmo sobre água

	## 1. Verifica o terreno base.
	##    Source IDs em WALKABLE_TERRAIN_SOURCES = andável (ex: 5 = chão base).
	##    Qualquer outro source_id presente (água, lava, etc.) bloqueia o movimento.
	if _terrain_layer:
		var tile_coords = _terrain_layer.local_to_map(tile_center)
		var src = _terrain_layer.get_cell_source_id(tile_coords)
		if src != -1 and src not in WALKABLE_TERRAIN_SOURCES:
			return false

	## 2. Verifica todas as layers bloqueadoras (construções, vegetação, etc.).
	##    Se qualquer uma tiver um tile na posição alvo, o movimento é bloqueado.
	##    Essa abordagem detecta tanto o interior quanto as bordas dos edifícios.
	for layer in _blocking_layers:
		var tile_coords = layer.local_to_map(tile_center)
		if layer.get_cell_source_id(tile_coords) != -1:
			return false

	## Nenhuma layer bloqueou → tile livre para mover.
	return true



func move(delta: float) -> void:
	percent_moved_to_next_tile += walk_speed * delta
	
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * input_direction)
		percent_moved_to_next_tile = 0.0
		is_moving = false
	else:
		position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)

func attack_enemy() -> void:
	var attack_vector = Vector2.ZERO
	match facing_direction:
		FacingDirection.LEFT: attack_vector = Vector2.LEFT
		FacingDirection.RIGHT: attack_vector = Vector2.RIGHT
		FacingDirection.UP: attack_vector = Vector2.UP
		FacingDirection.DOWN: attack_vector = Vector2.DOWN

	var target_position = global_position + (attack_vector * TILE_SIZE)

	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(target_position) < (TILE_SIZE / 2.0):
			if enemy.has_method("take_damage"):
				enemy.take_damage(attack_damage)
				print("Player atacou o inimigo!")

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Player recebeu dano! Vida restante: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Player morreu! Executando respawn...")
	respawn()

func respawn() -> void:
	is_moving = false
	percent_moved_to_next_tile = 0.0
	input_direction = Vector2.ZERO
	player_state = PlayerState.IDLE
	if anim_state:
		anim_state.travel("Idle")
	
	current_health = max_health
	global_position = respawn_position
	initial_position = respawn_position
