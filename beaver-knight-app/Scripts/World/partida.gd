class_name Partida
extends Node
## Controla o ciclo de uma partida: praia -> refinaria -> boss -> vitória/derrota -> rejogar.

signal objetivo_mudou(texto: String)
signal aviso(texto: String)
signal vida_boss_mudou(atual: int, maximo: int)

enum Etapa { PRAIA, REFINARIA, BOSS, FIM }

const GRUPO := &"partida"
const ARQUIVO_RECORDE := "user://recorde.cfg"
const CENA_MENU := "res://Scene/main_menu.tscn"

@export var meta_praia: int = 6
@export var meta_refinaria: int = 10
## Cena do boss. Sem ela, concluir a refinaria encerra a partida com vitória.
@export var boss_scene: PackedScene
@export var ponto_boss := Vector2(402, -690)
@export var tela_fim_scene: PackedScene

var etapa: Etapa = Etapa.PRAIA
var derrotados_etapa := 0
var total_derrotados := 0
var tempo := 0.0
## Desligado pelos testes automáticos, para não alterar o recorde real do jogador.
var salvar_recorde := true

@onready var _player: Node2D = get_parent().get_node("Player")


func _ready() -> void:
	add_to_group(GRUPO)
	get_tree().paused = false
	_anunciar_objetivo.call_deferred()


func _process(delta: float) -> void:
	if etapa != Etapa.FIM:
		tempo += delta


func registrar_derrota() -> void:
	if etapa == Etapa.FIM:
		return
	total_derrotados += 1
	if etapa == Etapa.BOSS:
		return
	derrotados_etapa += 1
	if derrotados_etapa >= _meta_atual():
		_avancar()
	else:
		_anunciar_objetivo()


func avisar(texto: String) -> void:
	aviso.emit(texto)


func atualizar_vida_boss(atual: int, maximo: int) -> void:
	vida_boss_mudou.emit(atual, maximo)


func boss_derrotado() -> void:
	_encerrar(true)


func jogador_morreu() -> void:
	_encerrar(false)


func jogar_novamente() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func voltar_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(CENA_MENU)


func _meta_atual() -> int:
	return meta_praia if etapa == Etapa.PRAIA else meta_refinaria


func _avancar() -> void:
	derrotados_etapa = 0
	_player.curar_total()
	if etapa == Etapa.PRAIA:
		etapa = Etapa.REFINARIA
		avisar("PRAIA LIMPA! A CAVERNA ABRIU.")
		_anunciar_objetivo()
		return

	etapa = Etapa.BOSS
	if boss_scene == null:
		_encerrar(true)
		return
	avisar("O BOSS DE PETRÓLEO DESPERTOU!")
	_anunciar_objetivo()
	var boss := boss_scene.instantiate() as Node2D
	get_parent().add_child(boss)
	boss.global_position = ponto_boss


func _anunciar_objetivo() -> void:
	match etapa:
		Etapa.PRAIA:
			objetivo_mudou.emit("SUBA A ESCADA E LIMPE A PRAIA: %d/%d" % [derrotados_etapa, meta_praia])
		Etapa.REFINARIA:
			objetivo_mudou.emit("ENTRE NA CAVERNA E LIMPE A REFINARIA: %d/%d" % [derrotados_etapa, meta_refinaria])
		Etapa.BOSS:
			objetivo_mudou.emit("VÁ AO PÁTIO DA FÁBRICA E DERROTE O BOSS!")


func _encerrar(venceu: bool) -> void:
	if etapa == Etapa.FIM:
		return
	etapa = Etapa.FIM
	var recorde := _atualizar_recorde(venceu)
	get_tree().paused = true
	if tela_fim_scene:
		var tela := tela_fim_scene.instantiate()
		get_parent().add_child(tela)
		tela.mostrar(self, venceu, tempo, total_derrotados, recorde)


## Melhor tempo de vitória, salvo no navegador/computador do jogador. Retorna -1 se não houver.
func _atualizar_recorde(venceu: bool) -> float:
	var config := ConfigFile.new()
	config.load(ARQUIVO_RECORDE)
	var melhor: float = config.get_value("partida", "melhor_tempo", -1.0)
	if venceu and (melhor < 0.0 or tempo < melhor):
		melhor = tempo
		if salvar_recorde:
			config.set_value("partida", "melhor_tempo", melhor)
			config.save(ARQUIVO_RECORDE)
	return melhor
