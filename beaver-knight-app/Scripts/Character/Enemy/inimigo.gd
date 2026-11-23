extends CharacterBody2D
## Inimigo com estados: patrulha, perseguição (A*), aviso + ataque, recuperação e retorno.

enum Estado { PATRULHA, PERSEGUICAO, AVISO, RECUPERACAO, RETORNO }

# Configurações de Vida
@export var max_health: int = 50
var current_health: int

# Movimento
@export var move_speed: float = 62.0
@export var velocidade_patrulha: float = 26.0
@export var raio_patrulha: float = 48.0
@export var knockback_resistance: float = 520.0 # Quão rápido se recupera de empurrões

# Percepção
@export var raio_visao: float = 110.0
@export var raio_perda: float = 180.0
@export var intervalo_caminho: float = 0.4

# Ataque
@export var attack_damage: int = 10
@export var attack_range: float = 18.0
@export var tempo_aviso: float = 0.25
@export var attack_cooldown: float = 0.9

@export var sfx_morte: AudioStream

const COR_AVISO := Color(1.7, 0.65, 0.65)
const COR_DANO := Color(2.2, 2.2, 2.2)
const DISTANCIA_SEPARACAO := 16.0
const FORCA_SEPARACAO := 34.0
## O alvo é o corpo do Player, um pouco acima da origem nos pés.
const AJUSTE_ALVO := Vector2(0, -4)

var player: Node2D = null
var estado: Estado = Estado.PATRULHA
var knockback_velocity: Vector2 = Vector2.ZERO

var _nav: MapaNavegacao
var _origem: Vector2
var _zona := Rect2()
var _tem_zona := false
var _cacando := false
var _caminho := PackedVector2Array()
var _indice_caminho := 0
var _tempo_caminho := 0.0
var _tempo_estado := 0.0
var _destino_patrulha: Variant = null
var _barra: BarraVida
var _morto := false

# Referências de Animação
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $DeathSlime
var anim_state: AnimationNodeStateMachinePlayback


## Chamado pelo spawner antes de o inimigo entrar na cena.
func configurar(origem: Vector2, zona: Rect2, cacar: bool = false) -> void:
	_origem = origem
	_zona = zona
	_tem_zona = true
	_cacando = cacar


func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	if not _tem_zona:
		_origem = global_position
	_tempo_caminho = randf() * intervalo_caminho
	_tempo_estado = randf_range(0.2, 1.2)
	_nav = get_tree().get_first_node_in_group(MapaNavegacao.GRUPO) as MapaNavegacao

	if has_node("AnimationTree"):
		anim_tree.active = true
		anim_state = anim_tree.get("parameters/playback")
		_ir_para_estado(&"slime")
	else:
		push_warning("Nó 'AnimationTree' não foi encontrado no Inimigo.")

	_barra = BarraVida.new()
	_barra.position = Vector2(0, -13)
	add_child(_barra)
	_barra.definir(current_health, max_health)

	# Surge crescendo, para o nascimento não parecer um corte seco.
	sprite.scale = Vector2(0.2, 0.2)
	create_tween().tween_property(sprite, "scale", Vector2.ONE, 0.25)

	find_player()


func find_player() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D


func _physics_process(delta: float) -> void:
	if _morto:
		return
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_resistance * delta)
	if player == null:
		find_player()

	var desejada := Vector2.ZERO
	match estado:
		Estado.PATRULHA:
			desejada = _patrulhar(delta)
		Estado.PERSEGUICAO:
			desejada = _perseguir(delta)
		Estado.AVISO:
			_avisar(delta)
		Estado.RECUPERACAO:
			_recuperar(delta)
		Estado.RETORNO:
			desejada = _retornar(delta)

	if desejada != Vector2.ZERO:
		desejada += _separacao()
		_definir_blend(&"walk", desejada.normalized())

	velocity = desejada + _knockback_seguro()
	move_and_slide()


# --- ESTADOS ---

