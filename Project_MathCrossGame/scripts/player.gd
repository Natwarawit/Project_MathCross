extends CharacterBody2D

const speed = 80
var health = 100
var attack = 30
var def = 0
var current_dir = "none"
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var player_alive = true
var attack_ip = false
var skill_cooldown_time = 5
var skill_cooldown_timer = 0
var can_use_skill = true


@export var inv: Inv   # ต้องลาก Inv node ใน Inspector มาตรงนี้
@onready var head = $CanvasLayer/HelmetBlack

# -------- อาวุธ --------
var using_bow: bool = false   # เริ่มยังไม่ถือธนู

func _ready():
	health = global.max_health
	$AnimatedSprite2D.play("front_idle")
	$Bow.visible = using_bow
	
	# แสดงหมวกถ้า global บอกว่าเคยซื้อ
	print("Helmet type from global: ", global.helmet_type)  # ตรวจสอบค่า
	if global.player_has_helmet:
		var helmet_type = global.helmet_type
		helmet_show(helmet_type)  # อัปเดตหมวก

func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	eatapple()
	update_health()
	handle_combat()
	skill()
	
	if health <= 0:
		player_alive = false 
		health = 0
		print("player has been killed")
		$AnimatedSprite2D.play("death")
		$Label.text = "YOU DEATH"

		for enemy in get_tree().get_nodes_in_group("enemies"):
			enemy.player_is_dead = true

		await get_tree().create_timer(3).timeout
		self.queue_free()
	
	if not can_use_skill:
		skill_cooldown_timer -= delta
		# ตัดทศนิยมและไม่ให้ติดลบ
		var cooldown = int(ceil(max(skill_cooldown_timer, 0)))
		
		# แสดงข้อความเฉพาะตอนที่ cooldown > 0
		if cooldown > 0:
			$Label.text = "Skill Cooldown " + str(cooldown)
		else:
			$Label.text = ""  # เคลียร์ข้อความ

		if skill_cooldown_timer <= 0:
			can_use_skill = true



