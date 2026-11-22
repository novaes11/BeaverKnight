class_name BossPetroleo
extends CharacterBody2D
## Chefe final. Alterna perseguição lenta, pancada em área e cuspe de petróleo.
## Todo ataque tem aviso claro e deixa uma janela para o jogador revidar.

enum Estado { SURGINDO, ESPERANDO, ANDANDO, PANCADA, CUSPE, RECUPERANDO, MORRENDO }

const PROJETIL: PackedScene = preload("res://Scene/projetil_petroleo.tscn")

# Linhas da folha (6 colunas x 6 linhas de 96 px)
const LINHA_PARADO := 0
const LINHA_ANDAR := 1
const LINHA_PANCADA := 2
const LINHA_CUSPE := 3
const LINHA_DANO := 4
const LINHA_MORTE := 5
const COLUNAS := 6

const ACHATAMENTO_AREA := 0.6
const AJUSTE_ALVO := Vector2(0, -8)
const ALTURA_BOCA := 26.0

# Balanceamento
@export var max_health: int = 800
@export var velocidade: float = 34.0
@export var velocidade_furia: float = 44.0
@export var raio_despertar: float = 170.0
@export var raio_perda: float = 250.0
@export var raio_pancada: float = 46.0
@export var dano_pancada: int = 18
@export var dano_cuspe: int = 8
@export var velocidade_cuspe: float = 85.0
@export var aviso_pancada: float = 0.8
@export var aviso_cuspe: float = 0.55
@export var recuperacao: float = 1.1
@export var recuperacao_furia: float = 0.85
@export var intervalo_ataque: float = 1.5
@export var intervalo_furia: float = 1.1
## Vida devolvida ao jogador quando o boss entra em fúria.
@export var cura_na_furia: int = 30
## Área do pátio da fábrica por onde o boss anda (coordenadas globais).
@export var arena := Rect2(225, -770, 305, 95)
@export var sfx_impacto: AudioStream

var estado: Estado = Estado.SURGINDO
var current_health: int
var em_furia := false

var _tempo := 0.0
var _tempo_total := 0.0
var _tempo_anim := 0.0
var _tempo_dano := 0.0
var _progresso_aviso := -1.0
var _ataques := 0
var _player: Node2D
var _partida: Partida

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	_player = get_tree().get_first_node_in_group("player") as Node2D
	_partida = get_tree().get_first_node_in_group(Partida.GRUPO) as Partida
	if _partida:
		_partida.atualizar_vida_boss(current_health, max_health)
	_entrar(Estado.SURGINDO, 1.2)


func _physics_process(delta: float) -> void:
	_tempo -= delta
	_tempo_anim += delta
	_tempo_dano = maxf(_tempo_dano - delta, 0.0)
	velocity = Vector2.ZERO

	match estado:
		Estado.SURGINDO:
			_quadro(LINHA_MORTE, 5 - _indice_progresso(6))
			if _tempo <= 0.0:
				_entrar(Estado.ESPERANDO, 0.0)
		Estado.ESPERANDO:
			_animar(LINHA_PARADO, 4, 5.0)
			if _distancia_jogador() <= raio_despertar:
				_entrar(Estado.ANDANDO, 0.8)
		Estado.ANDANDO:
			_andar()
		Estado.PANCADA:
			_preparar_pancada()
		Estado.CUSPE:
			_preparar_cuspe()
		Estado.RECUPERANDO:
			_animar(LINHA_PARADO, 4, 4.0)
			if _tempo <= 0.0:
				_entrar(Estado.ANDANDO, intervalo_furia if em_furia else intervalo_ataque)
		Estado.MORRENDO:
			_quadro(LINHA_MORTE, _indice_progresso(6))
			if _tempo <= 0.0:
				_concluir_morte()
				return

	if estado != Estado.MORRENDO and _tempo_dano > 0.0:
		sprite.frame = LINHA_DANO * COLUNAS
	move_and_slide()
	global_position = global_position.clamp(arena.position, arena.end)


# --- ESTADOS ---

func _entrar(novo: Estado, duracao: float) -> void:
	estado = novo
	_tempo = duracao
	_tempo_total = maxf(duracao, 0.001)
	_tempo_anim = 0.0
	_progresso_aviso = -1.0
	queue_redraw()


func _andar() -> void:
	if _player == null or _distancia_jogador() > raio_perda:
		_entrar(Estado.ESPERANDO, 0.0)
		return
	_animar(LINHA_ANDAR, 4, 6.0)
	var alvo := _player.global_position
	sprite.flip_h = alvo.x < global_position.x
	if global_position.distance_to(alvo) > 26.0:
		velocity = global_position.direction_to(alvo) * (velocidade_furia if em_furia else velocidade)
	if _tempo <= 0.0:
		# De perto alterna duas pancadas e um cuspe; de longe sempre cospe.
		_ataques += 1
		if _dentro_da_pancada(1.25) and _ataques % 3 != 0:
			_entrar(Estado.PANCADA, aviso_pancada)
		else:
			_entrar(Estado.CUSPE, aviso_cuspe)


