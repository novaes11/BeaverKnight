extends CanvasLayer
## Tela de pausa: abre com Esc ou P e permite continuar, reiniciar ou voltar ao menu.

@export var sfx_botao: AudioStream

var aberta := false

var _partida: Partida
var _player: Node
var _continuar: Button


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_partida = get_parent().get_node("Partida") as Partida
	_player = get_parent().get_node("Player")
	_montar()
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pausar") and not event.is_echo():
		alternar()
		get_viewport().set_input_as_handled()


func alternar() -> void:
	if aberta:
		fechar()
	elif _pode_pausar():
		abrir()


func abrir() -> void:
	aberta = true
	visible = true
	get_tree().paused = true
	_continuar.grab_focus()


func fechar() -> void:
	aberta = false
	visible = false
	get_tree().paused = false


## Não abre nas telas finais, com o jogador morto nem durante a transição da caverna.
func _pode_pausar() -> bool:
	return _partida.etapa != Partida.Etapa.FIM and not get_tree().paused \
		and not _player.morto and not _player.travado


func _montar() -> void:
	var fundo := ColorRect.new()
	fundo.color = Color(0.0, 0.0, 0.0, 0.62)
	fundo.size = Vector2(320, 180)
	add_child(fundo)

	var painel := EstiloUI.painel()
	painel.position = Vector2(80, 28)
	painel.custom_minimum_size = Vector2(160, 124)
	add_child(painel)

	var coluna := VBoxContainer.new()
	coluna.alignment = BoxContainer.ALIGNMENT_CENTER
	coluna.add_theme_constant_override("separation", 5)
	painel.add_child(coluna)

	var titulo := EstiloUI.rotulo("JOGO PAUSADO", 13, Color(1.0, 0.86, 0.35))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coluna.add_child(titulo)

	_continuar = _botao(coluna, "CONTINUAR", EstiloUI.VERDE, _on_continuar)
	_botao(coluna, "REINICIAR PARTIDA", EstiloUI.AZUL, _on_reiniciar)
	_botao(coluna, "MENU PRINCIPAL", EstiloUI.MARROM, _on_menu)


func _botao(coluna: VBoxContainer, texto: String, cor: Color, acao: Callable) -> Button:
	var botao := EstiloUI.botao(texto, cor)
	botao.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	botao.custom_minimum_size = Vector2(140, 20)
	botao.pressed.connect(acao)
	coluna.add_child(botao)
	return botao


func _on_continuar() -> void:
	AudioManager.play_sfx(sfx_botao, 0.0)
	fechar()


func _on_reiniciar() -> void:
	AudioManager.play_sfx(sfx_botao, 0.0)
	_partida.jogar_novamente()


func _on_menu() -> void:
	AudioManager.play_sfx(sfx_botao, 0.0)
	_partida.voltar_menu()