func _patrulhar(delta: float) -> Vector2:
	if _pode_engajar():
		_mudar_estado(Estado.PERSEGUICAO)
		return Vector2.ZERO

	if _destino_patrulha == null:
		_tempo_estado -= delta
		if _tempo_estado <= 0.0:
			_escolher_destino_patrulha()
		return Vector2.ZERO

	var destino: Vector2 = _destino_patrulha
	if global_position.distance_to(destino) <= 6.0:
		_destino_patrulha = null
		_tempo_estado = randf_range(0.8, 2.2)
		return Vector2.ZERO
	var movimento := _seguir_caminho(destino, velocidade_patrulha, delta)
	if movimento == Vector2.ZERO:
		_destino_patrulha = null
		_tempo_estado = randf_range(0.8, 2.2)
	return movimento


func _perseguir(delta: float) -> Vector2:
	if not _alvo_valido():
		_mudar_estado(Estado.RETORNO)
		return Vector2.ZERO
	var alvo := _posicao_alvo()
	if global_position.distance_to(alvo) <= attack_range:
		_mudar_estado(Estado.AVISO)
		return Vector2.ZERO
	return _seguir_caminho(alvo, move_speed, delta)


func _avisar(delta: float) -> void:
	_tempo_estado -= delta
	if _tempo_estado > 0.0:
		return
	sprite.modulate = Color.WHITE
	if player and player.has_method("take_damage") \
			and global_position.distance_to(_posicao_alvo()) <= attack_range + 6.0:
		player.take_damage(attack_damage, global_position)
	_mudar_estado(Estado.RECUPERACAO)


func _recuperar(delta: float) -> void:
	_tempo_estado -= delta
	if _tempo_estado <= 0.0:
		_mudar_estado(Estado.PERSEGUICAO if _alvo_valido() else Estado.RETORNO)


func _retornar(delta: float) -> Vector2:
	if _pode_engajar():
		_mudar_estado(Estado.PERSEGUICAO)
		return Vector2.ZERO
	if global_position.distance_to(_origem) <= 10.0:
		_recuperar_vida()
		_mudar_estado(Estado.PATRULHA)
		return Vector2.ZERO
	var movimento := _seguir_caminho(_origem, move_speed * 0.8, delta)
	if movimento == Vector2.ZERO:
		_recuperar_vida()
		_origem = global_position
		_mudar_estado(Estado.PATRULHA)
	return movimento


func _recuperar_vida() -> void:
	current_health = max_health
	_barra.definir(current_health, max_health)


func _mudar_estado(novo: Estado) -> void:
	estado = novo
	_caminho = PackedVector2Array()
	_indice_caminho = 0
	_tempo_caminho = 0.0
	match novo:
		Estado.PATRULHA:
			_destino_patrulha = null
			_tempo_estado = randf_range(0.5, 1.5)
		Estado.AVISO:
			_tempo_estado = tempo_aviso
			sprite.modulate = COR_AVISO
		Estado.RECUPERACAO:
			_tempo_estado = attack_cooldown
		_:
			sprite.modulate = Color.WHITE


# --- PERCEPÇÃO ---

func _posicao_alvo() -> Vector2:
	return player.global_position + AJUSTE_ALVO if player else global_position


func _na_zona(ponto: Vector2) -> bool:
	return not _tem_zona or _cacando or _zona.grow(48.0).has_point(ponto)


func _alcancavel(ponto: Vector2) -> bool:
	return _nav != null and _nav.pronto and _nav.conectados(global_position, ponto)


func _pode_engajar() -> bool:
	if player == null:
		return false
	var alvo := _posicao_alvo()
	return (_cacando or global_position.distance_to(alvo) <= raio_visao) and _na_zona(alvo) and _alcancavel(alvo)


func _alvo_valido() -> bool:
	if player == null:
		return false
	var alvo := _posicao_alvo()
	return (_cacando or global_position.distance_to(alvo) <= raio_perda) and _na_zona(alvo) and _alcancavel(alvo)


# --- MOVIMENTO ---

