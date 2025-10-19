extends Node2D

@onready var buttonSound = $ButtonSound

func _ready():
	pass 

func _process(delta):
	pass

func _on_button_pressed():
	buttonSound.play()
	$".".hide()
