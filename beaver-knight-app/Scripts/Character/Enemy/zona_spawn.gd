class_name ZonaSpawn
extends Node
## Zona de combate: define onde e quantos inimigos podem existir. Controlada por `enemy_spawn.gd`.

## Área da zona em coordenadas globais.
@export var area := Rect2()
@export var max_inimigos: int = 3
## Tempo entre um nascimento e outro enquanto a zona enche.
@export var intervalo_spawn: float = 2.0
## Tempo para repor um inimigo depois que ele morre.
@export var intervalo_reposicao: float = 6.0

# Sem tipo: guarda referências que podem já ter sido liberadas quando o inimigo morre.
var _vivos: Array = []
var _espera := 0.0


func atualizar(delta: float) -> void:
	_espera = maxf(_espera - delta, 0.0)
	var ainda_vivos: Array = []
	for i in _vivos.size():
		if is_instance_valid(_vivos[i]):
			ainda_vivos.append(_vivos[i])
	if ainda_vivos.size() < _vivos.size():
		_espera = maxf(_espera, intervalo_reposicao)
	_vivos = ainda_vivos


func pode_nascer() -> bool:
	return _espera <= 0.0 and _vivos.size() < max_inimigos


func registrar(inimigo: Node) -> void:
	_vivos.append(inimigo)
	_espera = intervalo_spawn


func quantidade() -> int:
	return _vivos.size()
