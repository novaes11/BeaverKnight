extends CanvasLayer
## Tela de vitória ou derrota, com estatísticas e opção de jogar novamente.

@export var sfx_botao: AudioStream

var _partida: Partida


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS


func mostrar(partida: Partida, venceu: bool, tempo: float, derrotados: int, recorde: float) -> void:
	_partida = partida

	var fundo := ColorRect.new()
	fundo.color = Color(0.0, 0.0, 0.0, 0.62)
	fundo.size = Vector2(320, 180)
	add_child(fundo)

	var painel := EstiloUI.painel()
	painel.position = Vector2(35, 18)
	painel.custom_minimum_size = Vector2(250, 144)
	add_child(painel)

	var coluna := VBoxContainer.new()
	coluna.alignment = BoxContainer.ALIGNMENT_CENTER
	coluna.add_theme_constant_override("separation", 4)
	painel.add_child(coluna)

	var titulo := EstiloUI.rotulo("PARABÉNS, CAVALEIRO!" if venceu else "A POLUIÇÃO VENCEU...", 13, Color(1.0, 0.86, 0.35) if venceu else Color(1.0, 0.45, 0.4))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coluna.add_child(titulo)

	var mensagem := EstiloUI.rotulo(
		"VOCÊ LIMPOU A CIDADE E RESTAUROU O EQUILÍBRIO ECOLÓGICO!" if venceu
		else "A CIDADE AINDA PRECISA DE VOCÊ. TENTE OUTRA VEZ!")
	mensagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mensagem.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mensagem.custom_minimum_size = Vector2(230, 0)
	coluna.add_child(mensagem)

	var dados := "TEMPO: %s   INIMIGOS: %d" % [EstiloUI.formatar_tempo(tempo), derrotados]
	if recorde >= 0.0:
		dados += "\nMELHOR TEMPO: %s" % EstiloUI.formatar_tempo(recorde)
	var estatisticas := EstiloUI.rotulo(dados)
	estatisticas.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coluna.add_child(estatisticas)

	var botoes := VBoxContainer.new()
	botoes.add_theme_constant_override("separation", 3)
	coluna.add_child(botoes)
	var novamente := EstiloUI.botao("JOGAR NOVAMENTE" if venceu else "TENTAR NOVAMENTE", EstiloUI.VERDE)
	novamente.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	novamente.custom_minimum_size = Vector2(140, 20)
	novamente.pressed.connect(_on_jogar_novamente)
	botoes.add_child(novamente)
	var menu := EstiloUI.botao("MENU PRINCIPAL", EstiloUI.MARROM)
	menu.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu.custom_minimum_size = Vector2(140, 20)
	menu.pressed.connect(_on_menu)
	botoes.add_child(menu)
	novamente.grab_focus()


func _on_jogar_novamente() -> void:
	AudioManager.play_sfx(sfx_botao, 0.0)
	_partida.jogar_novamente()


func _on_menu() -> void:
	AudioManager.play_sfx(sfx_botao, 0.0)
	_partida.voltar_menu()
