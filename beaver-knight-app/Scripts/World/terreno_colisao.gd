extends TileMapLayer
## Remove, em tempo de execução, a colisão dos tiles de margem cobertos por uma ponte/escada.
## O visual e os dados do mapa não mudam; só a física da célula embaixo da ponte.

## Tiles do atlas de `caminho_terreno` que formam a escada e a ponte de madeira sobre água e petróleo.
const ATLAS_ESCADA_MIN := Vector2i(42, 10)
const ATLAS_ESCADA_MAX := Vector2i(47, 12)

@export var camada_caminho: NodePath = ^"../caminho_terreno"

var _caminho: TileMapLayer


func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if _caminho == null:
		_caminho = get_node_or_null(camada_caminho) as TileMapLayer
	if _caminho == null or _caminho.get_cell_source_id(coords) == -1:
		return false
	var atlas := _caminho.get_cell_atlas_coords(coords)
	return atlas.x >= ATLAS_ESCADA_MIN.x and atlas.x <= ATLAS_ESCADA_MAX.x \
		and atlas.y >= ATLAS_ESCADA_MIN.y and atlas.y <= ATLAS_ESCADA_MAX.y


func _tile_data_runtime_update(_coords: Vector2i, tile_data: TileData) -> void:
	if tile_set and tile_set.get_physics_layers_count() > 0:
		tile_data.set_collision_polygons_count(0, 0)
