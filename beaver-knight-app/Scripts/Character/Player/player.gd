extends CharacterBody2D

signal vida_mudou(atual: int, maximo: int)

# Configurações de Vida
@export var max_health: int = 100
var current_health: int
## Tempo sem receber dano depois de ser atingido.
@export var tempo_invencivel: float = 0.7
## Empurrão recebido ao levar dano.
@export var forca_recuo: float = 150.0

# Configurações de Ataque
@export var attack_damage: int = 25
var respawn_position: Vector2 = Vector2.ZERO

# Configurações de Movimento Livre
@export var walk_speed: float = 100.0
var direction : Vector2 = Vector2.ZERO
var can_move : bool = true
var is_moving : bool = false

## Ponto dos pés relativo à origem do Player (a origem já fica nos pés do sprite).
## É daqui que a colisão com água/caminhos/obstáculos do mapa é testada.
@export var pe_offset: Vector2 = Vector2(0, -2)
## Distância à frente dos pés usada para testar se o próximo tile bloqueia o movimento.
@export var distancia_sonda: float = 8.0

## Regras compartilhadas de terreno (ver RegrasTerreno).
var _regras: RegrasTerreno

## Trava o controle durante transições (ex.: passagem da caverna).
var travado: bool = false
var morto: bool = false

## Força do empurrão aplicado ao inimigo atingido.
@export var forca_knockback: float = 190.0
## O golpe sai do corpo do castor, um pouco acima da origem nos pés.
const AJUSTE_ATAQUE := Vector2(0, -8)
const ALCANCE_GOLPE := 28.0
const ALCANCE_COLADO := 12.0
## Duração máxima do ataque: libera o movimento mesmo se a animação for interrompida.
const DURACAO_ATAQUE := 0.5
## O `set_move(true)` do fim da animação só vale depois deste tempo de ataque.
const TEMPO_MINIMO_ATAQUE := 0.35
const RESISTENCIA_RECUO := 700.0

var _atacando := false
var _golpe_pendente := false
var _tempo_ataque := 0.0
var _invencivel := 0.0
var _recuo := Vector2.ZERO
var _tween_camera: Tween

# Referências de Animação
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D
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

	_regras = RegrasTerreno.de_cena(get_parent())

	# Inicialização segura do AnimationTree
	if has_node("AnimationTree"):
		anim_tree.active = true
		anim_state = anim_tree.get("parameters/playback")

		if anim_state == null:
			push_warning("O Root Node precisa ser um AnimationNodeStateMachine.")
		else:
			anim_state.travel("idle")
	else:
		push_error("Nó 'AnimationTree' não foi encontrado.")

# Função chamada pelo AnimationPlayer para tocar o efeito de passo sincronizado com os pés
func tocar_SFXPasso() -> void:
	if is_moving:
		var pitch_var = randf_range(0.9, 1.1)
		AudioManager.play_sfx(sfx_andar, -7.0, pitch_var)

func _physics_process(delta: float) -> void:
	_atualizar_invencibilidade(delta)
	if morto:
		return

	if travado:
		velocity = Vector2.ZERO
		_recuo = Vector2.ZERO
		is_moving = false
		if anim_state:
			anim_state.travel("idle")
		return

	if _atacando:
		_tempo_ataque += delta
		if _tempo_ataque >= DURACAO_ATAQUE:
			_finalizar_ataque()

	# 1. Checa o botão de ataque (bloqueia o movimento durante o golpe armado)
	if Input.is_action_just_pressed("attack") and can_move:
		attack_enemy()
		return

	# 2. Lógica de Movimentação Livre Contínua
	if can_move:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	else:
		direction = Vector2.ZERO

	_recuo = _recuo.move_toward(Vector2.ZERO, RESISTENCIA_RECUO * delta)
	velocity = direction * walk_speed + _recuo

	# 3. Barreira de Terreno (Água / Pontes):
	# Impede que o movimento contínuo entre em tiles de água desprovidos de ponte no caminho.
	# A checagem nos eixos X e Y independentes permite deslizar suavemente pelas margens.
	var feet_pos = global_position + pe_offset
	if velocity.x != 0:
		var test_x = feet_pos + Vector2(sign(velocity.x) * distancia_sonda, 0)
		if is_terrain_blocked(test_x):
			velocity.x = 0
	if velocity.y != 0:
		var test_y = feet_pos + Vector2(0, sign(velocity.y) * distancia_sonda)
		if is_terrain_blocked(test_y):
			velocity.y = 0

	update_blend(direction)
	movement_animation()
	move_and_slide()
	# Com stretch `canvas_items`, a câmera aceita frações de pixel e o sprite não (snap 2D).
	# Alinhar a câmera ao mesmo arredondamento do sprite evita que o castor trema na tela.
	camera.position = (global_position + Vector2(0.5, 0.5)).floor() - global_position

# --- FUNÇÕES DE MOVIMENTAÇÃO E ANIMAÇÃO ---

func update_blend(value: Vector2):
	if value == Vector2.ZERO:
		return

	update_facing_direction(value)

	anim_tree.set("parameters/idle/blend_position", value)
	anim_tree.set("parameters/walk/blend_position", value)
	anim_tree.set("parameters/attack_armed/blend_position", value)

