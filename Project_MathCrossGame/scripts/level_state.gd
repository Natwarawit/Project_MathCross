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
