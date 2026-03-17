extends Node2D

@onready var buttonSound = $ButtonSound

func _on_button_pressed():
	buttonSound.play()
	hide()
