extends Control

@onready var storylabel = $StoryLabel

# ตัวแปรเพื่อเก็บข้อความที่จะไล่แสดง
var startstory = [
	"ตัวละคร A: เฮ้! คุณได้ลองเล่น MathCross แล้วหรือยัง? ฉันบอกเลยว่ามันทั้งสนุกและท้าทาย!",
	"ตัวละคร B: ยังไม่ได้ลองเลย แต่เห็นคนพูดถึงบ่อยนะ มันมีหลายโหมดให้เลือกเล่นใช่ไหม?",
	"ตัวละคร A: ใช่เลย! มีสามโหมดให้เลือก—ง่าย, ปกติ, และยาก แต่ละโหมดก็มี 10 ด่าน และความยากเพิ่มขึ้นเรื่อยๆ!",
	"ตัวละคร B: โอ้ว น่าสนใจนะ! แล้ววิธีเล่นเป็นยังไงบ้างล่ะ?",
	"ตัวละคร A: ก็ง่ายๆ เลย เราต้องแก้สมการคณิตศาสตร์ในกริดเพื่อทำให้ช่องหายไป ยิ่งตอบถูกก็ยิ่งผ่านด่านเร็ว!",
	"ตัวละคร B: ฟังดูใช้สมองไม่เบาเลยนะ! ฉันคงต้องเริ่มจากโหมดง่ายก่อนล่ะ รู้สึกว่าต้องอุ่นเครื่องก่อน!",
	"ตัวละคร A: เป็นความคิดที่ดี! จริงๆ เล่นกับเพื่อนยิ่งมันส์กว่า เพราะเราช่วยกันแก้ปัญหาได้!",
	"ตัวละคร B: งั้นดีเลย! ลองเล่นโหมดง่ายสัก 10 ด่านด้วยกันดีไหม? จะได้ดูว่าเราจะไปได้ไกลแค่ไหน!",
	"ตัวละคร A: เจ๋ง! มาเริ่มกันเลย! ดูซิว่าพวกเราจะผ่านไปได้กี่ด่าน!"
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
