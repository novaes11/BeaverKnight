extends SceneTree
# Teste headless da partida: escada, caverna fechada, etapas, combate, vitória, derrota e rejogar.
# Uso (PowerShell, na raiz do repo):
#   & "<pasta da Godot>/Godot_v4.7.1-stable_win64_console.exe" --headless --fixed-fps 60 --path beaver-knight-app -s "$PWD/ferramentas/testes/teste_combate_headless.gd"
# Resultado esperado: todas as linhas "OK", "RESULTADO: PASSOU" e nenhum "ERROR" da engine.

const LIMITE_ETAPA := 9000
# Valores de BossPetroleo.Estado (o teste compila antes dos autoloads e não pode citar a classe).
const ESTADO_SURGINDO := 0
const ESTADO_PANCADA := 3
const ESTADO_CUSPE := 4
const ESTADO_MORRENDO := 6

var town: Node2D
var player: CharacterBody2D
var nav: MapaNavegacao
var partida: Partida
var falhas := 0


func _initialize() -> void:
	var cena: Node = (load("res://Scene/town.tscn") as PackedScene).instantiate()
	root.add_child(cena)
	current_scene = cena
	_rodar()


func _rodar() -> void:
	await _preparar()

	# Cidade é área segura e a caverna começa fechada.
	await _esperar(300)
	_checar(_inimigos().is_empty(), "nenhum inimigo nasce na cidade")
	player.global_position = Vector2(107, -150)
	Input.action_press("ui_up")
	await _esperar(150)
	Input.action_release("ui_up")
	_checar(player.global_position.y < -320.0, "jogador atravessa a escada")
	player.global_position = Vector2(-13, -436)
	Input.action_press("ui_up")
	await _esperar(50)
	Input.action_release("ui_up")
	await _esperar(30)
	_checar(player.global_position.y > -500.0, "caverna fechada antes de limpar a praia")

	# Invencibilidade: dois golpes seguidos só contam uma vez.
	# Zera a invencibilidade: um slime da praia pode ter acertado o jogador logo antes.
	player._invencivel = 0.0
	var vida: int = player.current_health
	player.take_damage(10, player.global_position + Vector2(8, 0))
	player.take_damage(10, player.global_position + Vector2(8, 0))
	_checar(player.current_health == vida - 10, "invencibilidade evita dano duplo")
	await _esperar(60)

	# Partida 1: vitória.
	await _limpar_etapa(Partida.Etapa.PRAIA)
	_checar(partida.etapa == Partida.Etapa.REFINARIA, "limpar a praia avança para a refinaria")
	_checar(player.current_health == player.max_health, "vida restaurada ao concluir a etapa")
	player.global_position = Vector2(-13, -436)
	await _esperar(3)
	Input.action_press("ui_up")
	await _esperar(45)
	Input.action_release("ui_up")
	await _esperar(45)
	_checar(player.global_position.y < -520.0, "caverna abre depois da praia")

	# Refinaria: parado, os slimes precisam vir até o jogador.
	var espera := 0
	var chegou := false
	while espera < 1500 and not chegou:
		await physics_frame
		espera += 1
		player.current_health = player.max_health
		for inimigo: Node2D in _inimigos():
			chegou = chegou or inimigo.global_position.distance_to(player.global_position) <= 40.0
	_checar(chegou, "slimes da refinaria alcançam o jogador parado (%.0f s)" % (espera / 60.0))
	await _limpar_etapa(Partida.Etapa.REFINARIA)
	_checar(partida.etapa == Partida.Etapa.BOSS, "limpar a refinaria desperta o boss")
	var chefe := _boss()
	_checar(chefe != null, "boss aparece no pátio da fábrica")
	var resultado := await _lutar_boss(true)
	_checar(resultado["venceu"], "jogador que desvia vence o boss (%.0f s, vida %d)" % [resultado["tempo"], resultado["vida"]])
	_checar(resultado["furia"], "boss entra em fúria abaixo de 50%")
	_checar(resultado["pancadas"] > 0 and resultado["cuspes"] > 0, "boss usa pancada (%d) e cuspe (%d)" % [resultado["pancadas"], resultado["cuspes"]])
	_checar(paused, "jogo pausa na tela final")
	_checar(_tela_fim() != null, "tela de vitória aparece")
	_checar(partida.total_derrotados == partida.meta_praia + partida.meta_refinaria + 1, "contagem de derrotados (%d)" % partida.total_derrotados)

	# Balanceamento: várias lutas com e sem desvio.
	for desviar: bool in [true, true, true, false, false, false]:
		partida.jogar_novamente()
		await _nova_cena()
		partida.etapa = Partida.Etapa.REFINARIA
		partida._avancar()
		await _esperar(2)
		var luta := await _lutar_boss(desviar)
		print("BALANCO %s: %s em %.0f s, vida final %d" % ["desviando" if desviar else "sem desviar", "venceu" if luta["venceu"] else "perdeu", luta["tempo"], luta["vida"]])
		if desviar:
			_checar(luta["venceu"], "luta com desvio é vencível")
		else:
			_checar(not luta["venceu"], "ficar parado batendo perde para o boss")

	# Partida 2: derrota e rejogar.
	partida.jogar_novamente()
	await _nova_cena()
	_checar(not paused and partida.etapa == Partida.Etapa.PRAIA and partida.total_derrotados == 0, "jogar novamente zera a partida")
	_checar(player.current_health == player.max_health, "vida cheia na nova partida")

	# Pausa: congela a partida, retoma e reinicia.
	var pausa: Node = town.get_node("TelaPausa")
	await _esperar(10)
	pausa.alternar()
	var tempo_pausa: float = partida.tempo
	var posicao_pausa := player.global_position
	Input.action_press("ui_down")
	for _i in 30:
		await process_frame
	Input.action_release("ui_down")
	_checar(paused and pausa.aberta and is_equal_approx(partida.tempo, tempo_pausa) and player.global_position == posicao_pausa, "pausa congela o jogo")
	pausa.alternar()
	_checar(not paused and not pausa.aberta, "pausa retoma o jogo")
	await _esperar(5)
	_checar(partida.tempo > tempo_pausa, "cronômetro volta a contar")
	pausa.alternar()
	partida.derrotados_etapa = 3
	partida.jogar_novamente()
	await _nova_cena()
	pausa = town.get_node("TelaPausa")
	_checar(not paused and not pausa.aberta and partida.derrotados_etapa == 0, "reiniciar pela pausa zera a partida")

	player.current_health = 5
	player.take_damage(10)
	await process_frame
	_checar(partida.etapa == Partida.Etapa.FIM and player.morto, "morrer encerra a partida")
	_checar(_tela_fim() != null, "tela de derrota aparece")
	town.get_node("TelaPausa").alternar()
	_checar(not town.get_node("TelaPausa").aberta, "pausa não abre na tela final")

	# Partida 3: recomeça de novo e continua jogável.
	partida.jogar_novamente()
	await _nova_cena()
	var inicio := player.global_position
	Input.action_press("ui_down")
	await _esperar(30)
	Input.action_release("ui_down")
	_checar(player.global_position != inicio and not player.morto, "jogador se move na terceira partida")

	print("RESULTADO: ", "PASSOU" if falhas == 0 else "FALHOU (%d)" % falhas)
	quit(1 if falhas > 0 else 0)


