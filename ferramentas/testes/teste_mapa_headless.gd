extends SceneTree
# Teste headless do mapa: conectividade, limites jogáveis, passagens e pontos de spawn.
# Uso (PowerShell, na raiz do repo):
#   & "<pasta da Godot>/Godot_v4.7.1-stable_win64_console.exe" --headless --path beaver-knight-app -s "$PWD/ferramentas/testes/teste_mapa_headless.gd"
# Resultado esperado: todas as linhas "OK" e "RESULTADO: PASSOU".
# Opcional: MAPA_BASE=<png do mapa> e MAPA_SAIDA=<png> geram uma imagem com o alcance do jogador.

const PASSO := 4
const LIMITE_MIN := Vector2i(-600, -1100)
const LIMITE_MAX := Vector2i(960, 560)
const ORIGEM_IMAGEM := Vector2i(528, 1024)

const PONTOS := {
	"praia": Vector2i(100, -336),
	"refinaria_oeste": Vector2i(-28, -624),
	"refinaria_leste": Vector2i(420, -760),
	"refinaria_sudeste": Vector2i(520, -500),
}
const FORA := {
	"planalto_oeste": Vector2i(-480, -700),
	"planalto_leste": Vector2i(800, -700),
	"vazio_oeste": Vector2i(-500, 200),
	"vazio_sul": Vector2i(120, 540),
}

var town: Node2D
var regras: RegrasTerreno
var espaco: PhysicsDirectSpaceState2D
var consulta := PhysicsShapeQueryParameters2D.new()
var quadros := 0
var falhas := 0


func _initialize() -> void:
	town = (load("res://Scene/town.tscn") as PackedScene).instantiate()
	town.get_node("EnemySpawn/SpawnTimer").autostart = false
	root.add_child(town)
	current_scene = town
	regras = RegrasTerreno.de_cena(town)


func _physics_process(_delta: float) -> bool:
	quadros += 1
	var nav: MapaNavegacao = town.get_node("MapaNavegacao")
	if quadros < 5 or not nav.pronto:
		return false

	var player: CharacterBody2D = town.get_node("Player")
	player.set_physics_process(false)
	espaco = player.get_world_2d().direct_space_state
	var forma := RectangleShape2D.new()
	forma.size = Vector2(14, 8)
	consulta.shape = forma
	consulta.collision_mask = player.collision_mask
	consulta.exclude = [player.get_rid()]

	var inicio := _grade(Vector2i(player.global_position))
	var cidade := _alcance(inicio)
	_checar(not cidade.is_empty(), "jogador nasce em ponto livre")
	_checar(cidade.has(_grade(PONTOS["praia"])), "cidade conecta com a praia pela escada")

	var refinaria := _alcance(_grade(PONTOS["refinaria_oeste"]))
	_checar(refinaria.has(_grade(PONTOS["refinaria_leste"])), "refinaria oeste conecta com a leste")
	_checar(refinaria.has(_grade(PONTOS["refinaria_sudeste"])), "refinaria conecta com o sudeste")
	_checar(not refinaria.has(_grade(PONTOS["praia"])), "refinaria só liga à praia pela caverna")

	var todos := cidade.duplicate()
	todos.merge(refinaria)
	var no_vazio := 0
	for p: Vector2i in todos:
		if _sem_chao(Vector2(p) + Vector2(0, -2)):
			no_vazio += 1
	_checar(no_vazio == 0, "nenhuma posição alcançável fora dos tiles (%d)" % no_vazio)
	for nome: String in FORA:
		_checar(not todos.has(_grade(FORA[nome])), "%s inacessível" % nome)

	var camada_construcoes: TileMapLayer = regras.obstaculos.filter(func(c): return "constru" in String(c.name).to_lower())[0]
	var tanques := 0
	var tanques_livres := 0
	for celula in camada_construcoes.get_used_cells():
		if camada_construcoes.get_cell_source_id(celula) == 0 and camada_construcoes.get_cell_atlas_coords(celula) == Vector2i(52, 52):
			tanques += 1
			var base := camada_construcoes.to_global(camada_construcoes.map_to_local(celula)) + Vector2(0, 16)
			if todos.has(_grade(Vector2i(base))):
				tanques_livres += 1
	_checar(tanques > 0 and tanques_livres == 0, "base dos %d tanques bloqueia a passagem (%d livres)" % [tanques, tanques_livres])

	for passagem in town.get_node("Passagens").get_children():
		if passagem is PassagemCaverna:
			var alvo := passagem.get_node(passagem.destino) as Node2D
			_checar(todos.has(_grade(Vector2i(alvo.global_position))), "chegada de %s é alcançável" % passagem.name)
			_checar(_toca_passagem(passagem, todos), "%s pode ser ativada a pé" % passagem.name)

	var spawner := town.get_node("EnemySpawn")
	for zona in spawner.get_children():
		if zona is ZonaSpawn:
			var livres := 0
			for y in range(int(zona.area.position.y), int(zona.area.end.y), 16):
				for x in range(int(zona.area.position.x), int(zona.area.end.x), 16):
					var c := (Vector2(x, y) / 16).floor() * 16 + Vector2(8, 8)
					if nav.ponto_livre(c) and todos.has(_grade(Vector2i(c))):
						livres += 1
			_checar(livres >= 40, "%s tem pontos de spawn válidos (%d)" % [zona.name, livres])

	_salvar_imagem(cidade, refinaria)
	print("ALCANCE cidade+praia=", cidade.size(), " refinaria=", refinaria.size())
	print("RESULTADO: ", "PASSOU" if falhas == 0 else "FALHOU (%d)" % falhas)
	return true


