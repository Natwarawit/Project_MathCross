extends Node2D

var player_in_area = false

func _ready():
	$portal.play("default")

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("F"):
		get_tree().change_scene_to_file("res://scenes/storyendlevel1.tscn")

func _on_portal_area_body_entered(body):
	if body.name == "player":
		player_in_area = true

func _on_portal_area_body_exited(body):
	if body.name == "player":
		player_in_area = false
