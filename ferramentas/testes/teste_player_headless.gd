extends SceneTree
# Teste headless do Player: carrega a cidade, simula andar nas 4 direções, diagonais e atacar,
# e espera os inimigos nascerem e perseguirem. Erros da engine saem no stderr.
# Uso (PowerShell, na raiz do repo):
#   & "<pasta da Godot>/Godot_v4.7.1-stable_win64_console.exe" --headless --path beaver-knight-app -s "$PWD/ferramentas/testes/teste_player_headless.gd"
# Resultado esperado: nenhuma linha "ERROR" além das de vazamento (leaked / still in use) na saída.

var passos := [
	["", 30],
	["ui_down", 40], ["", 20], ["attack", 2], ["", 40],
	["ui_up", 40], ["", 20], ["attack", 2], ["", 40],
	["ui_right", 40], ["", 20], ["attack", 2], ["", 40],
	["ui_left", 40], ["", 20], ["attack", 2], ["", 40],
	["ui_down+ui_right", 40], ["", 20],
	["ui_up+ui_left", 40], ["", 20],
	["", 400],  # deixa inimigos nascerem e perseguirem
]
var i := 0
var frames := 0
var player: Node = null

func _initialize() -> void:
	var cena: PackedScene = load("res://Scene/town.tscn")
	var inst = cena.instantiate()
	root.add_child(inst)
	current_scene = inst
	print("TESTE: cena carregada")

func _soltar_tudo() -> void:
	for a in ["ui_down", "ui_up", "ui_left", "ui_right", "attack"]:
		Input.action_release(a)

func _physics_process(_delta: float) -> bool:
	if player == null:
		var lista = get_nodes_in_group("player")
		if lista.size() > 0:
			player = lista[0]
			var spr = player.get_node("Sprite2D")
			print("TESTE: player em ", player.global_position, " hframes=", spr.hframes, " vframes=", spr.vframes)
	if i >= passos.size():
		print("TESTE: inimigos vivos = ", get_nodes_in_group("enemies").size())
		print("TESTE: fim, player em ", player.global_position if player else null)
		return true
	var acao: String = passos[i][0]
	if frames == 0:
		_soltar_tudo()
		for a in acao.split("+", false):
			Input.action_press(a)
		if player:
			var spr = player.get_node("Sprite2D")
			print("TESTE: passo '", acao, "' frame=", spr.frame, " flip=", spr.flip_h, " pos=", player.global_position)
	frames += 1
	if frames >= passos[i][1]:
		frames = 0
		i += 1
	return false
