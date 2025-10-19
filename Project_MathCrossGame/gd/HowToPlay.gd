extends Node2D

@onready var howtoplay = $"."

func _ready():
	pass

func _process(delta):
	pass

func _on_button_pressed():
	howtoplay.hide()
	$"../ControlButton".show()
