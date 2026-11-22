extends SceneTree
# Teste headless do fluxo de jogo: escada, spawn por zonas, IA, golpe, desistência e caverna.
# Uso (PowerShell, na raiz do repo):
#   & "<pasta da Godot>/Godot_v4.7.1-stable_win64_console.exe" --headless --fixed-fps 60 --path beaver-knight-app -s "$PWD/ferramentas/testes/teste_combate_headless.gd"
# Resultado esperado: todas as linhas "OK", "RESULTADO: PASSOU" e nenhum "ERROR" da engine.

const PATRULHA := 0
const RETORNO := 4

var town: Node2D
var player: CharacterBody2D
var nav: MapaNavegacao
var falhas := 0


func _initialize() -> void:
	town = (load("res://Scene/town.tscn") as PackedScene).instantiate()
	root.add_child(town)
	current_scene = town
	player = town.get_node("Player")
	nav = town.get_node("MapaNavegacao")
	player.max_health = 100000
	player.current_health = 100000
	_rodar()


func _rodar() -> void:
	while not nav.pronto:
		await physics_frame

	# 1. Cidade é área segura.
	await _esperar(480)
	_checar(_inimigos().is_empty(), "nenhum inimigo nasce com o jogador na cidade")

	# 2. Subir a escada andando.
	player.global_position = Vector2(107, -150)
	Input.action_press("ui_up")
	await _esperar(150)
	Input.action_release("ui_up")
	_checar(player.global_position.y < -320.0, "jogador atravessa a escada (y=%.0f)" % player.global_position.y)

	# 3. Spawn na praia.
	var espera := 0
	while _inimigos().size() < 3 and espera < 1500:
		await physics_frame
		espera += 1
	var lista := _inimigos()
	_checar(lista.size() == 3, "praia enche até o limite de 3 (%d)" % lista.size())
	var livres := true
	for inimigo in lista:
		livres = livres and nav.conectados(inimigo.global_position, player.global_position)
	_checar(livres, "inimigos nascem conectados ao jogador")

	# 4. Perseguição até causar dano.
	var alvo: Node2D = _mais_proximo()
	var perto := _ponto_livre_perto(alvo.global_position, 72.0)
	player.global_position = perto
	var vida: int = player.current_health
	espera = 0
	while player.current_health == vida and espera < 600:
		await physics_frame
		espera += 1
	_checar(player.current_health < vida, "inimigo alcança e ataca o jogador (%.1f s)" % (espera / 60.0))

	# 5. Golpe com knockback até matar.
	alvo = _mais_proximo()
	var empurrou := false
	var golpes := 0
	while is_instance_valid(alvo) and golpes < 8:
		var direcao: Vector2 = (alvo.global_position - player.global_position).normalized()
		player.update_facing_direction(direcao)
		player.global_position = alvo.global_position - direcao * 12.0 + Vector2(0, 8)
		player.attack_enemy()
		golpes += 1
		if is_instance_valid(alvo) and alvo.knockback_velocity.length() > 100.0:
			empurrou = true
		await _esperar(32)
	_checar(not is_instance_valid(alvo), "golpes matam o inimigo (%d)" % golpes)
	_checar(empurrou, "golpe aplica knockback")
	_checar(player.can_move, "jogador volta a se mover depois do ataque")

	# 6. Reposição respeita o limite.
	await _esperar(600)
	_checar(_inimigos().size() <= 3, "reposição respeita o limite (%d)" % _inimigos().size())

	# 7. Fugir: inimigos desistem.
	player.global_position = Vector2(107, 150)
	await _esperar(90)
	var desistiram := true
	for inimigo in _inimigos():
		desistiram = desistiram and (inimigo.estado == RETORNO or inimigo.estado == PATRULHA)
	_checar(desistiram, "inimigos desistem quando o jogador foge")

	# 8. Caverna de ida e volta.
	player.global_position = Vector2(-13, -436)
	await _esperar(5)
	Input.action_press("ui_up")
	await _esperar(45)
	Input.action_release("ui_up")
	await _esperar(45)
	_checar(player.global_position.y < -520.0, "caverna leva à refinaria (y=%.0f)" % player.global_position.y)
	_checar(not player.travado, "controle volta depois do fade")
	Input.action_press("ui_down")
	await _esperar(45)
	Input.action_release("ui_down")
	await _esperar(45)
	_checar(player.global_position.y > -440.0, "túnel volta para a praia (y=%.0f)" % player.global_position.y)

	# 9. Zona da refinaria funciona.
	player.global_position = Vector2(100, -700)
	espera = 0
	var zona: ZonaSpawn = town.get_node("EnemySpawn/ZonaRefinariaOeste")
	while zona.quantidade() == 0 and espera < 1200:
		await physics_frame
		espera += 1
	_checar(zona.quantidade() > 0, "zona da refinaria gera inimigos")

	print("RESULTADO: ", "PASSOU" if falhas == 0 else "FALHOU (%d)" % falhas)
	quit(1 if falhas > 0 else 0)


func _esperar(quadros: int) -> void:
	for _i in quadros:
		await physics_frame


func _inimigos() -> Array[Node]:
	return get_nodes_in_group("enemies")


func _mais_proximo() -> Node2D:
	var melhor: Node2D = null
	for inimigo: Node2D in _inimigos():
		if melhor == null or inimigo.global_position.distance_squared_to(player.global_position) \
				< melhor.global_position.distance_squared_to(player.global_position):
			melhor = inimigo
	return melhor


func _ponto_livre_perto(centro: Vector2, distancia: float) -> Vector2:
	for i in 32:
		var p := centro + Vector2.from_angle(TAU * i / 32.0) * distancia
		if nav.ponto_livre(p) and nav.conectados(p, centro):
			return p
	return centro


func _checar(condicao: bool, texto: String) -> void:
	print("OK    " if condicao else "FALHA ", texto)
	if not condicao:
		falhas += 1
