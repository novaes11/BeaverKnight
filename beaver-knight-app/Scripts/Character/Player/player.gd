extends CharacterBody2D

# Configurações de Vida
@export var max_health: int = 100
var current_health: int

# Configurações de Ataque
@export var attack_damage: int = 25
var respawn_position: Vector2 = Vector2.ZERO

# Configurações de Movimento Livre
@export var walk_speed: float = 100.0
var direction : Vector2 = Vector2.ZERO
var can_move : bool = true
var is_moving : bool = false 

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

# Variáveis Sonoras
@export var sfx_dano: AudioStream
@export var sfx_corte: AudioStream
@export var sfx_andar: AudioStream
@export var sfx_respawn: AudioStream

# Enums de Direção
enum FacingDirection { LEFT, RIGHT, UP, DOWN }
var facing_direction = FacingDirection.DOWN


func _ready() -> void:
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

	# Inicialização segura do AnimationTree
	if has_node("AnimationTree"):
		anim_tree = $AnimationTree
		anim_tree.active = true
		anim_state = anim_tree.get("parameters/playback")
		
		if anim_state == null:
			print("AVISO: O Root Node precisa ser um AnimationNodeStateMachine.")
		else:
			anim_state.travel("idle") 
	else:
		print("ERRO: Nó 'AnimationTree' não foi encontrado.")

# Função chamada pelo AnimationPlayer para tocar o efeito de passo sincronizado com os pés
func tocar_SFXPasso() -> void:
	if is_moving:
		var pitch_var = randf_range(0.9, 1.1)
		AudioManager.play_sfx(sfx_andar, -36.0, pitch_var)
	
func _physics_process(_delta: float) -> void:
	# 1. Checa o botão de ataque (bloqueia o movimento durante o golpe armado)
	if Input.is_action_just_pressed("attack") and can_move:
		attack_enemy()
		return

	# 2. Lógica de Movimentação Livre Contínua
	if can_move:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	else:
		direction = Vector2.ZERO
	
	velocity = direction * walk_speed
	
	# 3. Barreira de Terreno (Água / Pontes):
	# Impede que o movimento contínuo entre em tiles de água desprovidos de ponte no _path_layer.
	# A checagem nos eixos X e Y independentes permite deslizar suavemente pelas margens.
	var feet_pos = global_position + Vector2(30, 41)
	if velocity.x != 0:
		var test_x = feet_pos + Vector2(sign(velocity.x) * 10.0, 0)
		if is_terrain_blocked(test_x):
			velocity.x = 0
	if velocity.y != 0:
		var test_y = feet_pos + Vector2(0, sign(velocity.y) * 10.0)
		if is_terrain_blocked(test_y):
			velocity.y = 0
	
	update_blend(direction)
	movement_animation()
	move_and_slide()

# --- FUNÇÕES DE MOVIMENTAÇÃO E ANIMAÇÃO ---

func update_blend(value: Vector2):
	if value == Vector2.ZERO:
		return
		
	update_facing_direction(value)
	
	anim_tree.set("parameters/idle/blend_position", value)
	anim_tree.set("parameters/walk/blend_position", value)
	anim_tree.set("parameters/attack_armed/blend_position", value)

## Verifica se um determinado ponto no mapa está bloqueado por água ou terreno intransponível.
## - Pontes no _path_layer liberam passagem imediatamente (sobrepõem a água).
## - Água no _terrain_layer bloqueia se o source_id for diferente de 5 (terreno andável).
## - Layers bloqueadoras (vegetação/construções sem colisor nativo) impedem o movimento.
func is_terrain_blocked(target_world_pos: Vector2) -> bool:
	# 0. Pontes e caminhos liberam o movimento imediatamente
	if _path_layer:
		var tile_coords = _path_layer.local_to_map(_path_layer.to_local(target_world_pos))
		if _path_layer.get_cell_source_id(tile_coords) != -1:
			return false

	# 1. Verifica se o terreno base é andável (ex: água não está em WALKABLE_TERRAIN_SOURCES)
	if _terrain_layer:
		var tile_coords = _terrain_layer.local_to_map(_terrain_layer.to_local(target_world_pos))
		var src = _terrain_layer.get_cell_source_id(tile_coords)
		if src != -1 and src not in WALKABLE_TERRAIN_SOURCES:
			return true

	# 2. Camadas bloqueadoras adicionais
	for layer in _blocking_layers:
		var tile_coords = layer.local_to_map(layer.to_local(target_world_pos))
		if layer.get_cell_source_id(tile_coords) != -1:
			return true

	return false

## Controla a transição entre idle e walk baseada na velocidade efetiva
func movement_animation():
	if not can_move:
		velocity = Vector2.ZERO
		is_moving = false
		return

	if is_zero_approx(velocity.length()):
		is_moving = false
		if anim_state:
			anim_state.travel("idle")
	else:
		is_moving = true
		if anim_state:
			anim_state.travel("walk")

func update_facing_direction(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			facing_direction = FacingDirection.RIGHT
		else:
			facing_direction = FacingDirection.LEFT
	else:
		if dir.y > 0:
			facing_direction = FacingDirection.DOWN
		else:
			facing_direction = FacingDirection.UP

func set_move(value: bool = true):
	can_move = value

# --- ATAQUE MELHORADO ---

func attack_enemy() -> void:
	can_move = false
	
	if anim_state:
		anim_state.travel("attack_armed") 
	
	var attack_vector = Vector2.ZERO
	match facing_direction:
		FacingDirection.LEFT: attack_vector = Vector2.LEFT
		FacingDirection.RIGHT: attack_vector = Vector2.RIGHT
		FacingDirection.UP: attack_vector = Vector2.UP
		FacingDirection.DOWN: attack_vector = Vector2.DOWN

	AudioManager.play_sfx(sfx_corte, -22.0)
	
	# Configurações de alcance ajustadas
	var max_attack_distance: float = 28.0   # Alcance máximo do golpe
	var close_range_threshold: float = 12.0 # Inimigos colados acertam de qualquer ângulo
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var distance_to_enemy = global_position.distance_to(enemy.global_position)
		
		# 1. Acerta inimigos extremamente próximos (colados)
		if distance_to_enemy <= close_range_threshold:
			if enemy.has_method("take_damage"):
				enemy.take_damage(attack_damage)
				print("Player acertou inimigo próximo!")
			continue

		# 2. Acerta inimigos na frente dentro do cone de ataque
		if distance_to_enemy <= max_attack_distance:
			var dir_to_enemy = (enemy.global_position - global_position).normalized()
			var alignment = attack_vector.dot(dir_to_enemy)
			
			if alignment > 0.3: # Maior que 0.3 garante um cone de ~140 graus na frente
				if enemy.has_method("take_damage"):
					enemy.take_damage(attack_damage)
					print("Player acertou inimigo na frente!")

# --- DANO E MORTE ---

func take_damage(amount: int) -> void:
	current_health -= amount
	AudioManager.play_sfx(sfx_dano, -32.0)
	print("Player recebeu dano! Vida restante: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Player morreu! Executando respawn...")
	respawn()

func respawn() -> void:
	AudioManager.play_sfx(sfx_respawn, -6.0)
	is_moving = false
	direction = Vector2.ZERO
	can_move = true
	
	if anim_state:
		anim_state.travel("idle")
	
	current_health = max_health
	global_position = respawn_position
