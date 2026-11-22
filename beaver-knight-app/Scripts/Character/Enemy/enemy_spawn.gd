extends Node2D
## Gerencia as zonas de combate (nós `ZonaSpawn` filhos). Só nasce inimigo em ponto caminhável,
## conectado ao jogador e fora da tela, e só nas zonas próximas ao jogador.

@export var enemy_scene: PackedScene
## Fora da tela: meia diagonal do viewport 320x180 é ~184 px.
@export var distancia_minima: float = 190.0
## Distância do jogador até a zona para ela ficar ativa.
@export var margem_ativacao: float = 96.0
@export var tentativas_por_ciclo: int = 16

const TILE_SIZE: int = 16

@onready var spawn_timer: Timer = $SpawnTimer

var _nav: MapaNavegacao
var _player: Node2D


func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func _on_spawn_timer_timeout() -> void:
	if enemy_scene == null:
		push_warning("Nenhuma cena de inimigo foi atribuída ao Spawner!")
		return
	if _nav == null:
		_nav = get_tree().get_first_node_in_group(MapaNavegacao.GRUPO) as MapaNavegacao
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _nav == null or _player == null or not _nav.pronto:
		return

	for filho in get_children():
		var zona := filho as ZonaSpawn
		if zona == null:
			continue
		zona.atualizar(spawn_timer.wait_time)
		if zona.pode_nascer() and zona.area.grow(margem_ativacao).has_point(_player.global_position):
			_tentar_nascer(zona)


func _tentar_nascer(zona: ZonaSpawn) -> void:
	var alvo := _player.global_position + Vector2(0, -4)
	for _tentativa in tentativas_por_ciclo:
		var ponto := _sortear_ponto(zona.area)
		if ponto.distance_to(alvo) < distancia_minima:
			continue
		if not _nav.ponto_livre(ponto) or not _nav.conectados(ponto, alvo):
			continue
		var inimigo := enemy_scene.instantiate() as Node2D
		inimigo.configurar(ponto, zona.area)
		get_tree().current_scene.add_child(inimigo)
		inimigo.global_position = ponto
		zona.registrar(inimigo)
		return


func _sortear_ponto(area: Rect2) -> Vector2:
	var x := randf_range(area.position.x, area.end.x)
	var y := randf_range(area.position.y, area.end.y)
	# Centro do tile de 16 px.
	return (Vector2(x, y) / TILE_SIZE).floor() * TILE_SIZE + Vector2.ONE * TILE_SIZE * 0.5
