extends Sprite2D

@onready var label = $Text
@onready var texture_number: TextureRect = $TextureRect
@onready var anim_sprite = $AnimatedSprite2D

@export var coin_cost := 1
@export var qid := 0

var player_chase := false
var player = null
var is_dead := false
var has_received_all := false

# ===============================
# Rolling system
# ===============================
var is_rolling := false
var rolling_time := 0.0
var rolling_duration := 5.0
var rolling_interval_timer := 0.0
var min_interval := 0.02
var max_interval := 0.2

# ⭐ เวลาสุ่มตามจำนวนเลข
var base_roll_time := 5.0
var min_roll_time := 1.0
var max_numbers := 8.0

var no_coin_lock := false
var no_coin_timer := 0.0
const NO_COIN_LOCK_TIME := 3.0

var final_number := 0

# ===============================
# State
# ===============================
var cooldown_time := 0.0

var received_numbers: Array = []
var available_numbers: Array = []

# ===============================
# Popup Effect
# ===============================
var start_pos: Vector2 = Vector2(-7, -9)
var end_pos: Vector2 = Vector2(-7, -29)
var float_tween: Tween = null

# ===============================
# REALTIME MAGNET SYSTEM
# ===============================
var is_flying := false
var fly_speed := 0.0


# ===============================
# READY
# ===============================
func _ready():
	label.text = ""
	label.visible = false

	texture_number.visible = false
	texture_number.modulate = Color(1,1,1,1)

	randomize()
	_set_available_numbers()


# ===============================
# SET QID
# ===============================
func set_qid(value):
	qid = value
	_set_available_numbers()


# ===============================
# AVAILABLE NUMBERS
# ===============================
func _set_available_numbers():

	if qid == 0:
		available_numbers = [1,4,11]
		
	# level1
	elif qid == 1:
		available_numbers = [7, 2, 12, 5, 9]
	elif qid == 2:
		available_numbers = [11, 6, 2, 14, 8]
	elif qid == 3:
		available_numbers = [15, 4, 13, 16, 10]
		
	# level2
	elif qid == 4:
		available_numbers = [10, 24, 15, 11, 21]
	elif qid == 5:
		available_numbers = [16, 12, 18, 23, 27]
	elif qid == 6:
		available_numbers = [50, 19, 14, 20, 30]
		
	# level3
	elif qid == 7:
		available_numbers = [4, 18, 7, 31, 12]
	elif qid == 8:
		available_numbers = [5, 15, 28, 9, 27]
	elif qid == 9:
		available_numbers = [4, 22, 42, 16, 35]
		
	# level4
	elif qid == 10:
		available_numbers = [1, 6, 2, 9, 5, 30]
	elif qid == 11:
		available_numbers = [2, 4, 7, 10, 11, 28]
	elif qid == 12:
		available_numbers = [2, 6, 13, 10, 14, 18]
	elif qid == 13:
		available_numbers = [20, 8, 45, 48, 36, 2]
		
	# level5
	elif qid == 14:
		available_numbers = [1, 6, 2, 3, 4, 36]
	elif qid == 15:
		available_numbers = [2, 3, 4, 5, 7, 48]
	elif qid == 16:
		available_numbers = [3, 4, 6, 9, 12, 54]
	elif qid == 17:
		available_numbers = [36, 8, 16, 72, 96, 2]
		
	#level6
	elif qid == 18:
		available_numbers = [1, 3, 12, 22, 42, 5, 7]
	elif qid == 19:
		available_numbers = [2, 4, 10, 15, 24, 14, 16]
	elif qid == 20:
		available_numbers = [2, 12, 17, 20, 25, 22, 23]
	elif qid == 21:
		available_numbers = [3, 4, 31, 36, 40, 12, 22]
	elif qid == 22:
		available_numbers = [50, 53, 66, 70, 28, 60, 2]
		
	# level7
	elif qid == 23:
		available_numbers = [2, 11, 7, 32, 24, 37, 54, 90]

	elif qid == 24:
		available_numbers = [3, 60, 4, 12, 13, 36, 39, 50]

	elif qid == 25:
		available_numbers = [4, 63, 11, 18, 23, 24, 37, 57]

	elif qid == 26:
		available_numbers = [2, 108, 4, 6, 13, 15, 36, 58]

	elif qid == 27:
		available_numbers = [3, 6, 9, 18, 24, 36, 114, 123]

	elif qid == 28:
		available_numbers = [2, 4, 6, 18, 24, 36, 58, 50]

	received_numbers.clear()
	has_received_all = false
	cooldown_time = 0