## Verifica se um ponto do mapa bloqueia o movimento (regras em RegrasTerreno).
func is_terrain_blocked(target_world_pos: Vector2) -> bool:
	return _regras.bloqueado(target_world_pos)

## Controla a transição entre idle e walk baseada na velocidade efetiva
func movement_animation():
	if not can_move:
		is_moving = false
		# Durante o ataque só o recuo do dano ainda move o personagem.
		velocity = _recuo
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

## Chamado pelas animações. O idle também chama no início, então durante um ataque
## só vale depois do tempo mínimo (fim da animação de golpe).
func set_move(value: bool = true):
	if value and _atacando:
		if _tempo_ataque >= TEMPO_MINIMO_ATAQUE:
			_finalizar_ataque()
		return
	can_move = value

func set_travado(valor: bool) -> void:
	travado = valor

# --- ATAQUE ---

func attack_enemy() -> void:
	can_move = false
	_atacando = true
	_golpe_pendente = true
	_tempo_ataque = 0.0

	if anim_state:
		anim_state.travel("attack_armed")

	AudioManager.play_sfx(sfx_corte, 6.0)

## Chamado pela animação no quadro de impacto.
func aplicar_golpe() -> void:
	if not _golpe_pendente or morto:
		return
	_golpe_pendente = false

	var attack_vector = Vector2.ZERO
	match facing_direction:
		FacingDirection.LEFT: attack_vector = Vector2.LEFT
		FacingDirection.RIGHT: attack_vector = Vector2.RIGHT
		FacingDirection.UP: attack_vector = Vector2.UP
		FacingDirection.DOWN: attack_vector = Vector2.DOWN

	var acertou := false
	var origem_golpe := global_position + AJUSTE_ATAQUE
	for enemy in get_tree().get_nodes_in_group("enemies"):
		# Inimigos grandes informam o ponto do corpo mais próximo do golpe.
		var alvo: Vector2 = enemy.ponto_mais_proximo(origem_golpe) if enemy.has_method("ponto_mais_proximo") else enemy.global_position
		var distancia = origem_golpe.distance_to(alvo)
		var no_cone = distancia <= ALCANCE_GOLPE \
			and attack_vector.dot((alvo - origem_golpe).normalized()) > 0.3
		if distancia <= ALCANCE_COLADO or no_cone: # cone frontal de ~140 graus
			_acertar_inimigo(enemy, origem_golpe)
			acertou = true
	if acertou:
		tremer(1.0)

func _finalizar_ataque() -> void:
	aplicar_golpe()
	_golpe_pendente = false
	_atacando = false
	can_move = true

func _acertar_inimigo(enemy: Node2D, origem_golpe: Vector2) -> void:
	if enemy.has_method("apply_knockback"):
		enemy.apply_knockback(origem_golpe.direction_to(enemy.global_position) * forca_knockback)
	if enemy.has_method("take_damage"):
		enemy.take_damage(attack_damage)

# --- DANO E MORTE ---

func take_damage(amount: int, origem: Vector2 = Vector2.INF) -> void:
	if morto or _invencivel > 0.0:
		return
	current_health = maxi(current_health - amount, 0)
	vida_mudou.emit(current_health, max_health)
	AudioManager.play_sfx(sfx_dano, 5.0)
	_invencivel = tempo_invencivel
	tremer(2.0)
	if origem != Vector2.INF:
		_recuo = origem.direction_to(global_position) * forca_recuo

	if current_health <= 0:
		die()

func curar_total() -> void:
	current_health = max_health
	vida_mudou.emit(current_health, max_health)

func curar(quantidade: int) -> void:
	current_health = mini(current_health + quantidade, max_health)
	vida_mudou.emit(current_health, max_health)

func _atualizar_invencibilidade(delta: float) -> void:
	if _invencivel <= 0.0:
		return
	_invencivel -= delta
	sprite.modulate.a = 1.0 if _invencivel <= 0.0 or int(_invencivel * 14.0) % 2 == 0 else 0.35

func tremer(forca: float) -> void:
	if _tween_camera:
		_tween_camera.kill()
	_tween_camera = create_tween()
	for i in 3:
		var deslocamento := Vector2.from_angle(randf() * TAU) * forca * (1.0 - i / 3.0)
		_tween_camera.tween_property(camera, "offset", deslocamento, 0.035)
	_tween_camera.tween_property(camera, "offset", Vector2.ZERO, 0.035)

func die() -> void:
	var partida := get_tree().get_first_node_in_group(Partida.GRUPO) as Partida
	if partida == null:
		respawn()
		return
	morto = true
	_atacando = false
	_golpe_pendente = false
	can_move = false
	is_moving = false
	velocity = Vector2.ZERO
	sprite.modulate = Color(1.0, 0.45, 0.45, 1.0)
	partida.jogador_morreu()

func respawn() -> void:
	AudioManager.play_sfx(sfx_respawn, 4.0)
	is_moving = false
	direction = Vector2.ZERO
	can_move = true
	travado = false
	morto = false
	_atacando = false
	_golpe_pendente = false
	_recuo = Vector2.ZERO
	sprite.modulate = Color.WHITE

	if anim_state:
		anim_state.travel("idle")

	curar_total()
	global_position = respawn_position
