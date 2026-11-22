class_name RegrasTerreno
extends RefCounted
## Fonte única das regras de "onde dá para andar", usada pelo Player e pela navegação dos inimigos.
##
## - Sem tile no terreno base: fora do mapa, bloqueia.
## - Tile em `caminho_terreno`: libera (pontes, escadas e estradas sobre a água).
## - Terreno base com fonte não andável (água, petróleo): bloqueia.
## - Demais camadas: bloqueiam, exceto decoração baixa (canos no chão, plantas e areia),
##   que não deve criar parede invisível.

## 5 = source_id do terreno base andável.
const FONTES_ANDAVEIS: Array[int] = [5]
## Tiles baixos da vegetação: areia sobreposta, capim e plantas.
const DECORACAO_VEGETACAO: Array[Vector2i] = [
	Vector2i(1, 21), Vector2i(4, 21), Vector2i(30, 20), Vector2i(31, 20), Vector2i(32, 20),
	Vector2i(3, 0), Vector2i(3, 2), Vector2i(28, 0), Vector2i(30, 0), Vector2i(31, 0), Vector2i(51, 21),
]

var terreno: TileMapLayer
var caminho: TileMapLayer
var obstaculos: Array[TileMapLayer] = []

const GRADE_OBJETOS := 8
var _objetos_altos := {}


## Classifica as TileMapLayers filhas de `raiz` por parte do nome (só ASCII, por causa de ç/ã).
static func de_cena(raiz: Node) -> RegrasTerreno:
	var regras := RegrasTerreno.new()
	for filho in raiz.get_children():
		if not (filho is TileMapLayer):
			continue
		var nome := String(filho.name).to_lower()
		if "tipo" in nome:
			regras.terreno = filho
		elif "caminh" in nome:
			regras.caminho = filho
		else:
			regras.obstaculos.append(filho)
	regras._mapear_objetos_altos()
	return regras


func bloqueado(posicao_global: Vector2) -> bool:
	if _objetos_altos.has(Vector2i((posicao_global / GRADE_OBJETOS).floor())):
		return true
	if caminho and caminho.get_cell_source_id(_celula(caminho, posicao_global)) != -1:
		return false
	if terreno:
		var fonte := terreno.get_cell_source_id(_celula(terreno, posicao_global))
		if fonte == -1 or fonte not in FONTES_ANDAVEIS:
			return true
	for camada in obstaculos:
		if _obstaculo(camada, _celula(camada, posicao_global)):
			return true
	return false


## Tiles de várias células sem colisão (tanques, turbinas, tocos) ocupam mais que a célula de
## origem. Bloqueia a metade de baixo do desenho, deixando o jogador passar atrás do topo.
func _mapear_objetos_altos() -> void:
	for camada in obstaculos:
		for celula in camada.get_used_cells():
			var id_fonte := camada.get_cell_source_id(celula)
			var fonte := camada.tile_set.get_source(id_fonte) as TileSetAtlasSource
			var atlas := camada.get_cell_atlas_coords(celula)
			if fonte == null or not fonte.has_tile(atlas):
				continue
			var tamanho := fonte.get_tile_size_in_atlas(atlas)
			if tamanho == Vector2i.ONE or _decoracao_passavel_na(camada, id_fonte, atlas):
				continue
			var dados := camada.get_cell_tile_data(celula)
			if dados == null or dados.get_collision_polygons_count(0) > 0:
				continue
			var medida := Vector2(tamanho * camada.tile_set.tile_size)
			var centro := camada.to_global(camada.map_to_local(celula)) - Vector2(dados.texture_origin)
			var base := Rect2(centro.x - medida.x * 0.5, centro.y, medida.x, medida.y * 0.5)
			var de := Vector2i((base.position / GRADE_OBJETOS).floor())
			var ate := Vector2i(((base.end - Vector2.ONE) / GRADE_OBJETOS).floor())
			for y in range(de.y, ate.y + 1):
				for x in range(de.x, ate.x + 1):
					_objetos_altos[Vector2i(x, y)] = true


func _decoracao_passavel_na(camada: TileMapLayer, id_fonte: int, atlas: Vector2i) -> bool:
	return id_fonte == 0 and _decoracao_passavel(String(camada.name).to_lower(), atlas)


func _celula(camada: TileMapLayer, posicao_global: Vector2) -> Vector2i:
	return camada.local_to_map(camada.to_local(posicao_global))


func _obstaculo(camada: TileMapLayer, celula: Vector2i) -> bool:
	var id_fonte := camada.get_cell_source_id(celula)
	if id_fonte == -1:
		return false
	var fonte := camada.tile_set.get_source(id_fonte) as TileSetAtlasSource
	var atlas := camada.get_cell_atlas_coords(celula)
	if fonte == null or not fonte.has_tile(atlas):
		return false
	return not _decoracao_passavel_na(camada, id_fonte, atlas)


func _decoracao_passavel(nome_camada: String, atlas: Vector2i) -> bool:
	if "veget" in nome_camada:
		return atlas in DECORACAO_VEGETACAO
	# Canos baixos no chão; os tanques (52:52) continuam bloqueando.
	return atlas.x >= 54 and atlas.x <= 59 and atlas.y >= 51 and atlas.y <= 54