# ===============================
# PHYSICS PROCESS
# ===============================
func _physics_process(delta):

	# ⭐ เลขดูดเข้าผู้เล่นแบบ real time
	if is_flying and player != null:

		var dir = (player.global_position - texture_number.global_position).normalized()

		fly_speed += 1400 * delta
		texture_number.global_position += dir * fly_speed * delta

		if texture_number.global_position.distance_to(player.global_position) < 20:
			texture_number.visible = false
			is_flying = false
			$"../player/Inv_UI2".add_choice_to_inventory(final_number)
			return


	if no_coin_lock:

		no_coin_timer -= delta

		label.text = "❌ coin ไม่พอ\nรอ " + str(int(ceil(no_coin_timer))) + " วิ"
		label.visible = true

		if no_coin_timer <= 0:
			no_coin_lock = false
			label.visible = false

		return


	if has_received_all:
		return


	if cooldown_time > 0:
		cooldown_time -= delta
		label.text = "รอ " + str(int(ceil(cooldown_time))) + " วิ"
		label.visible = true
		return
	else:
		label.visible = false


	if is_rolling:
		_process_rolling(delta)
		return


	# ⭐ กด F ครั้งเดียว
	if player_chase and is_dead:

		if Input.is_action_just_pressed("F") and not no_coin_lock:

			if player != null:

				var coin = player.get_coin_count()

				if coin < coin_cost:

					label.text = "❌ ต้องใช้ coin " + str(coin_cost)
					label.visible = true

					no_coin_lock = true
					no_coin_timer = NO_COIN_LOCK_TIME
					return


				if player.consume_coin(coin_cost):

					anim_sprite.play("open")
					start_rolling()

				else:
					label.text = "❌ coin ไม่พอ"
					label.visible = true


# ===============================
# ROLLING PROCESS
# ===============================
func _process_rolling(delta):

	rolling_time += delta
	rolling_interval_timer += delta

	var t: float = clamp(rolling_time / rolling_duration, 0.0, 1.0)
	var eased_t: float = ease_out(t)
	var current_interval: float = lerp(min_interval, max_interval, eased_t)

	if rolling_interval_timer >= current_interval:
		rolling_interval_timer = 0.0
		final_number = available_numbers.pick_random()
		set_number_texture(final_number)

	if rolling_time >= rolling_duration:
		stop_rolling()


# ===============================
# START ROLLING
# ===============================
func start_rolling():

	if available_numbers.is_empty():

		has_received_all = true
		label.text = "คุณได้รับตัวเลขทั้งหมดแล้ว!"
		label.visible = true
		return

	# ⭐ เวลาสุ่มตามจำนวนเลขที่เหลือ
	var remain = float(available_numbers.size())
	rolling_duration = clamp(base_roll_time * (remain / max_numbers), min_roll_time, base_roll_time)

	is_rolling = true
	rolling_time = 0
	rolling_interval_timer = 0
	final_number = 0

	texture_number.visible = true
	texture_number.position = start_pos
	texture_number.modulate = Color(1,1,1,1)

	if float_tween:
		float_tween.kill()

	float_tween = create_tween()

	float_tween.tween_property(
		texture_number,
		"position",
		end_pos,
		0.15
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


# ===============================
# STOP ROLLING
# ===============================
func stop_rolling():

	is_rolling = false

	available_numbers.erase(final_number)
	received_numbers.append(final_number)

	if float_tween:
		float_tween.kill()
		float_tween = null

	play_finish_effect(final_number)

	await get_tree().create_timer(0.6).timeout
	fly_to_player(final_number)

	cooldown_time = 5
	$collectnumber.play()


# ===============================
# START MAGNET
# ===============================
func fly_to_player(num:int):

	if player == null:
		return

	is_flying = true
	fly_speed = 100


# ===============================
# FINISH EFFECT
# ===============================
func play_finish_effect(num:int):

	set_number_texture(num)

	var tween := create_tween()

	var shake := 3.0

	for i in range(4):

		tween.tween_property(
			texture_number,
			"position",
			texture_number.position + Vector2(randf_range(-shake,shake),0),
			0.03
		)

	tween.tween_property(texture_number,"position",texture_number.position,0.03)


	for i in range(3):

		tween.tween_property(texture_number,"modulate",Color(1.4,1.4,1.4,1),0.08)
		tween.tween_property(texture_number,"modulate",Color(1,1,1,1),0.08)

	tween.tween_interval(0.5)


# ===============================
# TEXTURE
# ===============================
func set_number_texture(num:int):

	var path:String = "res://drop_numbers/number_%d.png" % num

	if ResourceLoader.exists(path):
		texture_number.texture = load(path)


# ===============================
# EASE OUT
# ===============================
func ease_out(t:float) -> float:
	return 1.0 - pow(1.0 - t,3)


# ===============================
# DETECTION AREA
# ===============================
func _on_detection_area_body_entered(body):

	if body.name == "player":

		player_chase = true
		player = body
		is_dead = true

		label.text = "กด F เพื่อสุ่มเลข (ใช้ coin " + str(coin_cost) + ")"
		label.visible = true


func _on_detection_area_body_exited(body):

	if body.name == "player":

		player_chase = false
		label.visible = false
