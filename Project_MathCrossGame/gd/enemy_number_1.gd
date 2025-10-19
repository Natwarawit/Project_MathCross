extends CharacterBody2D

@onready var target = $"../Player"
@onready var drop = "res://drop_numbers/number1.png"
@onready var drop_label = $Label  # Ensure this is the correct path

var original_position: Vector2
var speed = 150
var detection_range = 300
var stop_threshold = 10
var health = 10
var attack_damage = 20
var attack_range = 50
var player_inattack_zone = false
var can_take_damage = true
var player = null
var player_chase = false

func _ready():
	original_position = position

	# Ensure drop_label is valid before trying to set its text
	if drop_label:
		drop_label.text = "กด F เพื่อเก็บเข้าช่องเก็บของ"
		drop_label.visible = false  # ซ่อนข้อความไว้ก่อน
	else:
		print("Error: drop_label is null. Make sure the Label node is present in the scene.")

func _physics_process(delta):
	deal_damage()
	if target and is_instance_valid(target):  # ตรวจสอบว่า target ยังมีอยู่
		var distance_to_player = position.distance_to(target.position)
		var direction = Vector2.ZERO
		
		# คำนวณทิศทางและการเคลื่อนที่ตามระยะห่าง
		if distance_to_player <= detection_range:
			direction = (target.position - position).normalized()
		else:
			direction = (original_position - position).normalized()
		
		velocity = direction * speed

		# ใช้ move_and_collide แทน move_and_slide เพื่อตรวจจับการชนกัน
		var collision = move_and_collide(velocity * delta)
		
		# ถ้ามีการชนกันกับวัตถุอื่น (ผู้เล่นหรือสิ่งกีดขวาง)
		if collision:
			# แยกตัวออกจากกัน (เลื่อนกลับไปข้างหลังเล็กน้อย)
			velocity = Vector2.ZERO
			
		# ตรวจสอบว่าตัวละครใกล้กับตำแหน่งต้นฉบับหรือไม่
		if position.distance_to(original_position) <= stop_threshold:
			velocity = Vector2.ZERO

		rotation = 0

func _on_detection_body_entered(body):
	if body.is_in_group("player"):  
		player = body
		player_chase = true

func _on_detection_body_exited(body):
	if body.is_in_group("player"):  
		player = null
		player_chase = false

# ตรวจจับการโจมตี
func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):  
		player_inattack_zone = true
		print("Enemy: Player entered attack zone!")

func _on_hitbox_body_exited(body):
	if body.is_in_group("player"):  
		player_inattack_zone = false
		print("Enemy: Player exited attack zone.")

# ลดเลือดเมื่อถูกโจมตี
func deal_damage():
	if player_inattack_zone and global.player_current_attack and can_take_damage == true:
		can_take_damage = false
		health -= 20  # ใช้ damage ที่ลดลง
		print("Enemy HP:", health)
		# ตั้งเวลาให้ศัตรูสามารถรับความเสียหายได้อีกครั้ง
		await get_tree().create_timer(0.5).timeout
		can_take_damage = true
		if health <= 0:
			print("Enemy: Destroyed!")
			drop_item()  # เรียกใช้ฟังก์ชันการดรอปของเมื่อศัตรูตาย
			queue_free()  # ลบศัตรูออกจากเกม

# ฟังก์ชันสำหรับการดรอปของเมื่อศัตรูตาย
# ฟังก์ชันสำหรับการดรอปของเมื่อศัตรูตาย
func drop_item():
	# ใช้ตำแหน่งของศัตรูตอนที่มันตายเป็นตำแหน่งดรอป
	var drop_position = position  # ใช้ตำแหน่งของศัตรู

	# สร้างไอเท็มที่ดรอป (ในที่นี้คือใช้ Sprite ที่แสดงตัวเลข)
	var drop_sprite = Sprite2D.new()
	drop_sprite.texture = load(drop)  # ใช้ไฟล์ภาพที่กำหนดไว้
	drop_sprite.position = drop_position  # ตั้งตำแหน่งของไอเท็ม
	
	# Ensure drop_sprite is valid before adding it to the scene
	if drop_sprite:
		get_parent().add_child(drop_sprite)  # เพิ่มไอเท็มใน scene
		print("Item dropped at: ", drop_position)
	else:
		print("Error: Failed to create drop_sprite.")

	# แสดงข้อความว่ากด F เพื่อเก็บ
	if drop_label:
		drop_label.position = drop_position + Vector2(0, -30)  # แสดงข้อความขึ้นเหนือไอเท็ม
		drop_label.visible = true  # ทำให้ข้อความแสดงขึ้นมา
	else:
		print("Error: drop_label is null. Ensure the Label node is assigned correctly.")

# ตรวจจับการกดปุ่ม F เพื่อเก็บของ
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):  # กด F
		collect_item()

# ฟังก์ชันเก็บไอเท็ม
func collect_item():
	print("Item collected!")  # แสดงข้อความเมื่อเก็บไอเท็ม
	drop_label.visible = false  # ซ่อนข้อความ

	# สร้างไอเท็มใหม่จากไอคอนหรือรูปภาพที่กำหนด
	var collected_item = {
		"item_icon": load(drop),  # ใช้ภาพที่ดรอปเป็น icon
		"item_type": "hat"  # หรือสามารถกำหนดประเภทไอเท็มตามที่ต้องการ
	}
	
	# เพิ่มไอเท็มลงใน inventory
	$Inventory.add_item(collected_item)
	
	queue_free()  # ลบไอเท็มจาก scene (หรือทำการเก็บมันใน inventory ของผู้เล่น)
