extends Node2D

@onready var howtoplay = $howtoplay
@onready var setting = $Setting
@onready var controlbutton = $ControlButton
@onready var animation = $AnimationPlayer
@onready var buttonSound = $ButtonSound
@onready var music = $Music

func _ready():
	animation.play("intro")
	get_tree().create_timer(3).connect("timeout", Callable(self, "_on_timer_timeout"))

func _on_play_pressed():
	buttonSound.play()
	await get_tree().create_timer(0.75).timeout
	get_tree().change_scene_to_file("res://scenes/story.tscn")

func _on_how_to_play_pressed():
	buttonSound.play()
	howtoplay.show()

func _on_timer_timeout():
	$ColorRect.visible = false
	$"Screenshot2025-03-23025113".visible = false
	music.play()

func _on_setting_pressed():
	buttonSound.play()
	setting.show()
	controlbutton.hide()

func _on_quit_pressed():
	buttonSound.play()
	get_tree().quit()
