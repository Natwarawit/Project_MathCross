extends CanvasLayer

func _on_playagain_pressed() -> void:
	await get_tree().create_timer(0.5).timeout
	var path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(path)



func _on_backtorest_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/rest.tscn")
