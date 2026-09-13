extends Node2D

@export var musica_combate: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.stop_music()
	
	AudioManager.play_music(musica_combate, -24.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
