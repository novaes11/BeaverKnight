extends Node2D
## Gerencia as zonas de combate (nós `ZonaSpawn` filhos). Só nasce inimigo em ponto caminhável,
## conectado ao jogador e fora da tela, e só nas zonas próximas ao jogador.

@export var enemy_scene: PackedScene
## Fora da tela: meia diagonal do viewport 320x180 é ~184 px.
@export var distancia_minima: float = 190.0
## Limite do anel em volta do jogador nas zonas com `nascer_perto`.
@export var distancia_maxima: float = 280.0
## Evita nascer perto em linha reta, mas do outro lado do rio de petróleo.
@export var caminho_maximo: float = 460.0
## Distância do jogador até a zona para ela ficar ativa.
@export var margem_ativacao: float = 96.0
@export var tentativas_por_ciclo: int = 16

const TILE_SIZE: int = 16

@onready var spawn_timer: Timer = $SpawnTimer

var _nav: MapaNavegacao
var _player: Node2D
var _partida: Partida


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
	if _partida == null:
		_partida = get_tree().get_first_node_in_group(Partida.GRUPO) as Partida
	if _nav == null or _player == null or not _nav.pronto:
		return

	for filho in get_children():
		var zona := filho as ZonaSpawn
		if zona == null:
			continue
		zona.atualizar(spawn_timer.wait_time)
		if _partida and zona.etapa != _partida.etapa:
			continue
		if zona.pode_nascer() and zona.area.grow(margem_ativacao).has_point(_player.global_position):
			_tentar_nascer(zona)


func _tentar_nascer(zona: ZonaSpawn) -> void:
	var alvo := _player.global_position + Vector2(0, -4)
	for tentativa in tentativas_por_ciclo:
		var perto := zona.nascer_perto and tentativa < tentativas_por_ciclo * 3 / 4
		var ponto := _sortear_perto(alvo) if perto else _sortear_ponto(zona.area)
		if perto and not zona.area.has_point(ponto):
			continue
		# Na segunda metade aceita um ponto um pouco mais perto, para a zona nunca ficar sem nascer.
		var minimo := distancia_minima if tentativa < tentativas_por_ciclo / 2 else distancia_minima * 0.8
		if ponto.distance_to(alvo) < minimo:
			continue
		if not _nav.ponto_livre(ponto) or not _nav.conectados(ponto, alvo):
			continue
		if perto and _comprimento_caminho(ponto, alvo) > caminho_maximo:
			continue
		var inimigo := enemy_scene.instantiate() as Node2D
		inimigo.configurar(ponto, zona.area, zona.cacar_jogador)
		get_tree().current_scene.add_child(inimigo)
		inimigo.global_position = ponto
		zona.registrar(inimigo)
		return


func _sortear_ponto(area: Rect2) -> Vector2:
	var x := randf_range(area.position.x, area.end.x)
	var y := randf_range(area.position.y, area.end.y)
	return _centro_do_tile(Vector2(x, y))


func _sortear_perto(alvo: Vector2) -> Vector2:
	var direcao := Vector2.from_angle(randf() * TAU)
	return _centro_do_tile(alvo + direcao * randf_range(distancia_minima, distancia_maxima))


func _centro_do_tile(ponto: Vector2) -> Vector2:
	return (ponto / TILE_SIZE).floor() * TILE_SIZE + Vector2.ONE * TILE_SIZE * 0.5


func _comprimento_caminho(de: Vector2, para: Vector2) -> float:
	var caminho := _nav.caminho(de, para)
	var total := 0.0
	for i in range(1, caminho.size()):
		total += caminho[i - 1].distance_to(caminho[i])
	return total
