extends Node2D



func copy_from_player(src: AnimatedSprite2D):
	# 👉 ให้ ghost อยู่ระดับเดียวหรือสูงกว่า player
	z_index = src.z_index + 1

	# copy transform ทั้งก้อน
	global_transform = src.global_transform

	var anim := $AnimatedSprite2D
	anim.sprite_frames = src.sprite_frames
	anim.animation = src.animation
	anim.frame = src.frame
	anim.flip_h = src.flip_h
	anim.flip_v = src.flip_v
	anim.offset = src.offset

	start_ghosting()


func start_ghosting():
	var tween = get_tree().create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate:a", 0.0, 0.6)
	await tween.finished
	queue_free()
