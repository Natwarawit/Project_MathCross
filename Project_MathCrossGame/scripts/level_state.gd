<<<<<<< HEAD
extends CanvasLayer

@onready var ui_root = $UIRoot
@onready var level_state = $"."
@onready var back_button = $UIRoot/Back

# ===============================
# Chain ของแต่ละด่าน
# ===============================
@onready var chains = [
	$UIRoot/Level2Button/Chain2,
	$UIRoot/Level3Button/Chain3,
	$UIRoot/Level4Button/Chain4,
	$UIRoot/Level5Button/Chain5,
	$UIRoot/Level6Button/Chain6,
	$UIRoot/Level7Button/Chain7
]

# ===============================
# ปุ่มด่าน
# ===============================
@onready var level_buttons = [
	$UIRoot/Level1Button,
	$UIRoot/Level2Button,
	$UIRoot/Level3Button,
	$UIRoot/Level4Button,
	$UIRoot/Level5Button,
	$UIRoot/Level6Button,
	$UIRoot/Level7Button
]

# ===============================
# จุดซูมของแต่ละด่าน
# ===============================
const LEVEL_ZOOM_POINTS = [
	Vector2(123,136),
	Vector2(188,277),
	Vector2(275,63),
	null,
	null,
	null,
	null
]

# ===============================
# ตัวแปรระบบ
# ===============================
var max_unlocked_level : int = 1
var hovered_button : Control = null
var canvas_tween : Tween

@export var button_zoom_scale := Vector2(1.2,1.2)
@export var button_zoom_time := 0.18

@export var canvas_zoom_scale := Vector2(2,2)
@export var canvas_zoom_time := 0.8


# ===============================
# READY
# ===============================
func _ready():

	back_button.pressed.connect(_on_back_pressed)

	_load_progress()
	_update_level_ui()

	ui_root.scale = Vector2.ONE
	ui_root.pivot_offset = ui_root.size / 2

	for i in range(level_buttons.size()):
		var btn : Control = level_buttons[i]

		btn.mouse_entered.connect(func():
			_on_button_hover(btn,i)
		)

		btn.mouse_exited.connect(func():
			_reset_button(btn)
		)


# ===============================
# BUTTON HOVER ZOOM
# ===============================
func _on_button_hover(btn:Control,index:int):

	if index + 1 > max_unlocked_level:
		return

	if hovered_button == btn:
		return

	hovered_button = btn
	btn.pivot_offset = btn.size / 2
	btn.z_index = 10

	create_tween() \
	.tween_property(btn,"scale",button_zoom_scale,button_zoom_time) \
	.set_trans(Tween.TRANS_BACK) \
	.set_ease(Tween.EASE_OUT)


func _reset_button(btn:Control):

	btn.z_index = 0
	create_tween().tween_property(btn,"scale",Vector2.ONE,button_zoom_time)

	if hovered_button == btn:
		hovered_button = null


# ===============================
# ZOOM → เข้าปุ่ม
# ===============================
func zoom_ui_to_button_and_then(btn:Control,action:Callable):

	if canvas_tween:
		canvas_tween.kill()

	var btn_center_global:Vector2 = btn.global_position + btn.size / 2
	var pivot_local:Vector2 = ui_root.global_transform.affine_inverse() * btn_center_global
	ui_root.pivot_offset = pivot_local

	canvas_tween = create_tween()

	canvas_tween \
	.tween_property(ui_root,"scale",canvas_zoom_scale,canvas_zoom_time) \
	.set_trans(Tween.TRANS_SINE) \
	.set_ease(Tween.EASE_IN_OUT)

	await canvas_tween.finished

	ui_root.scale = Vector2.ONE
	ui_root.pivot_offset = ui_root.size / 2

	action.call()


# ===============================
# ZOOM → จุดตายตัว
# ===============================
func zoom_ui_to_point_and_then(pivot_point:Vector2,action:Callable):

	if canvas_tween:
		canvas_tween.kill()

	ui_root.pivot_offset = pivot_point

	canvas_tween = create_tween()

	canvas_tween \
	.tween_property(ui_root,"scale",canvas_zoom_scale,canvas_zoom_time) \
	.set_trans(Tween.TRANS_SINE) \
	.set_ease(Tween.EASE_IN_OUT)

	await canvas_tween.finished

	ui_root.scale = Vector2.ONE
	ui_root.pivot_offset = ui_root.size / 2

	action.call()


# ===============================
# BACK
# ===============================
func _on_back_pressed():

	if canvas_tween:
		canvas_tween.kill()

	ui_root.scale = Vector2.ONE
	ui_root.pivot_offset = ui_root.size / 2

	level_state.hide()


# ===============================
# LEVEL BUTTONS
# ===============================
func _on_level_1_pressed():
	enter_level(1,"res://level/level_1.tscn",level_buttons[0])

func _on_level_2_pressed():
	enter_level(2,"res://level/level_2.tscn",level_buttons[1])

func _on_level_3_pressed():
	enter_level(3,"res://level/level_3.tscn",level_buttons[2])

func _on_level_4_pressed():
	enter_level(4,"res://level/level_4.tscn",level_buttons[3])

func _on_level_5_pressed():
	enter_level(5,"res://level/level_5.tscn",level_buttons[4])

