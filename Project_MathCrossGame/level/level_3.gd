extends Node2D

# ==================================================
# UI (Mission)
# ==================================================
@onready var hp_label: Label = $CanvasLayer/Mission/hp
@onready var incorrect_label: Label = $CanvasLayer/Mission/incorrect
@onready var regen_label: Label = $CanvasLayer/Mission/regen
@onready var clear_label: Label = $CanvasLayer/Mission/clear

# ==================================================
# Victory UI
# ==================================================
@onready var victory_layer := $CanvasLayer2
@onready var victory_label_percent: Label = $CanvasLayer2/Label2
@onready var victory_label_reward: Label = $CanvasLayer2/Label3

# ==================================================
# State
# ==================================================
var player_in_area := false
var player_chase = false
# Gate
var math_cleared := false
var gate_unlocked := false

# Mission values
var incorrect_count := 0
var eat_count := 0

# ==================================================
# Ready
# ==================================================
func _ready():
	$portal.play("default")

	# ซ่อน Victory ตอนเริ่ม
	victory_layer.visible = false

	# Player
	if has_node("player"):
		$player.apple_eaten.connect(_on_player_apple_eaten)

	# MathCross
	if has_node("mathcross"):
		$mathcross.mathcross_completed.connect(_on_mathcross_completed)

# ==================================================
# Process
# ==================================================
func _process(delta):
	_update_mission_ui()

	if player_in_area and Input.is_action_just_pressed("F"):
		if _can_enter_portal():
			var result = calculate_mission_result()
			give_coin_to_inventory(result.coin)
			show_victory_screen(result.percent, result.coin)

# ==================================================
# Signals
# ==================================================
# 🍎 ฟื้นฟูเลือด
func _on_player_apple_eaten():
	eat_count += 1

# 🧮 เคลียร์ MathCross
func _on_mathcross_completed(_incorrect_count: int):
	math_cleared = true
	gate_unlocked = true
	incorrect_count = _incorrect_count

# ==================================================
# Mission UI
# ==================================================
func _update_mission_ui():
	var player = $player

	# ---------- Clear ----------
	if math_cleared:
		clear_label.text = "เคลียร์ด่าน ✔"
		clear_label.modulate = Color(0, 1, 0)
	else:
		clear_label.text = "ยังไม่เคลียร์ด่าน ✘"
		clear_label.modulate = Color(1, 0, 0)

	# ---------- ยังไม่ปลดล็อก ----------
	if not gate_unlocked:
		_set_gray(hp_label, "HP > 50% (รอเคลียร์ด่าน)")
		_set_gray(incorrect_label, "ตอบผิด ≤ 3 (รอเคลียร์ด่าน)")
		_set_gray(regen_label, "ฟื้นฟู < 3 (รอเคลียร์ด่าน)")
		return

	# ---------- HP ----------
	if player.health > global.max_health * 0.5:
		_set_green(hp_label, "HP > 50% ✔")
	else:
		_set_red(hp_label, "HP ต้องมากกว่า 50% ✘")

	# ---------- Incorrect ----------
	if incorrect_count <= 3:
		_set_green(incorrect_label, "ตอบผิด: %d / 3 ✔" % incorrect_count)
	else:
		_set_red(incorrect_label, "ตอบผิดเกิน 3 ครั้ง ✘")

	# ---------- Regen ----------
	if eat_count < 3:
		_set_green(regen_label, "ฟื้นฟูเลือด: %d / 2 ✔" % eat_count)
	else:
		_set_red(regen_label, "ฟื้นฟูเลือดเกิน 2 ครั้ง ✘")

# ==================================================
# Portal Logic
# ==================================================
func _can_enter_portal() -> bool:
	# เข้าได้ แค่เคลียร์ด่านก็พอ
	return math_cleared

# ==================================================
# Mission Result
# ==================================================
func calculate_mission_result() -> Dictionary:
	var player = $player
	var passed := 0
	var total := 4

	if math_cleared:
		passed += 1
	if player.health > global.max_health * 0.5:
		passed += 1
	if incorrect_count <= 3:
		passed += 1
	if eat_count < 3:
		passed += 1

	var percent := int((float(passed) / total) * 100)

	var coin := 0
	if percent == 100:
		coin = 5
	elif percent >= 50:
		coin = 3
	else:
		coin = 2

	return {
		"passed": passed,
		"percent": percent,
		"coin": coin
	}

# ==================================================
# Victory Screen
# ==================================================
func show_victory_screen(percent: int, amount: int):

	# ซ่อน UI ด่าน
	$CanvasLayer.visible = false

	# แสดง Victory
	victory_layer.visible = true
	victory_label_percent.text = "สำเร็จภารกิจ " + str(percent) + "%"
	victory_label_reward.text = "ได้รับรางวัล " + str(amount) + " coin"

	print("🏆 Victory:", percent, "% |", amount, "coin")

# ==================================================
# Inventory
# ==================================================
func give_coin_to_inventory(amount: int):
	var inv_ui = $"player/Inv_UI2"
	if inv_ui == null:
		print("❌ ไม่พบ Inv_UI2")
		return

	var coin_name := "coin"
	var current := 0

	for slot in inv_ui.inv_misc.slots:
		if slot != null and slot.item != null and slot.item.name == coin_name:
			current = slot.amount
			break

	inv_ui.set_item_count_misc(coin_name, current + amount)
	print(" ได้รับ coin:", amount, "รวมเป็น", current + amount)

# ==================================================
# UI Utils
# ==================================================
func _set_green(label: Label, text: String):
	label.text = text
	label.modulate = Color(0, 1, 0)

func _set_red(label: Label, text: String):
	label.text = text
	label.modulate = Color(1, 0, 0)

func _set_gray(label: Label, text: String):
	label.text = text
	label.modulate = Color(0.6, 0.6, 0.6)

# ==================================================
# Portal Area
# ==================================================
func _on_portal_area_body_entered(body):
	if body.name == "player":
		player_in_area = true

func _on_portal_area_body_exited(body):
	if body.name == "player":
		player_in_area = false

func _on_next_button_pressed():
	print("➡ จบด่าน 3")
	global.last_cleared_stage = 3
	var player = $player
	if player != null:
		player.change_scene_clean("res://scenes/story.tscn")


func _on_player_died():
	print("💀 Player died → hide mission UI")
	$player/healthbarcanvas.visible = false
	$player/Hotbarcanvas.visible = false
	$player/status.visible = false
	$player/ability.visible = false
	$player/CanvasLayer.visible = false
	$CanvasLayer.visible = false   # ปิด Mission UI
	$CanvasLayer2.visible = false  # ปิด Victory (กันค้าง)
