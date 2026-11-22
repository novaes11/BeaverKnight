class_name PassagemCaverna
extends Area2D
## Leva o jogador até `destino` com um fade rápido. Inimigos não usam a passagem.

@export var destino: NodePath
@export var duracao_fade: float = 0.2

static var _em_transicao := false


func _ready() -> void:
	_em_transicao = false
	collision_layer = 0
	collision_mask = 2 # camada do Player
	monitorable = false
	body_entered.connect(_on_body_entered)


func _on_body_entered(corpo: Node2D) -> void:
	if _em_transicao or not corpo.is_in_group("player"):
		return
	var marcador := get_node_or_null(destino) as Node2D
	if marcador == null:
		push_warning("Passagem da caverna sem destino: %s" % name)
		return
	_atravessar(corpo, marcador.global_position)


func _atravessar(jogador: Node2D, chegada: Vector2) -> void:
	_em_transicao = true
	jogador.set_travado(true)

	var camada := CanvasLayer.new()
	camada.layer = 100
	var tela := ColorRect.new()
	tela.color = Color(0, 0, 0, 0)
	tela.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tela.set_anchors_preset(Control.PRESET_FULL_RECT)
	camada.add_child(tela)
	get_tree().current_scene.add_child(camada)

	var entrada := camada.create_tween()
	entrada.tween_property(tela, "color:a", 1.0, duracao_fade)
	await entrada.finished

	if is_instance_valid(jogador):
		jogador.global_position = chegada
		var camera := jogador.get_node_or_null("Camera2D") as Camera2D
		if camera:
			camera.reset_smoothing()
	await get_tree().physics_frame

	var saida := camada.create_tween()
	saida.tween_property(tela, "color:a", 0.0, duracao_fade)
	await saida.finished

	camada.queue_free()
	if is_instance_valid(jogador):
		jogador.set_travado(false)
	_em_transicao = false