# -------- การเคลื่อนไหว --------
func player_movement(delta):
	if Input.is_action_pressed("d"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("a"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("s"):
		current_dir = "down"
		play_anim(1)
		velocity.y = speed
		velocity.x = 0
	elif Input.is_action_pressed("w"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -speed
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0 and not attack_ip:
			anim.play("side_idle")

	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0 and not attack_ip:
			anim.play("side_idle")

	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0 and not attack_ip:
			anim.play("front_idle")

	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0 and not attack_ip:
			anim.play("back_idle")

# -------- ต่อสู้ --------
func handle_combat():
	# สลับอาวุธ
	if Input.is_action_just_pressed("switch_weapon"): # R
		using_bow = !using_bow
		$Bow.visible = using_bow
		print("Now using bow:", using_bow)

	# โจมตีด้วยดาบ
	if not using_bow and Input.is_action_just_pressed("attack"):
		sword_attack()

	# ยิงธนู
	if using_bow and Input.is_action_just_pressed("shoot"):
		$Bow.shoot_arrow()

func sword_attack():
	var dir = current_dir
	$soundattack.play()
	global.player_current_attack = true
	attack_ip = true

	match dir:
		"right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
		"left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
		"down":
			$AnimatedSprite2D.play("front_attack")
		"up":
			$AnimatedSprite2D.play("back_attack")

	$deal_attack_timer.start()

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false

# -------- ศัตรูโจมตี --------
func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_inattack_range = false


func flash_red():
	var sprite = $AnimatedSprite2D
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1)


func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown:
		var damage = 0
		if global.enemy_attacker != null:
			var enemy_attack = global.enemy_attacker.attack
			damage = enemy_attack - def

		flash_red()
		health -= damage
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print("Player ถูกตี! damage =", damage, " HP เหลือ =", health)
		$hurt.play()

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

# -------- สกิล --------
func skill():
	if Input.is_action_just_pressed("E"):
		if can_use_skill:
			global.player_current_attack = true
			attack_ip = true

			match current_dir:
				"right", "left":
					$AnimatedSprite2D.play("skill_attack")
				"down":
					$AnimatedSprite2D.play("front_skill_attack")
				"up":
					$AnimatedSprite2D.play("back_skill_attack")

			$deal_attack_timer.start()
			can_use_skill = false
			skill_cooldown_timer = skill_cooldown_time
			$soundattack.play()
			await get_tree().create_timer(0.2).timeout
			$soundattack.play()
		else:
			$Label.text = "Skill Cooldown"

# -------- Health Bar --------
func update_health(): 
	# ตรวจสอบให้ค่าพลังชีวิตไม่เกิน max_health
	var clamped_health = min(health, global.max_health)

	# อัปเดตค่าแถบเลือดและแสดงผล
	var healthbar = $healthbarcanvas/healthbar
	$healthbarcanvas/Label2.text = str(clamped_health) + "/" + str(global.max_health)
	healthbar.value = clamped_health
	healthbar.max_value = global.max_health  # ใช้ค่า clamped_health ในการอัปเดตแถบเลือด
	healthbar.visible = true
	
# -------- Item / Apple --------
func collect(item):
	if item == null:
		return
	print("Collecting item:", item.name)

	if $Inv_UI == null:
		print("ERROR: Inv_UI not found")
		return

	# แยกประเภท item
	if item.name.begins_with("ปุ่มหมายเลข "):
		$Inv_UI.inv_main.insert(item)
		print("เก็บเข้า inv_main (ตัวเลข)")
	else:
		$Inv_UI.inv_misc.insert(item)
		print("เก็บเข้า inv_misc (coin/apple/fixcoin)")


func eatapple():
	if Input.is_action_just_pressed("Q"): 
		eat()

func eat():
	var inv_ui = $Inv_UI  # 👈 ตรวจว่าชื่อ node ตรงกับใน scene จริง (เช่น Inventory หรือ Inv_UI)

	if inv_ui == null:
		print("❌ ไม่พบ Inv_UI")
		return

	# === ตรวจจำนวน apple_ ใน inv_misc ===
	var apple_count := 0
	for invslot in inv_ui.inv_misc.slots:
		if invslot != null and invslot.item != null and invslot.item.name == "apple_":
			apple_count = invslot.amount
			break

	if apple_count > 0:
		# ลดจำนวนแอปเปิ้ลลง 1
		inv_ui.set_item_count_misc("apple_", apple_count - 1)

		# ฟื้นพลังชีวิต (สูงสุด 100)
		health = min(global.max_health, health + 20)
		print("🍎 คุณกินแอปเปิ้ลแล้ว! พลังชีวิตเพิ่มขึ้นเป็น:", health)

		# ถ้าใช้หมดแล้ว ลบ item ออกจาก inventory
		if apple_count - 1 <= 0:
			inv_ui.remove_item_from_inventory_misc("apple_")
	else:
		print("❌ ไม่มีแอปเปิ้ลใน inventory")

func helmet_show(helmet_type: String): 
	if head != null:
		head.visible = true
		
		# ตรวจสอบประเภทของหมวกและอัปเดตค่าพลังชีวิตสูงสุด
		match helmet_type:
			"หมวกทองแดง":
				global.max_health = 150  # เปลี่ยนค่าพลังชีวิตสูงสุดเป็น 150
				global.helmet_type = "หมวกทองแดง"
				$CanvasLayer/HelmetBlack.texture = preload("res://image/armor/helmet/copper_helmet.png")
			"หมวกเหล็ก":
				global.max_health = 200  # เปลี่ยนค่าพลังชีวิตสูงสุดเป็น 200
				global.helmet_type = "หมวกเหล็ก"
				$CanvasLayer/HelmetBlack.texture = preload("res://image/armor/helmet/iron_helmet.png")
			"หมวกทอง":
				global.max_health = 250  # เปลี่ยนค่าพลังชีวิตสูงสุดเป็น 250
				global.helmet_type = "หมวกทอง"
				$CanvasLayer/HelmetBlack.texture = preload("res://image/armor/helmet/gold_helmet.png")
			"หมวกเพชร":
				global.max_health = 300 
				global.helmet_type = "หมวกเพชร"
				$CanvasLayer/HelmetBlack.texture = preload("res://image/armor/helmet/diamond_helmet.png")
			_:
				print("ประเภทหมวกไม่ถูกต้อง")

		# รีเซ็ต health ให้ไม่เกิน max_health ใหม่
		health = min(health, global.max_health)  
		
		# อัปเดตการแสดงผลพลังชีวิต
		update_health()
		
		print("หมวก " + helmet_type + " ถูกสวมใส่! พลังชีวิตสูงสุดเพิ่มขึ้นเป็น ", global.max_health)
	else:
		print("❌ HelmetBlack node ไม่พบ")
func player():
	pass
