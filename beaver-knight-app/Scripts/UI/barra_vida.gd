class_name BarraVida
extends Node2D
## Barra de vida pequena desenhada sobre a cabeça dos inimigos.

const LARGURA := 18.0
const ALTURA := 3.0
const COR_FUNDO := Color(0.09, 0.05, 0.05)
const COR_VIDA := Color(0.86, 0.2, 0.18)

var _proporcao := 1.0


func _ready() -> void:
	z_as_relative = false
	z_index = 6


func definir(atual: int, maximo: int) -> void:
	_proporcao = clampf(float(atual) / maxf(float(maximo), 1.0), 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	var inicio := Vector2(-LARGURA * 0.5, 0.0)
	draw_rect(Rect2(inicio, Vector2(LARGURA, ALTURA)), COR_FUNDO)
	draw_rect(Rect2(inicio + Vector2.ONE, Vector2((LARGURA - 2.0) * _proporcao, ALTURA - 2.0)), COR_VIDA)
