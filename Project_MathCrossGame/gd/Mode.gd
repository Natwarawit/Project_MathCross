extends Control 

@onready var mode = $"." 
@onready var easy = $Easy
@onready var normal = $Normal 
@onready var hard = $Hard 
@onready var Broze = $"BrozePrize"
@onready var Silver = $"SilverPrize"
@onready var Gold = $"GoldPrize"



func _ready():
	mode.visible = true
	Broze.visible = false
	Silver.visible = false
	Gold.visible = false
	update_mode_buttons()
	# แสดงถ้วยรางวัลตามระดับที่ปลดล็อค
	if GameManager.unlocked_modes["easy"]:
		pass
	if GameManager.unlocked_modes["normal"]:
		Broze.visible = true
	if GameManager.unlocked_modes["hard"]:
		Silver.visible = true
	if GameManager.unlocked_modes["easy"] and GameManager.unlocked_modes["normal"] and GameManager.unlocked_modes["hard"]:
		Gold.visible = true

func _on_easy_pressed():
	if GameManager.unlocked_modes["easy"]:
		mode.visible = false
		get_tree().change_scene_to_file("res://tscn/EasyMode.tscn")

func _on_normal_pressed():
	if GameManager.unlocked_modes["normal"] and GameManager.unlocked_modes["easy"]:
		mode.visible = false
		get_tree().change_scene_to_file("res://tscn/NormalMode.tscn")

func _on_hard_pressed():
	if GameManager.unlocked_modes["hard"] and GameManager.unlocked_modes["normal"]:
		mode.visible = false
		get_tree().change_scene_to_file("res://tscn/HardMode.tscn")

# ฟังก์ชันสำหรับอัปเดตสถานะของปุ่มโหมด
func update_mode_buttons():
	normal.disabled = not GameManager.unlocked_modes["normal"]
	hard.disabled = not GameManager.unlocked_modes["hard"]


func _on_button_pressed():
	get_tree().change_scene_to_file("res://tscn/Main.tscn")
	pass # Replace with function body.
