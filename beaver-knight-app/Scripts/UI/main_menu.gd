extends Control

@export var sfx_botao: AudioStream
@export var musica_menu: AudioStream


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.play_music(musica_menu, -20.0)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	AudioManager.play_sfx(sfx_botao, -28.0)
	get_tree().change_scene_to_file("res://Scene/town.tscn") # Replace with function body.
	

func _on_options_button_pressed() -> void:
	$MenuPanel.hide()
	$LeafFrame.hide()
	$HelpPanel.show()
	$HelpPanel/HelpContent/BackButton.grab_focus()
	AudioManager.play_sfx(sfx_botao, -28.0)

func _on_back_button_pressed() -> void:
	$HelpPanel.hide()
	$MenuPanel.show()
	$LeafFrame.show()
	$MenuPanel/Buttons/StartButton.grab_focus()
	AudioManager.play_sfx(sfx_botao, -28.0)

func _on_exit_button_pressed() -> void:
	AudioManager.play_sfx(sfx_botao, -28.0)
	get_tree().quit()
