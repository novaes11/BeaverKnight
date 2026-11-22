class_name MapaNavegacao
extends Node2D
## Grade A* das áreas de combate. Usa as mesmas regras de terreno do Player e a física do mapa,
## com folga para o tamanho do inimigo. Também separa o mapa em regiões conectadas.

const GRUPO := &"mapa_navegacao"

## Área coberta pela grade, em coordenadas globais.
@export var area := Rect2(-272, -912, 912, 744)
@export var tamanho_celula := 8
## Tamanho usado para testar se o inimigo cabe na célula.
@export var folga := Vector2(12, 12)

var pronto := false

var _astar := AStarGrid2D.new()
var _regiao := {}
var _regras: RegrasTerreno
var _quadros := 0


func _ready() -> void:
	add_to_group(GRUPO)
	_regras = RegrasTerreno.de_cena(get_parent())


func _physics_process(_delta: float) -> void:
	# A física dos TileMapLayers só fica disponível depois dos primeiros quadros.
	_quadros += 1
	if _quadros < 3:
		return
	_construir()
	set_physics_process(false)


func _construir() -> void:
	var inicio := Vector2i((area.position / tamanho_celula).floor())
	var tamanho := Vector2i((area.size / tamanho_celula).ceil())
	_astar.region = Rect2i(inicio, tamanho)
	_astar.cell_size = Vector2(tamanho_celula, tamanho_celula)
	_astar.offset = Vector2(tamanho_celula, tamanho_celula) * 0.5
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.update()

	var espaco := get_world_2d().direct_space_state
	var forma := RectangleShape2D.new()
	forma.size = folga
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.collision_mask = 1

	for y in range(inicio.y, inicio.y + tamanho.y):
		for x in range(inicio.x, inicio.x + tamanho.x):
			var celula := Vector2i(x, y)
			var centro := Vector2(celula * tamanho_celula) + Vector2.ONE * tamanho_celula * 0.5
			consulta.transform = Transform2D(0.0, centro)
			var solido := _terreno_bloqueia(centro) or not espaco.intersect_shape(consulta, 1).is_empty()
			_astar.set_point_solid(celula, solido)

	_marcar_regioes(inicio, tamanho)
	pronto = true


func _terreno_bloqueia(centro: Vector2) -> bool:
	var meio := folga * 0.5
	for canto: Vector2 in [Vector2.ZERO, meio, -meio, Vector2(meio.x, -meio.y), Vector2(-meio.x, meio.y)]:
		if _regras.bloqueado(centro + canto):
			return true
	return false


func _marcar_regioes(inicio: Vector2i, tamanho: Vector2i) -> void:
	_regiao.clear()
	var proxima := 0
	for y in range(inicio.y, inicio.y + tamanho.y):
		for x in range(inicio.x, inicio.x + tamanho.x):
			var semente := Vector2i(x, y)
			if _astar.is_point_solid(semente) or _regiao.has(semente):
				continue
			proxima += 1
			_regiao[semente] = proxima
			var fila: Array[Vector2i] = [semente]
			var cabeca := 0
			while cabeca < fila.size():
				var atual: Vector2i = fila[cabeca]
				cabeca += 1
				for passo: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					var vizinha := atual + passo
					if _astar.is_in_boundsv(vizinha) and not _astar.is_point_solid(vizinha) and not _regiao.has(vizinha):
						_regiao[vizinha] = proxima
						fila.append(vizinha)


## Caminho em coordenadas globais. Vazio se não existir rota entre os pontos.
func caminho(de: Vector2, para: Vector2) -> PackedVector2Array:
	if not pronto:
		return PackedVector2Array()
	var origem: Variant = _celula_livre(de)
	var destino: Variant = _celula_livre(para)
	if origem == null or destino == null or _regiao[origem] != _regiao[destino]:
		return PackedVector2Array()
	return _astar.get_point_path(origem, destino)


func conectados(a: Vector2, b: Vector2) -> bool:
	if not pronto:
		return false
	var celula_a: Variant = _celula_livre(a)
	var celula_b: Variant = _celula_livre(b)
	return celula_a != null and celula_b != null and _regiao[celula_a] == _regiao[celula_b]


func ponto_livre(posicao: Vector2) -> bool:
	if not pronto:
		return false
	var celula := Vector2i((posicao / tamanho_celula).floor())
	return _astar.is_in_boundsv(celula) and not _astar.is_point_solid(celula)


## Célula livre mais próxima; o alvo pode estar colado em uma parede.
func _celula_livre(posicao: Vector2) -> Variant:
	var base := Vector2i((posicao / tamanho_celula).floor())
	for raio in range(0, 4):
		for y in range(-raio, raio + 1):
			for x in range(-raio, raio + 1):
				if maxi(absi(x), absi(y)) != raio:
					continue
				var celula := base + Vector2i(x, y)
				if _astar.is_in_boundsv(celula) and not _astar.is_point_solid(celula):
					return celula
	return null
