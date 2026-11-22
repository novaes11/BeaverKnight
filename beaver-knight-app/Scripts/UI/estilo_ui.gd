class_name EstiloUI
extends RefCounted
## Fonte, cores e componentes das telas, seguindo o visual do menu principal.

const FONTE: FontFile = preload("res://Assets/UI/pkmnfl.ttf")
const COR_TEXTO := Color(0.96, 0.93, 0.81)
const COR_PAINEL := Color(0.063, 0.239, 0.165, 0.96)
const COR_BORDA := Color(0.537, 0.325, 0.184)
const VERDE := Color(0.224, 0.478, 0.227)
const AZUL := Color(0.086, 0.561, 0.69)
const MARROM := Color(0.537, 0.325, 0.184)


static func rotulo(texto: String, tamanho: int = 8, cor: Color = COR_TEXTO) -> Label:
	var label := Label.new()
	label.text = texto
	label.add_theme_font_override("font", FONTE)
	label.add_theme_font_size_override("font_size", tamanho)
	label.add_theme_color_override("font_color", cor)
	return label


static func rotulo_hud(texto: String, tamanho: int = 8) -> Label:
	var label := rotulo(texto, tamanho)
	label.add_theme_color_override("font_shadow_color", Color(0.05, 0.04, 0.04))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label


static func botao(texto: String, cor: Color) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(112, 20)
	b.add_theme_font_override("font", FONTE)
	b.add_theme_font_size_override("font_size", 10)
	b.add_theme_color_override("font_color", COR_TEXTO)
	b.add_theme_stylebox_override("normal", _caixa_botao(cor))
	b.add_theme_stylebox_override("hover", _caixa_botao(cor.lightened(0.15)))
	b.add_theme_stylebox_override("pressed", _caixa_botao(cor.darkened(0.15)))
	b.add_theme_stylebox_override("focus", _caixa_foco())
	return b


static func painel() -> PanelContainer:
	var p := PanelContainer.new()
	var caixa := StyleBoxFlat.new()
	caixa.bg_color = COR_PAINEL
	caixa.border_color = COR_BORDA
	caixa.set_border_width_all(2)
	caixa.set_corner_radius_all(5)
	caixa.set_content_margin_all(8)
	p.add_theme_stylebox_override("panel", caixa)
	return p


static func barra(cor: Color, tamanho: Vector2) -> ProgressBar:
	var b := ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = tamanho
	b.size = tamanho
	var fundo := StyleBoxFlat.new()
	fundo.bg_color = Color(0.09, 0.05, 0.05)
	fundo.border_color = Color(0.96, 0.93, 0.81)
	fundo.set_border_width_all(1)
	var cheio := StyleBoxFlat.new()
	cheio.bg_color = cor
	cheio.set_expand_margin_all(-1)
	b.add_theme_stylebox_override("background", fundo)
	b.add_theme_stylebox_override("fill", cheio)
	return b


static func formatar_tempo(segundos: float) -> String:
	var total := int(segundos)
	return "%02d:%02d" % [total / 60, total % 60]


static func _caixa_botao(cor: Color) -> StyleBoxFlat:
	var caixa := StyleBoxFlat.new()
	caixa.bg_color = cor
	caixa.border_color = COR_TEXTO
	caixa.set_border_width_all(1)
	caixa.set_corner_radius_all(6)
	return caixa


static func _caixa_foco() -> StyleBoxFlat:
	var caixa := StyleBoxFlat.new()
	caixa.draw_center = false
	caixa.border_color = Color(1.0, 0.86, 0.35)
	caixa.set_border_width_all(1)
	caixa.set_corner_radius_all(6)
	return caixa
