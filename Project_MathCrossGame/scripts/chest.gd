extends Sprite2D  

@onready var label = $Text
@onready var inv: Inv = preload("res://inventory/playerinv.tres")
@export var qid = 0 

var player_chase = false
var player = null
var is_dead = false  
var has_received_all = false  
var hold_time = 0
var cooldown_time = 0 
var received_numbers: Array = []                  
var available_numbers: Array = []
@onready var anim_sprite = $AnimatedSprite2D

func _ready(): 
	label.text = ""
	label.visible = false
	randomize()
	_set_available_numbers()

# setter เวลาเปลี่ยนค่า qid
func set_qid(value):
	qid = value
	_set_available_numbers()

# ฟังก์ชันไว้ตั้งค่าเลขที่สุ่มได้ตาม qid
func _set_available_numbers():
	if qid == 0:
		available_numbers = [1,2,3,4,5,10]
	elif qid == 1:
		available_numbers = [2,3,5,4,6,9]
	elif qid == 2:
		available_numbers = [5,6,7,8,9]
	# เพิ่มเงื่อนไข qid อื่น ๆ ได้ตามต้องการ
	
	# รีเซ็ตสถานะ
	received_numbers.clear()
	has_received_all = false
	hold_time = 0
	cooldown_time = 0

func _physics_process(delta):
	if has_received_all:
		return

	if cooldown_time > 0:
		cooldown_time -= delta
		if cooldown_time > 0:
			label.text = "รอ " + str(int(round(cooldown_time))) + " วิก่อนเปิดกล่องใหม่"
			label.visible = true
		else:
			label.visible = false   # 🔹 ซ่อนข้อความเมื่อเหลือ 0 วิ
		return

	
	if player_chase and is_dead:
		# กด F ค้างไว้
		if Input.is_action_pressed("F"):
			# ให้เริ่มเล่น animation เฉพาะตอนเริ่มกด
			if not $AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play("open")

			hold_time += delta
			label.text = "กำลังเปิดกล่อง" +"\n"+  str(int(round(hold_time))) + " / 5 วินาที"
			label.visible = true
			$Text2.text = "" 
			
			if hold_time >= 2:
				if available_numbers.size() > 0:
					var random_num = available_numbers.pick_random()
					available_numbers.erase(random_num)
					received_numbers.append(random_num)
					
					print("สุ่มได้เลข: ", random_num)
					print("เลขที่ได้รับแล้ว: ", received_numbers)
					print("เลขที่เหลือให้สุ่ม: ", available_numbers)
					$"../player/Inv_UI2".add_choice_to_inventory(random_num)
					$Text2.text = "คุณได้รับปุ่มหมายเลข " + str(random_num)
				else:
					has_received_all = true
					label.text = "คุณได้รับตัวเลขทั้งหมดแล้ว!"
				hold_time = 0.0
				cooldown_time = 2
				$collectnumber.play()

		# ปล่อยปุ่ม F
		elif Input.is_action_just_released("F"):
			$AnimatedSprite2D.stop()
			$AnimatedSprite2D.frame = 0  # กลับไปเฟรมแรก (เลือกใส่หรือไม่ก็ได้)
			hold_time = 0.0


func _on_detection_area_body_entered(body):
	if body.name == "player":
		player_chase = true
		player = body
	
		if not has_received_all:
			label.text = "กด F ค้างเพื่อเปิดกล่อง"
		else:
			label.text = "คุณได้รับตัวเลขครบแล้ว!"
		label.visible = true
		is_dead = true

func _on_detection_area_body_exited(body):
	if body.name == "player":
		player_chase = false
		label.visible = false
		hold_time = 0
