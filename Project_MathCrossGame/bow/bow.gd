extends Node2D

<<<<<<< HEAD
# ==================================================
# Resource
# ==================================================
const ARROW = preload("res://bow/arrow.tscn")

# ==================================================
# Nodes
# ==================================================
@onready var muzzle: Marker2D = $Marker2D
@onready var visual: Node2D = $Visual
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

# ==================================================
# Config (ค่าปรับแต่ง)
# ==================================================
const SHOOT_COOLDOWN := 1.0
const MAX_CHARGE := 2.0
const MIN_MULT := 1.0
const MAX_MULT := 4.0
const SHAKE_POWER := 2.5
const PULL_DISTANCE := -10.0
const MAX_STRETCH := 1.5

# ==================================================
# State
# ==================================================
var is_charging := false
var charge_time := 0.0
var can_shoot := true

# ==================================================
# Main Loop
# ==================================================
func _process(delta: float) -> void:
	_update_rotation()
	_update_charge_visual(delta)

# ==================================================
# Aim System
# ==================================================
func _update_rotation():
	look_at(get_global_mouse_position())
	rotation_degrees = wrap(rotation_degrees, 0, 360)

=======
const ARROW = preload("res://bow/arrow.tscn")
@onready var muzzle: Marker2D = $Marker2D

func _process(delta: float) -> void:
	# หันไปทางเมาส์ตลอดเวลา
	look_at(get_global_mouse_position())
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	
	# กลับด้าน sprite ตามองศา
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1

<<<<<<< HEAD
# ==================================================
# Charge Visual System
# ==================================================
func _update_charge_visual(delta: float):

	if is_charging:
		charge_time += delta
		charge_time = min(charge_time, MAX_CHARGE)

		var t: float = charge_time / MAX_CHARGE
		var power_curve: float = pow(t, 2.2)

		visual.position.x = lerp(0.0, PULL_DISTANCE, power_curve)
		visual.scale.x = lerp(1.0, MAX_STRETCH, power_curve)
		visual.scale.y = lerp(1.0, 0.75, power_curve)

		var shake_strength: float = t * SHAKE_POWER
		visual.position.y = sin(Time.get_ticks_msec() * 0.05) * shake_strength

	else:
		visual.position = visual.position.lerp(Vector2.ZERO, 10 * delta)
		visual.scale = visual.scale.lerp(Vector2.ONE, 10 * delta)

# ==================================================
# Charge System
# ==================================================
func start_charge():
	if !can_shoot:
		return

	is_charging = true
	charge_time = 0.0

func release_charge() -> void:
	if !is_charging:
		return

	is_charging = false
	can_shoot = false

	var percent: float = charge_time / MAX_CHARGE
	var damage_mult: float = lerp(MIN_MULT, MAX_MULT, percent)

	spawn_arrow(damage_mult)
	start_cooldown()
	play_release_animation()

# ==================================================
# Shoot System
# ==================================================
func spawn_arrow(multiplier: float):

	var arrow_instance = ARROW.instantiate()
	get_tree().root.add_child(arrow_instance)

	arrow_instance.global_position = muzzle.global_position
	arrow_instance.rotation = rotation

	var size_mult = lerp(1.0, 2.5, multiplier / MAX_MULT)
	arrow_instance.scale = Vector2.ONE * size_mult

	arrow_instance.set_damage_multiplier(multiplier)

	# ยิงเสียง
	var pitch = lerp(1.0, 1.8, multiplier / MAX_MULT)
	audio.pitch_scale = pitch
	audio.play()

# ==================================================
# Bow Animation
# ==================================================
func play_release_animation():

	var tween = get_tree().create_tween()

	visual.scale = Vector2(1.8, 0.6)
	visual.position.x = 6

	tween.tween_property(visual, "scale", Vector2.ONE, 0.12)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(visual, "position", Vector2.ZERO, 0.12)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

# ==================================================
# Cooldown System
# ==================================================
func start_cooldown():
	await get_tree().create_timer(SHOOT_COOLDOWN).timeout
	can_shoot = true
=======
# ฟังก์ชันยิงลูกธนู เรียกจาก player.gd
func shoot_arrow():
	var arrow_instance = ARROW.instantiate()
	get_tree().root.add_child(arrow_instance)
	arrow_instance.global_position = muzzle.global_position
	arrow_instance.rotation = rotation
	$AudioStreamPlayer.play()
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
