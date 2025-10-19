extends Control

@onready var storylabel = $StoryLabel

# ตัวแปรเพื่อเก็บข้อความที่จะไล่แสดง
var startstory = [
	"ตัวละคร B: เย้! เราทำได้แล้ว! โหมดง่ายนี่ทำให้ฉันรู้สึกมั่นใจขึ้นมากเลย!",
	"ตัวละคร A: ใช่แล้ว! เราเก่งกันมาก! ความสำเร็จนี้เป็นเพียงจุดเริ่มต้นเท่านั้น",
	"ตัวละคร B: ตอนแรกก็คิดว่าอาจจะยาก แต่พอทำไปแล้วกลับสนุกมากเลย!",
	"ตัวละคร A: นั่นล่ะ เราแค่ต้องมีความเชื่อในตัวเองและไม่ยอมแพ้",
	"ตัวละคร B: ต่อไปเราจะท้าทายตัวเองในโหมดปกติ! พร้อมแล้วหรือยัง?",
	"ตัวละคร A: พร้อมที่สุด! ไปดูกันว่าเราจะทำได้ดีแค่ไหน!",
	"ตัวละคร B: ฉันพร้อมจะชนะอีกครั้ง!"
]

var current_index = 0
var is_skipping = false

func _ready():
	add_child(storylabel)
	storylabel.text = ""
	# เริ่มการแสดงข้อความ
	show_next_message()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and !is_skipping:
		is_skipping = true
		# ข้ามไปยังข้อความถัดไปทันที
		if current_index < startstory.size():
			storylabel.text = startstory[current_index]
			current_index += 1
			is_skipping = false
			if current_index < startstory.size():
				show_next_message()  # เรียกดูข้อความถัดไป
		else:
			storylabel.text = ""  # หากจบแล้วให้ล้างข้อความ

func show_next_message():
	if current_index < startstory.size():
		is_skipping = false  # รีเซ็ตการข้ามเมื่อแสดงข้อความใหม่
		storylabel.text = startstory[current_index]
		current_index += 1
		await get_tree().create_timer(3).timeout
		show_next_message()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://tscn/Mode.tscn")
