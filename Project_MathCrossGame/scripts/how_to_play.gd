extends Node2D

@onready var buttonSound = $ButtonSound

<<<<<<< HEAD
func _on_button_pressed():
	buttonSound.play()
	hide()
=======
func _ready():
	pass 

func _process(delta):
	pass

func _on_button_pressed():
	buttonSound.play()
	$".".hide()
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
