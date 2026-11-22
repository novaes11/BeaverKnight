extends CanvasLayer
## HUD da partida: vida do jogador, objetivo atual, avisos e vida do boss.

const COR_VIDA := Color(0.3, 0.75, 0.3)
const COR_VIDA_BAIXA := Color(0.86, 0.2, 0.18)
const COR_BOSS := Color(0.72, 0.08, 0.14)

var _fundo: ColorRect
var _barra_vida: ProgressBar
var _texto_vida: Label
var _objetivo: Label
var _aviso: Label
var _caixa_boss: Control
var _barra_boss: ProgressBar
var _tween_aviso: Tween


func _ready() -> void:
	layer = 10
	_montar()
	var player := get_parent().get_node("Player")
	var partida := get_parent().get_node("Partida") as Partida
	player.vida_mudou.connect(_on_vida_mudou)
	partida.objetivo_mudou.connect(_on_objetivo_mudou)
	partida.aviso.connect(_on_aviso)
	partida.vida_boss_mudou.connect(_on_vida_boss_mudou)
	_on_vida_mudou(player.max_health, player.max_health)


func _montar() -> void:
	_fundo = ColorRect.new()
	_fundo.color = Color(0.03, 0.06, 0.05, 0.72)
	_fundo.position = Vector2(2, 2)
	_fundo.size = Vector2(140, 24)
	add_child(_fundo)

	var rotulo_vida := EstiloUI.rotulo_hud("VIDA")
	rotulo_vida.position = Vector2(6, 2)
	add_child(rotulo_vida)

	_barra_vida = EstiloUI.barra(COR_VIDA, Vector2(72, 7))
	_barra_vida.position = Vector2(31, 5)
	add_child(_barra_vida)

	_texto_vida = EstiloUI.rotulo_hud("100/100")
	_texto_vida.position = Vector2(107, 2)
	add_child(_texto_vida)

	_objetivo = EstiloUI.rotulo_hud("")
	_objetivo.position = Vector2(6, 13)
	add_child(_objetivo)

	_aviso = EstiloUI.rotulo_hud("", 10)
	_aviso.position = Vector2(0, 42)
	_aviso.size = Vector2(320, 14)
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var faixa := StyleBoxFlat.new()
	faixa.bg_color = Color(0.03, 0.06, 0.05, 0.78)
	faixa.content_margin_top = 1
	faixa.content_margin_bottom = 2
	_aviso.add_theme_stylebox_override("normal", faixa)
	_aviso.modulate.a = 0.0
	add_child(_aviso)

	_caixa_boss = Control.new()
	_caixa_boss.visible = false
	add_child(_caixa_boss)
	var nome := EstiloUI.rotulo_hud("BOSS DE PETRÓLEO")
	nome.position = Vector2(0, 152)
	nome.size = Vector2(320, 12)
	nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caixa_boss.add_child(nome)
	_barra_boss = EstiloUI.barra(COR_BOSS, Vector2(220, 8))
	_barra_boss.position = Vector2(50, 166)
	_caixa_boss.add_child(_barra_boss)


func _on_vida_mudou(atual: int, maximo: int) -> void:
	_barra_vida.max_value = maximo
	_barra_vida.value = atual
	_texto_vida.text = "%d/%d" % [atual, maximo]
	_ajustar_fundo()
	var cheio := _barra_vida.get_theme_stylebox("fill") as StyleBoxFlat
	cheio.bg_color = COR_VIDA_BAIXA if atual <= maximo * 0.3 else COR_VIDA


func _on_objetivo_mudou(texto: String) -> void:
	_objetivo.text = texto
	_ajustar_fundo()


## O fundo escuro acompanha o texto mais largo, sem sobrar faixa vazia na tela.
func _ajustar_fundo() -> void:
	var fim_vida := _texto_vida.position.x + _texto_vida.get_minimum_size().x
	var fim_objetivo := _objetivo.position.x + _objetivo.get_minimum_size().x
	_fundo.size.x = maxf(fim_vida, fim_objetivo) + 3.0 - _fundo.position.x


func _on_aviso(texto: String) -> void:
	_aviso.text = texto
	if _tween_aviso:
		_tween_aviso.kill()
	_aviso.modulate.a = 1.0
	_tween_aviso = create_tween()
	_tween_aviso.tween_interval(2.2)
	_tween_aviso.tween_property(_aviso, "modulate:a", 0.0, 0.4)


func _on_vida_boss_mudou(atual: int, maximo: int) -> void:
	_caixa_boss.visible = atual > 0
	_barra_boss.max_value = maximo
	_barra_boss.value = atual
