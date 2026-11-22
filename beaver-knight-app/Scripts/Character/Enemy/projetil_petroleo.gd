extends Node2D
## Gota de petróleo cuspida pelo boss.

const DURACAO := 2.2
const RAIO_ACERTO := 9.0
const AJUSTE_ALVO := Vector2(0, -8)

var _direcao := Vector2.DOWN
var _dano := 8
var _velocidade := 85.0
var _vida := DURACAO
var _player: Node2D


func iniciar(origem: Vector2, direcao: Vector2, dano: int, velocidade: float) -> void:
	global_position = origem
	_direcao = direcao
	_dano = dano
	_velocidade = velocidade


func _ready() -> void:
	add_to_group("projeteis_boss")
	z_index = 4
	_player = get_tree().get_first_node_in_group("player") as Node2D


func _physics_process(delta: float) -> void:
	global_position += _direcao * _velocidade * delta
	_vida -= delta
	if _vida <= 0.0:
		queue_free()
		return
	if _player and global_position.distance_to(_player.global_position + AJUSTE_ALVO) <= RAIO_ACERTO:
		_player.take_damage(_dano, global_position)
		queue_free()


func _draw() -> void:
	draw_rect(Rect2(-3, -2, 6, 5), Color8(5, 4, 8))
	draw_rect(Rect2(-2, -3, 4, 7), Color8(5, 4, 8))
	draw_rect(Rect2(-2, -2, 4, 5), Color8(29, 25, 35))
	draw_rect(Rect2(-1, -2, 1, 1), Color8(216, 208, 232))
	draw_rect(Rect2(0, 2, 2, 1), Color8(220, 28, 40))