func _preparar_pancada() -> void:
	_progresso_aviso = 1.0 - clampf(_tempo / _tempo_total, 0.0, 1.0)
	_quadro(LINHA_PANCADA, 0 if _progresso_aviso < 0.65 else 1)
	queue_redraw()
	if _tempo > 0.0:
		return
	sprite.frame = LINHA_PANCADA * COLUNAS + 2
	AudioManager.play_sfx_2d(sfx_impacto, global_position, 6.0, 0.55)
	if _player:
		if _player.has_method("tremer"):
			_player.tremer(3.0)
		if _dentro_da_pancada(1.0):
			_player.take_damage(dano_pancada, global_position)
	_entrar(Estado.RECUPERANDO, recuperacao_furia if em_furia else recuperacao)
	_quadro(LINHA_PANCADA, 2)


func _preparar_cuspe() -> void:
	var progresso := 1.0 - clampf(_tempo / _tempo_total, 0.0, 1.0)
	_quadro(LINHA_CUSPE, 0 if progresso < 0.5 else 1)
	sprite.modulate = Color(1.35, 0.85, 0.85) if int(progresso * 8.0) % 2 == 1 else Color.WHITE
	if _tempo > 0.0:
		return
	sprite.modulate = Color.WHITE
	_quadro(LINHA_CUSPE, 2)
	_cuspir()
	_entrar(Estado.RECUPERANDO, recuperacao_furia if em_furia else recuperacao)


func _cuspir() -> void:
	if _player == null:
		return
	var boca := global_position + Vector2(0, -ALTURA_BOCA)
	var direcao := boca.direction_to(_player.global_position + AJUSTE_ALVO)
	var quantidade := 5 if em_furia else 3
	var abertura := deg_to_rad(16.0)
	for i in quantidade:
		var angulo := (i - (quantidade - 1) * 0.5) * abertura
		var gota := PROJETIL.instantiate()
		get_parent().add_child(gota)
		gota.iniciar(boca, direcao.rotated(angulo), dano_cuspe, velocidade_cuspe)


# --- DANO ---

## Ponto do corpo mais próximo do golpe: o boss é maior que um inimigo comum.
func ponto_mais_proximo(origem: Vector2) -> Vector2:
	var corpo := Rect2(global_position + Vector2(-34, -58), Vector2(68, 58))
	return origem.clamp(corpo.position, corpo.end)


func take_damage(amount: int) -> void:
	if estado == Estado.MORRENDO or estado == Estado.SURGINDO:
		return
	current_health = maxi(current_health - amount, 0)
	if _partida:
		_partida.atualizar_vida_boss(current_health, max_health)
	if current_health <= 0:
		_morrer()
		return
	_tempo_dano = 0.1
	if estado == Estado.ESPERANDO:
		_entrar(Estado.ANDANDO, 0.8)
	if not em_furia and current_health <= max_health * 0.5:
		_entrar_em_furia()


func _entrar_em_furia() -> void:
	em_furia = true
	sprite.self_modulate = Color(1.2, 0.82, 0.82)
	if _player and _player.has_method("curar"):
		_player.curar(cura_na_furia)
	if _partida:
		_partida.avisar("O BOSS ENTROU EM FÚRIA!  +%d DE VIDA" % cura_na_furia)


func _morrer() -> void:
	remove_from_group("enemies")
	sprite.modulate = Color.WHITE
	for gota in get_tree().get_nodes_in_group("projeteis_boss"):
		gota.queue_free()
	AudioManager.play_sfx_2d(sfx_impacto, global_position, 8.0, 0.4)
	_entrar(Estado.MORRENDO, 1.4)


func _concluir_morte() -> void:
	set_physics_process(false)
	if _partida:
		_partida.registrar_derrota()
		_partida.boss_derrotado()


# --- AUXILIARES ---

func _distancia_jogador() -> float:
	return global_position.distance_to(_player.global_position) if _player else INF


func _dentro_da_pancada(margem: float) -> bool:
	if _player == null:
		return false
	var d := _player.global_position - global_position
	var raio := raio_pancada * margem
	return (d.x / raio) ** 2 + (d.y / (raio * ACHATAMENTO_AREA)) ** 2 <= 1.0


func _indice_progresso(quadros: int) -> int:
	var progresso := 1.0 - clampf(_tempo / _tempo_total, 0.0, 1.0)
	return mini(int(progresso * quadros), quadros - 1)


func _quadro(linha: int, coluna: int) -> void:
	sprite.frame = linha * COLUNAS + coluna


func _animar(linha: int, quadros: int, fps: float) -> void:
	_quadro(linha, int(_tempo_anim * fps) % quadros)


## Área vermelha no chão avisando onde a pancada vai acertar.
func _draw() -> void:
	if _progresso_aviso < 0.0:
		return
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, ACHATAMENTO_AREA))
	draw_circle(Vector2.ZERO, raio_pancada, Color(0.9, 0.08, 0.08, 0.22))
	draw_circle(Vector2.ZERO, raio_pancada * _progresso_aviso, Color(1.0, 0.2, 0.12, 0.34))
	draw_arc(Vector2.ZERO, raio_pancada, 0.0, TAU, 40, Color(1.0, 0.25, 0.2, 0.95), 1.5)
