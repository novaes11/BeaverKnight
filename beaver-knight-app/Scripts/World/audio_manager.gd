extends Node


# Reforço de volume só na versão Web (dB), sobre os barramentos do projeto.
const GANHO_WEB_MUSICA := 14.0
const GANHO_WEB_EFEITOS := 8.0

#2 Variaveis que definem a quantidade de audios que podem tocar ao mesmo tempo
var pool_Tamanho: int = 8

# Pool de áudio Global
var sfx_players: Array[AudioStreamPlayer] = []

# Pool de áudio Posicional
var sfx_2d_players: Array[AudioStreamPlayer2D] = []

# Player de musica
var musica_player: AudioStreamPlayer

#Cria os Arrays de AudioStreamPlayer
func _ready() -> void:
	# O áudio continua respondendo na tela de pausa e nas telas finais.
	process_mode = Node.PROCESS_MODE_ALWAYS
	if OS.has_feature("web"):
		_aplicar_ganho_web()

	# pool de efeitos sonoros
	for i in range(pool_Tamanho):
		var pool = AudioStreamPlayer.new()
		pool.bus = "Effect"
		add_child(pool)
		sfx_players.append(pool)
	
	# pool de efeitos posicionais
	for i in range(pool_Tamanho):
		var pool = AudioStreamPlayer2D.new()
		pool.bus = "Effect"
		add_child(pool)
		sfx_2d_players.append(pool)
	
	# Define a musica tocada atualmente
	musica_player = AudioStreamPlayer.new()
	musica_player.bus = "Music"
	add_child(musica_player)
	


func _aplicar_ganho_web() -> void:
	for par in [["Music", GANHO_WEB_MUSICA], ["Effect", GANHO_WEB_EFEITOS]]:
		var indice := AudioServer.get_bus_index(par[0])
		if indice >= 0:
			AudioServer.set_bus_volume_db(indice, AudioServer.get_bus_volume_db(indice) + par[1])

# Funções que controlam os efeitos sonoros
func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	#cancela se não foi achado audio
	if stream == null: 
		return
	
	#Procura um tocador livre
	for pool in sfx_players:
		if ! pool.playing:
			pool.stream = stream
			pool.volume_db = volume_db
			pool.pitch_scale = pitch_scale
			pool.play()
			return
	#Trava caso acabar os espaços de Stream de audio
	sfx_players[0].stream = stream
	sfx_players[0].volume_db = volume_db
	sfx_players[0].pitch_scale = pitch_scale
	sfx_players[0].play()

func play_sfx_2d(stream: AudioStream, global_posi: Vector2, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if stream == null:
		return
	
	for pool_2d in sfx_2d_players:
		if ! pool_2d.playing:
			pool_2d.stream = stream
			pool_2d.global_position = global_posi
			pool_2d.volume_db = volume_db
			pool_2d.pitch_scale = pitch_scale
			pool_2d.play()
			return
	#Trava caso acabar os espaços de Stream2D
	sfx_2d_players[0].stream = stream
	sfx_2d_players[0].global_position = global_posi
	sfx_2d_players[0].volume_db = volume_db
	sfx_2d_players[0].pitch_scale = pitch_scale
	sfx_2d_players[0].play()

# Função que controla a musica do jogo
func play_music(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	# Se a mesma música já estiver tocando, não reinicia
	if musica_player.stream == stream and musica_player.playing:
		return
	
	musica_player.stream = stream
	musica_player.volume_db = volume_db
	musica_player.play()

# Para a musica que esta sendo tocada
func stop_music():
	musica_player.stop()
