extends CanvasLayer

@onready var anim = $AnimationPlayer

func change_scene(scene_path):

	anim.play("fade_out")
	await anim.animation_finished

	get_tree().change_scene_to_file(scene_path)

	anim.play("fade_in")