func _preparar() -> void:
	town = current_scene
	player = town.get_node("Player")
	nav = town.get_node("MapaNavegacao")
	partida = town.get_node("Partida")
	partida.salvar_recorde = false
	while not nav.pronto:
		await physics_frame


func _nova_cena() -> void:
	var antiga := town
	while current_scene == antiga or current_scene == null or not is_instance_valid(current_scene):
		await process_frame
	await process_frame
	await _preparar()


func _limpar_etapa(etapa: int) -> void:
	var quadros := 0
	while partida.etapa == etapa and quadros < LIMITE_ETAPA:
		var alvo := _mais_proximo()
		if alvo == null:
			var zona := _zona_ativa()
			if zona and player.global_position.distance_to(zona.area.get_center()) > 40.0:
				player.global_position = _ponto_livre_perto(zona.area.get_center())
			await _esperar(30)
			quadros += 30
			continue
		player.global_position = alvo.global_position + Vector2(-12, 8)
		player.update_facing_direction(Vector2.RIGHT)
		player.current_health = player.max_health
		player.attack_enemy()
		await _esperar(34)
		quadros += 34


func _boss() -> Node2D:
	return town.get_node_or_null("BossPetroleo") as Node2D


## Robô simples: fica perto do boss e ataca. Com `desviar`, sai da área da pancada.
## Nunca desvia das gotas, então é mais fraco que um jogador atento.
func _lutar_boss(desviar: bool) -> Dictionary:
	var chefe := _boss()
	var r := {"venceu": false, "tempo": 0.0, "vida": 0, "furia": false, "pancadas": 0, "cuspes": 0}
	if chefe == null:
		return r
	player.global_position = chefe.global_position + Vector2(0, 40)
	var estado_antes: int = chefe.estado
	var quadros := 0
	while partida.etapa != Partida.Etapa.FIM and quadros < 7200:
		await physics_frame
		quadros += 1
		if partida.etapa == Partida.Etapa.FIM or not is_instance_valid(chefe):
			break
		r["vida"] = player.current_health
		r["furia"] = r["furia"] or chefe.em_furia
		if chefe.estado != estado_antes:
			if chefe.estado == ESTADO_PANCADA:
				r["pancadas"] += 1
			elif chefe.estado == ESTADO_CUSPE:
				r["cuspes"] += 1
			estado_antes = chefe.estado
		if chefe.estado == ESTADO_MORRENDO or not player.can_move:
			continue
		var perto: Vector2 = chefe.global_position + Vector2(0, 16)
		if desviar and chefe.estado == ESTADO_PANCADA:
			var fuga: Vector2 = chefe.global_position + Vector2(0, 42)
			player.global_position = player.global_position.move_toward(fuga, 100.0 / 60.0)
		elif player.global_position.distance_to(perto) > 4.0:
			player.global_position = player.global_position.move_toward(perto, 100.0 / 60.0)
		elif chefe.estado != ESTADO_SURGINDO:
			player.update_facing_direction(Vector2.UP)
			player.attack_enemy()
	r["tempo"] = quadros / 60.0
	r["venceu"] = partida.etapa == Partida.Etapa.FIM and not player.morto
	return r


func _zona_ativa() -> ZonaSpawn:
	for filho in town.get_node("EnemySpawn").get_children():
		if filho is ZonaSpawn and filho.etapa == partida.etapa and filho.restantes() > 0:
			return filho
	return null


func _tela_fim() -> Node:
	return town.get_node_or_null("TelaFim")


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


func _ponto_livre_perto(centro: Vector2) -> Vector2:
	for raio in range(0, 160, 8):
		for i in 16:
			var p := centro + Vector2.from_angle(TAU * i / 16.0) * raio
			if nav.ponto_livre(p):
				return p
	return centro


func _checar(condicao: bool, texto: String) -> void:
	print("OK    " if condicao else "FALHA ", texto)
	if not condicao:
		falhas += 1