func _grade(p: Vector2i) -> Vector2i:
	return Vector2i(Vector2(p) / PASSO) * PASSO


func _checar(condicao: bool, texto: String) -> void:
	print("OK    " if condicao else "FALHA ", texto)
	if not condicao:
		falhas += 1


func _colide(p: Vector2i) -> bool:
	consulta.transform = Transform2D(0.0, Vector2(p) + Vector2(0, -4))
	return not espaco.intersect_shape(consulta, 1).is_empty()


func _sem_chao(pos: Vector2) -> bool:
	return regras.terreno.get_cell_source_id(regras.terreno.local_to_map(regras.terreno.to_local(pos))) == -1 \
		and regras.caminho.get_cell_source_id(regras.caminho.local_to_map(regras.caminho.to_local(pos))) == -1


func _alcance(inicio: Vector2i) -> Dictionary:
	var visitados := {}
	if _colide(inicio):
		return visitados
	visitados[inicio] = true
	var fila: Array[Vector2i] = [inicio]
	var cabeca := 0
	while cabeca < fila.size():
		var atual: Vector2i = fila[cabeca]
		cabeca += 1
		for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = atual + d * PASSO
			if n.x < LIMITE_MIN.x or n.y < LIMITE_MIN.y or n.x >= LIMITE_MAX.x or n.y >= LIMITE_MAX.y or visitados.has(n):
				continue
			if regras.bloqueado(Vector2(atual) + Vector2(0, -2) + Vector2(d) * 8.0) or _colide(n):
				continue
			visitados[n] = true
			fila.append(n)
	return visitados


func _toca_passagem(passagem: Area2D, alcance: Dictionary) -> bool:
	var forma_area := passagem.get_node("CollisionShape2D") as CollisionShape2D
	var ret := (forma_area.shape as RectangleShape2D).get_rect()
	ret.position += forma_area.global_position
	var corpo := Rect2(Vector2(-7, -8), Vector2(14, 8))
	for p: Vector2i in alcance:
		if ret.intersects(Rect2(corpo.position + Vector2(p), corpo.size)):
			return true
	return false


func _salvar_imagem(cidade: Dictionary, refinaria: Dictionary) -> void:
	var base := OS.get_environment("MAPA_BASE")
	var saida := OS.get_environment("MAPA_SAIDA")
	if base.is_empty() or saida.is_empty():
		return
	var im := Image.load_from_file(base)
	im.convert(Image.FORMAT_RGBA8)
	for par: Array in [[cidade, Color(0, 1, 0.35, 0.42)], [refinaria, Color(0.1, 0.55, 1, 0.45)]]:
		var ponto := Image.create(PASSO, PASSO, false, Image.FORMAT_RGBA8)
		ponto.fill(par[1])
		for p: Vector2i in par[0]:
			var px: Vector2i = p + ORIGEM_IMAGEM - Vector2i(2, 2)
			if px.x >= 0 and px.y >= 0 and px.x < im.get_width() - PASSO and px.y < im.get_height() - PASSO:
				im.blend_rect(ponto, Rect2i(0, 0, PASSO, PASSO), px)
	im.save_png(saida)