func _seguir_caminho(destino: Vector2, velocidade: float, delta: float) -> Vector2:
	if _nav == null or not _nav.pronto:
		return Vector2.ZERO
	_tempo_caminho -= delta
	if _tempo_caminho <= 0.0 or _caminho.is_empty():
		_caminho = _nav.caminho(global_position, destino)
		_indice_caminho = 0
		_tempo_caminho = intervalo_caminho + randf() * 0.1
	while _indice_caminho < _caminho.size() \
			and global_position.distance_to(_caminho[_indice_caminho]) <= 5.0:
		_indice_caminho += 1
	if _indice_caminho >= _caminho.size():
		return Vector2.ZERO
	return global_position.direction_to(_caminho[_indice_caminho]) * velocidade


func _escolher_destino_patrulha() -> void:
	_tempo_estado = randf_range(0.8, 1.6)
	if _nav == null or not _nav.pronto:
		return
	for _tentativa in 8:
		var ponto := _origem + Vector2.from_angle(randf() * TAU) * randf_range(16.0, raio_patrulha)
		if _nav.ponto_livre(ponto) and _nav.conectados(global_position, ponto):
			_destino_patrulha = ponto
			return


## Afasta levemente de outros inimigos próximos para não formar uma pilha.
func _separacao() -> Vector2:
	var empurrao := Vector2.ZERO
	for outro in get_tree().get_nodes_in_group("enemies"):
		if outro == self:
			continue
		var diferenca: Vector2 = global_position - outro.global_position
		var distancia := diferenca.length()
		if distancia > 0.01 and distancia < DISTANCIA_SEPARACAO:
			empurrao += diferenca / distancia * (1.0 - distancia / DISTANCIA_SEPARACAO)
	return empurrao * FORCA_SEPARACAO


## Knockback não empurra o inimigo para dentro de água ou obstáculos.
func _knockback_seguro() -> Vector2:
	if knockback_velocity == Vector2.ZERO or _nav == null or not _nav.pronto:
		return knockback_velocity
	if not _nav.ponto_livre(global_position + knockback_velocity.normalized() * 8.0):
		knockback_velocity = Vector2.ZERO
	return knockback_velocity


# --- ANIMAÇÃO ---

## Viaja para um estado da AnimationTree somente se ele existir e ainda não for o atual.
## Evita os erros "_make_travel_path ... states.has(travel)" / "No such node: 'walk'".
func _ir_para_estado(nome: StringName) -> void:
	if anim_state == null or anim_tree == null:
		return
	var maquina := anim_tree.tree_root as AnimationNodeStateMachine
	if maquina == null or not maquina.has_node(nome):
		return
	if anim_state.get_current_node() != nome:
		anim_state.travel(nome)


## Define o blend_position apenas se o estado existir e for um BlendSpace2D.
func _definir_blend(nome: StringName, direcao: Vector2) -> void:
	if anim_tree == null:
		return
	var maquina := anim_tree.tree_root as AnimationNodeStateMachine
	if maquina and maquina.has_node(nome) and maquina.get_node(nome) is AnimationNodeBlendSpace2D:
		anim_tree.set("parameters/%s/blend_position" % nome, direcao)


# --- DANO ---

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force


func take_damage(amount: int) -> void:
	if _morto:
		return
	current_health = maxi(current_health - amount, 0)
	_barra.definir(current_health, max_health)
	if current_health <= 0:
		die()
		return
	sprite.modulate = COR_DANO
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.14)
	if estado == Estado.PATRULHA or estado == Estado.RETORNO:
		_mudar_estado(Estado.PERSEGUICAO)


func die() -> void:
	_morto = true
	remove_from_group("enemies")
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	_barra.hide()
	AudioManager.play_sfx_2d(sfx_morte, global_position, 4.0)

	var partida := get_tree().get_first_node_in_group(Partida.GRUPO) as Partida
	if partida:
		partida.registrar_derrota()

	sprite.modulate = COR_DANO
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(sprite, "scale", Vector2(1.5, 0.15), 0.25)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)
