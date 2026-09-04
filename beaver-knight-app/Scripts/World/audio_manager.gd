extends Node

var musica_volume: int

var sfx_volume: int

#2 Variaveis que definem a quantidade de audios que podem tocar ao mesmo tempo
var pool_Tamanho: int = 8
var tocador: Array[AudioStreamPlayer] = []

#Cria o Array da pool Imediatamente
func _ready() -> void:
	for i in range(pool_Tamanho):
		var pool = AudioStreamPlayer.new()
		add_child(pool)
		tocador.append(pool)

#Função que toca os sons
func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	#cancela se não foi achado audio
	if stream == null: 
		return
	
	#Procura um tocador livre
	for pool in tocador:
		if ! pool.playing:
			pool.stream = stream
			pool.volume_db = volume_db
			pool.play()
			return
		
	
	#Se estiver tudo cheio substitui o primeiro
	tocador[0].stream = stream
	tocador[0].volume_db = volume_db
	tocador[0].play()
	
