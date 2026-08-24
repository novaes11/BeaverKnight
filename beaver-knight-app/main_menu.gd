extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://town.tscn") # Replace with function body.


func _on_options_button_pressed() -> void:
	$MenuPanel.hide()
	$LeafFrame.hide()
	$HelpPanel.show()
	$HelpPanel/HelpContent/BackButton.grab_focus()


func _on_back_button_pressed() -> void:
	$HelpPanel.hide()
	$MenuPanel.show()
	$LeafFrame.show()
	$MenuPanel/Buttons/StartButton.grab_focus()
	

func _on_exit_button_pressed() -> void:
	get_tree().quit()
