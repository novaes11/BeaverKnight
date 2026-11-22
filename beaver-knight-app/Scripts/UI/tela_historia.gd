extends Control
## Tela entre o menu e a partida: apresenta a história, o objetivo e as etapas.

const CENA_JOGO := "res://Scene/town.tscn"
const FUNDO: Texture2D = preload("res://Assets/UI/BeaverKnight-BG.png")

@export var sfx_botao: AudioStream


func _ready() -> void:
	var imagem := TextureRect.new()
	imagem.texture = FUNDO
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	imagem.size = Vector2(320, 180)
	add_child(imagem)

	var escuro := ColorRect.new()
	escuro.color = Color(0, 0, 0, 0.45)
	escuro.size = Vector2(320, 180)
	add_child(escuro)

	var painel := EstiloUI.painel()
	painel.position = Vector2(26, 10)
	painel.custom_minimum_size = Vector2(268, 160)
	add_child(painel)

	var coluna := VBoxContainer.new()
	coluna.alignment = BoxContainer.ALIGNMENT_CENTER
	coluna.add_theme_constant_override("separation", 5)
	painel.add_child(coluna)

	var titulo := EstiloUI.rotulo("SUA MISSÃO", 13, Color(1.0, 0.86, 0.35))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coluna.add_child(titulo)

	var historia := EstiloUI.rotulo("A POLUIÇÃO TOMOU A REGIÃO! DERROTE OS SLIMES E O BOSS DE PETRÓLEO PARA LIMPAR A CIDADE E MANTER O EQUILÍBRIO ECOLÓGICO.")
	historia.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	historia.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	historia.custom_minimum_size = Vector2(250, 0)
	coluna.add_child(historia)

	var etapas := EstiloUI.rotulo("1. SUBA A ESCADA E LIMPE A PRAIA\n2. ENTRE NA CAVERNA E LIMPE A REFINARIA\n3. VENÇA O BOSS DE PETRÓLEO", 8, Color(0.72, 0.92, 0.62))
	coluna.add_child(etapas)

	var controles := EstiloUI.rotulo("SETAS: ANDAR   -   CLIQUE ESQUERDO: ATACAR")
	controles.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coluna.add_child(controles)

	var comecar := EstiloUI.botao("COMEÇAR", EstiloUI.VERDE)
	comecar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	comecar.pressed.connect(_on_comecar)
	coluna.add_child(comecar)
	comecar.grab_focus()


func _on_comecar() -> void:
	AudioManager.play_sfx(sfx_botao, 0.0)
	get_tree().change_scene_to_file(CENA_JOGO)