func _on_level_6_pressed():
	enter_level(6,"res://level/level_6.tscn",level_buttons[5])

func _on_level_7_pressed():
	enter_level(7,"res://level/level_7.tscn",level_buttons[6])


# ===============================
# ENTER LEVEL
# ===============================
func enter_level(level:int,scene_path:String,btn:Control):

	if level > max_unlocked_level:
		print("Level ",level," ยังไม่ถูกปลดล็อก!")
		return

	var index = level - 1

	if index < LEVEL_ZOOM_POINTS.size() and LEVEL_ZOOM_POINTS[index] != null:

		zoom_ui_to_point_and_then(LEVEL_ZOOM_POINTS[index],func():
			get_tree().change_scene_to_file(scene_path)
		)

	else:

		zoom_ui_to_button_and_then(btn,func():
			get_tree().change_scene_to_file(scene_path)
		)


# ===============================
# UNLOCK SYSTEM
# ===============================
func unlock_next_level(current_level:int):

	if current_level > global.last_cleared_stage:
		global.last_cleared_stage = current_level

	max_unlocked_level = global.last_cleared_stage + 1
	max_unlocked_level = clamp(max_unlocked_level,1,level_buttons.size())

	_update_level_ui()


func _update_level_ui():

	for i in range(level_buttons.size()):

		if i < max_unlocked_level:

			level_buttons[i].disabled = false

			if i > 0:
				chains[i-1].hide()

		else:

			level_buttons[i].disabled = true
			level_buttons[i].scale = Vector2.ONE

			if i > 0:
				chains[i-1].show()


# ===============================
# LOAD PROGRESS จาก GLOBAL
# ===============================
func _load_progress():

	max_unlocked_level = global.last_cleared_stage + 1
	max_unlocked_level = clamp(max_unlocked_level,1,level_buttons.size())
=======
extends Node2D 

@onready var level_state = $"."
@onready var back_button = $Back

# เก็บ chain แต่ละด่าน
@onready var chains = [
	$Level2Button/Chain2,
	$Level3Button/Chain3,
	$Level4Button/Chain4,
	$Level5Button/Chain5,
	$Level6Button/Chain6,
	$Level7Button/Chain7
]

# เก็บปุ่มกดเลเวล
@onready var level_buttons = [
	$Level1Button,
	$Level2Button,
	$Level3Button,
	$Level4Button,
	$Level5Button,
	$Level6Button,
	$Level7Button
]

# เก็บเลเวลที่ปลดล็อกล่าสุด (ค่าเริ่มต้นคือ 1)
var max_unlocked_level: int = 1

func _ready():
	back_button.connect("pressed", Callable(self, "_on_back_pressed"))

	# โหลดค่าที่เคยปลดล็อกจาก save (ถ้ามี)
	_load_progress()
	
	#max_unlocked_level = 1
	#_save_progress()
	# อัปเดตสถานะปุ่มและ chain
	_update_level_ui()


func _on_back_pressed():
	level_state.hide()


# ฟังก์ชันใช้สำหรับเข้าเลเวล (ตรวจสอบก่อนเข้า)
func enter_level(level: int, scene_path: String):
	if level <= max_unlocked_level:
		get_tree().change_scene_to_file(scene_path)
	else:
		print("Level ", level, " ยังไม่ถูกปลดล็อก!")


func _on_level_1_pressed():
	$"1".show()

func _on_level_2_pressed():
	enter_level(2, "res://level/level_2.tscn")

func _on_level_3_pressed():
	enter_level(3, "res://level/level_3.tscn")

func _on_level_4_pressed():
	enter_level(4, "res://level/level_4.tscn")

func _on_level_5_pressed():
	enter_level(5, "res://level/level_5.tscn")

func _on_level_6_pressed():
	enter_level(6, "res://level/level_6.tscn")

func _on_level_7_pressed():
	enter_level(7, "res://level/level_7.tscn")


# ========================
# การจัดการการปลดล็อก
# ========================

# เรียกฟังก์ชันนี้เมื่อผู้เล่น "ผ่านเลเวล"
func unlock_next_level(current_level: int):
	if current_level == max_unlocked_level and max_unlocked_level < 7:
		max_unlocked_level += 1
		print("ปลดล็อก Level ", max_unlocked_level)
		_save_progress()
		_update_level_ui()


# อัปเดต UI ของปุ่มและ chain ตามสถานะการปลดล็อก
func _update_level_ui():
	for i in range(level_buttons.size()):
		if i < max_unlocked_level:
			level_buttons[i].disabled = false
			if i > 0: # chain เริ่มจาก level 2 ขึ้นไป
				chains[i - 1].hide()
		else:
			level_buttons[i].disabled = true
			if i > 0:
				chains[i - 1].show()


# ========================
# Save / Load
# ========================

func _save_progress():
	var save_data = {"max_level": max_unlocked_level}
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	file.store_var(save_data)
	file.close()

func _load_progress():
	if FileAccess.file_exists("user://savegame.save"):
		var file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var save_data = file.get_var()
		file.close()
		if "max_level" in save_data:
			max_unlocked_level = save_data["max_level"]


func _on_button_2_pressed():
	enter_level(1, "res://level/level_1.tscn")


func _on_button_pressed():
	$"1".hide()
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
