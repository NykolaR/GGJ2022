extends Control

func set_text(seconds : int) -> void:
	$VBoxContainer/Lived.text = "YOU LIVED " + str(seconds) + " SECONDS"
