extends Node2D

const ARROW = preload("res://bow/arrow.tscn")
@onready var muzzle: Marker2D = $Marker2D

func _process(delta: float) -> void:
	# หันไปทางเมาส์ตลอดเวลา
	look_at(get_global_mouse_position())
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	
	# กลับด้าน sprite ตามองศา
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1

# ฟังก์ชันยิงลูกธนู เรียกจาก player.gd
func shoot_arrow():
	var arrow_instance = ARROW.instantiate()
	get_tree().root.add_child(arrow_instance)
	arrow_instance.global_position = muzzle.global_position
	arrow_instance.rotation = rotation
	$AudioStreamPlayer.play()
