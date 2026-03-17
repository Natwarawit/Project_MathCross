extends CharacterBody2D 

signal died
signal apple_eaten
signal shoote

# ============================
# ⭐ BASE STATS
# ============================

const BASE_HP := 100
const BASE_ATK := 100
const BASE_DEF := 0
const BASE_SPEED := 80

# ============================
# ⭐ LEVEL BONUS
# ============================

var level_hp_bonus := 0
var level_atk_bonus := 0
var level_def_bonus := 0
var level_speed_bonus := 0

# ============================
# ⭐ EQUIPMENT BONUS
# ============================

var helmet_hp := 0
var sword_atk := 0
var chestplate_def := 0
var boots_speed := 0

# ============================
# ⭐ FINAL STATS
# ============================

var max_health := 100
var attack := 30
var def := 0
var speed := 80

var health := 100
# ============================
# ⭐ LEVEL SYSTEM
# ============================
const MAX_LEVEL := 30
@export var attack_range := 80.0
var level := 1
var exp := 0
var exp_to_next := 50   # EXP ที่ต้องใช้เลเวลแรก

# โบนัสที่ได้จากเลเวล
var current_dir = "none"
var enemy_inattack_range = false
var enemy_attacker = null
var enemy_attack_cooldown = true
var player_alive = true
var sword_attack_ip = false
var skill_attack_ip = false
var skill_cooldown_time = 5
var skill_cooldown_timer = 0
var can_use_skill = true

# -------- Skill Damage Boost --------
var skill_damage_multiplier := 2.0
var skill_active := false
# -------- Bow Cooldown --------
var can_shoot := true
@export var shoot_cooldown := 1   # เวลาคั่นระหว่างลูกธนู (ปรับได้)
@export var inv: Inv   # ต้องลาก Inv node ใน Inspector มาตรงนี้
@onready var head = $CanvasLayer/Helmet
@onready var chestplate = $CanvasLayer/Chestplate
@onready var boots = $CanvasLayer/Boots
@onready var sword =$CanvasLayer/Sword
@onready var damaged_player = $damaged_player
var can_attack := true
@export var attack_cooldown := 0.35
# -------- อาวุธ --------
var using_bow: bool = false   # เริ่มยังไม่ถือธนู
# -------- EXP Bar --------
@onready var exp_bar = $expbarcanvas/expbarprogress
@onready var exp_label = $expbarcanvas/expbarlabel
#-------------dash--------------
@export var dash_ghost_node : PackedScene
@onready var dash_ghost_timer = $DashGhostTimer
const DASH_DISTANCE := 50   # ระยะ dash (ยิ่งมากยิ่งไกล)
const DASH_TIME := 0.25       # เวลาที่ใช้ dash (ยิ่งน้อยยิ่งไว)
# BLUR
@onready var helmetblur = $CanvasLayer/Helmetblur
@onready var chestplateblur = $CanvasLayer/Armorblur
@onready var bootsblur = $CanvasLayer/Bootsblur
@onready var swordblur = $CanvasLayer/Swordblur

func _ready():
	# โหลดค่าที่เคยเล่นไว้
	load_player_progress()
	load_equipment_from_global() 
	update_all_stats()
	health = max_health
	update_exp_bar()  
	load_coin_from_global()
	update_coin_ui()
	add_to_group("player")
	$AnimatedSprite2D.play("front_idle")
	$Bow.visible = using_bow
	
	
	if not dash_ghost_timer.timeout.is_connected(_on_dash_ghost_timer_timeout):
		dash_ghost_timer.timeout.connect(_on_dash_ghost_timer_timeout)
	
	# แสดงหมวกถ้า global บอกว่าเคยซื้อ
	print("Helmet type from global: ", global.helmet_type)  # ตรวจสอบค่า
	if global.player_has_helmet:
		var helmet_type = global.helmet_type
		helmet_show(helmet_type)  # อัปเดตหมวก

func _physics_process(delta):
	player_movement(delta)
	#enemy_attack()   # 🔥 เปิดการโจมตีศัตรู
	eatapple()
	update_health()
	handle_combat()
	skill()
	
	if health <= 0:
		player_died()
		
	
	if not can_use_skill:
		skill_cooldown_timer -= delta
		# ตัดทศนิยมและไม่ให้ติดลบ
		var cooldown = int(ceil(max(skill_cooldown_timer, 0)))
		
		# แสดงข้อความเฉพาะตอนที่ cooldown > 0
		if cooldown > 0:
			#$Label.text = "Skill Cooldown " + str(cooldown)
			pass

		if skill_cooldown_timer <= 0:
			can_use_skill = true

# -------- การเคลื่อนไหว --------
func player_movement(delta):
	if sword_attack_ip or skill_attack_ip:
		velocity = Vector2.ZERO
		move_and_slide()
		return

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
		velocity = Vector2.ZERO

	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0 and not sword_attack_ip and not skill_attack_ip:
			anim.play("side_idle")

	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0 and not sword_attack_ip and not skill_attack_ip:
			anim.play("side_idle")

	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0 and not sword_attack_ip and not skill_attack_ip:
			anim.play("front_idle")

	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0 and not sword_attack_ip and not skill_attack_ip:
			anim.play("back_idle")

# -------- ต่อสู้ --------
func handle_combat():
	# สลับอาวุธ
	if Input.is_action_just_pressed("switch_weapon"):
		using_bow = !using_bow
		$Bow.visible = using_bow
		print("Now using bow:", using_bow)

		# โจมตีด้วยดาบ (เฉพาะตอนมีศัตรูในระยะ)
	if not using_bow and Input.is_action_just_pressed("attack"):
		if enemy_in_range():
			sword_attack()

	# =========================
	# 🔥 ระบบง้างธนู
	# =========================
	if using_bow:
		# เริ่มง้าง
		if Input.is_action_just_pressed("shoot") and can_shoot:
			can_shoot = false
			$Bow.start_charge()

		# ปล่อยยิง
		if Input.is_action_just_released("shoot"):
			$Bow.release_charge()
			emit_signal("shoote")

			# เริ่มคูลดาวน์หลังปล่อย ไม่ใช่ตอนกด
			start_bow_cooldown()
			
func play_sword_sound():
	$soundattack.pitch_scale = randf_range(0.9, 1.1)
	$soundattack.stop()
	$soundattack.play()
		
func _on_animated_sprite_2d_frame_changed():

	if $AnimatedSprite2D.animation.contains("attack"):
		if $AnimatedSprite2D.frame == 1:
			play_sword_sound()

func sword_attack():

	if not enemy_in_range():
		return

	if not can_attack:
		return

	can_attack = false

	var dir = current_dir

	global.player_current_attack = true
	sword_attack_ip = true

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

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func start_bow_cooldown() -> void:
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

	can_shoot = true
	
func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()

	global.player_current_attack = false

	sword_attack_ip = false
	skill_attack_ip = false

# -------- ศัตรูโจมตี --------
func _on_player_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		enemy_inattack_range = true
		enemy_attacker = body

func _on_player_hitbox_body_exited(body):
	if body.is_in_group("enemies"):
		enemy_inattack_range = false
		enemy_attacker = null


func flash_red():
	var sprite = $AnimatedSprite2D
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1)
	
func take_damage(damage):

	if not player_alive:
		return

	health -= damage

	show_damage_player(damage)
	flash_red()
	$hurt.play()

	print("Player HP =", health)

func enemy_attack():

	for enemy in get_tree().get_nodes_in_group("enemies"):

		if enemy == null:
			continue

		if enemy.is_dead:
			continue

		if not enemy.player_inattack_zone:
			continue

		if not enemy_attack_cooldown:
			return

		var damage = enemy.attack - def
		damage = max(damage, 1)

		health -= damage

		show_damage_player(damage)
		flash_red()
		$hurt.play()

		enemy_attack_cooldown = false
		$attack_cooldown.start()

		print("Player ถูกตี! damage =", damage, " HP เหลือ =", health)

		break
		
func show_damage_player(amount:int):

	damaged_player.text = str(amount)
	damaged_player.visible = true

	damaged_player.modulate = Color(1,0.2,0.2)

	var start_pos = damaged_player.position

	var tween = create_tween()

	tween.tween_property(
		damaged_player,
		"position",
		start_pos + Vector2(randf_range(-10,10), -40),
		0.5
	)

	tween.parallel().tween_property(
		damaged_player,
		"modulate:a",
		0,
		0.5
	)

	await tween.finished

	damaged_player.visible = false
	damaged_player.modulate.a = 1
	damaged_player.position = start_pos
# ============================
# ☠️ PLAYER DIED
# ============================
func player_died():
	if not player_alive:
		return  # กันเรียกซ้ำ

	player_alive = false
	health = 0

	print("player has been killed")
	emit_signal("died") 

	# 🔴 เล่นอนิเมชั่นตาย
	$AnimatedSprite2D.play("death")
	#$Label.text = "YOU DEATH"

	# 🛑 บอกศัตรูทุกตัวให้หยุดทำงาน
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.player_is_dead = true

	# ❌ หยุดการเคลื่อนไหวทั้งหมด
	velocity = Vector2.ZERO
	set_physics_process(false)

	# 🧹 ล้าง inventory ตอนตายเท่านั้น
	reset_inventory()

	# 🎮 แสดง Game Over
	$gameover.visible = true
	hide()
	set_process_input(false)

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

# -------- สกิล --------
func skill():
	if Input.is_action_just_pressed("E"):
		if not can_use_skill:
			return

		# ⭐ รีเซ็ตสถานะโจมตีเก่า
		global.player_current_attack = false

		can_use_skill = false
		skill_cooldown_timer = skill_cooldown_time

		# ✅ เปิดโหมดสกิล (ดาเมจ x2)
		skill_active = true
		update_attack()

		global.player_current_attack = true
		skill_attack_ip = true

		# เล่นอนิเมชั่น
		match current_dir:
			"right", "left":
				$AnimatedSprite2D.play("skill_attack")
			"down":
				$AnimatedSprite2D.play("front_skill_attack")
			"up":
				$AnimatedSprite2D.play("back_skill_attack")

		# =========================
		# 🔥 HIT ครั้งที่ 1
		# =========================
		$deal_attack_timer.start()
		$soundattack.play()

		await get_tree().create_timer(0.15).timeout

		# =========================
		# 🔥 HIT ครั้งที่ 2
		# =========================
		$deal_attack_timer.start()
		$soundattack.play()

		await get_tree().create_timer(0.2).timeout

		# ปิดสถานะโจมตี
		global.player_current_attack = false
		skill_attack_ip = false

		# ❌ ปิดบัฟสกิล
		skill_active = false
		update_attack()

func get_coin_count() -> int:
	var inv_ui = $Inv_UI
	if inv_ui == null:
		return 0

	for slot in inv_ui.inv_misc.slots:
		if slot != null and slot.item != null and slot.item.name == "coin":
			return slot.amount
	return 0

func get_item_count(item_name: String) -> int:
	var inv_ui = $Inv_UI
	if inv_ui == null:
		return 0

	for slot in inv_ui.inv_misc.slots:
		if slot != null and slot.item != null and slot.item.name == item_name:
			return slot.amount

	return 0

func update_coin_ui():
	# --- coin ---
	if has_node("status/coin"):
		$status/coin.text = str(get_item_count("coin"))

	# --- fixcoin ---
	if has_node("status/coin3"):
		$status/coin3.text = str(get_item_count("coin_fix"))

	# --- apple ---
	if has_node("status/coin4"):
		$status/coin4.text = str(get_item_count("apple_"))

# -------- Health Bar --------
func update_health(): 
	# ตรวจสอบให้ค่าพลังชีวิตไม่เกิน max_health
	var clamped_health = min(health, max_health)

	# อัปเดตค่าแถบเลือดและแสดงผล
	var healthbar = $healthbarcanvas/healthbar

	$healthbarcanvas/Label2.text = str(clamped_health) + "/" + str(max_health)
	healthbar.max_value = max_health
	healthbar.value = clamped_health
	healthbar.visible = true
	
# -------- Item / Apple --------
func collect(item):
	if item == null:
		return
	print("Collecting item:", item.name)

	if $Inv_UI == null:
		print("ERROR: Inv_UI not found")
		return

	# แยกประเภท itemก
	if item.name.begins_with("ปุ่มหมายเลข "):
		$Inv_UI.inv_main.insert(item)
		print("เก็บเข้า inv_main (ตัวเลข)")
	else:
		$Inv_UI.inv_misc.insert(item)
		print("เก็บเข้า inv_misc (coin/apple/fixcoin)")
		
	update_coin_ui() # 🪙 อัปเดต coin ทุกครั้งที่เก็บของ

func consume_coin(amount: int) -> bool:
	var inv_ui = $Inv_UI
	if inv_ui == null:
		return false

	for slot in inv_ui.inv_misc.slots:
		if slot != null and slot.item != null and slot.item.name == "coin":
			if slot.amount >= amount:
				inv_ui.set_item_count_misc("coin", slot.amount - amount)

				if slot.amount - amount <= 0:
					inv_ui.remove_item_from_inventory_misc("coin")

				update_coin_ui()
				return true
	return false
	
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
		inv_ui.set_item_count_misc("apple_", apple_count - 1)

		health = min(max_health, health + 20)
		print("🍎 คุณกินแอปเปิ้ลแล้ว! พลังชีวิตเพิ่มขึ้นเป็น:", health)
		emit_signal("apple_eaten")
	
		update_coin_ui()   # ✅ เพิ่มบรรทัดนี้

		if apple_count - 1 <= 0:
			inv_ui.remove_item_from_inventory_misc("apple_")
			$heal_effect.visible = true
			$heal_effect.play('default')
			await $heal_effect.animation_finished
			$heal_effect.visible = false
	else:
		print("❌ ไม่มีแอปเปิ้ลใน inventory")

func helmet_show(helmet_type: String):

	head.visible = true
	helmetblur.visible = false
	match helmet_type:

		"หมวกทองแดง":
			helmet_hp = 50
			head.texture = preload("res://image/armor/helmet/copper_helmet.png")

		"หมวกเหล็ก":
			helmet_hp = 100
			head.texture = preload("res://image/armor/helmet/iron_helmet.png")

		"หมวกทอง":
			helmet_hp = 150
			head.texture = preload("res://image/armor/helmet/gold_helmet.png")

		"หมวกเพชร":
			helmet_hp = 200
			head.texture = preload("res://image/armor/helmet/diamond_helmet.png")

	update_all_stats()

func chestplate_show(chestplate_type: String):

	chestplate.visible = true
	chestplateblur.visible = false
	match chestplate_type:

		"เกราะทองแดง":
			chestplate_def = 10
			chestplate.texture = preload("res://image/armor/chestplate/copper_chestplate.png")

		"เกราะเหล็ก":
			chestplate_def = 20
			chestplate.texture = preload("res://image/armor/chestplate/iron_chestplate.png")

		"เกราะทอง":
			chestplate_def = 25
			chestplate.texture = preload("res://image/armor/chestplate/gold_chestplate.png")

		"เกราะเพชร":
			chestplate_def = 35
			chestplate.texture = preload("res://image/armor/chestplate/diamond_chestplate.png")
			
	update_all_stats()


func boots_show(boots_type: String):

	boots.visible = true
	bootsblur.visible = false
	match boots_type:

		"รองเท้าทองแดง":
			boots_speed = 30
			boots.texture = preload("res://image/armor/boots/copper_boots.png")

		"รองเท้าเหล็ก":
			boots_speed = 40
			boots.texture = preload("res://image/armor/boots/iron_boots.png")

		"รองเท้าทอง":
			boots_speed = 50
			boots.texture = preload("res://image/armor/boots/gold_boots.png")

		"รองเท้าเพชร":
			boots_speed = 70
			boots.texture = preload("res://image/armor/boots/diamond_boots.png")

	update_all_stats()

func sword_show(sword_type: String):

	sword.visible = true
	swordblur.visible = false

	match sword_type:

		"ดาบระดับ 1":
			sword_atk = 20
			sword.texture = preload("res://image/sword/sword_level1.png")

		"ดาบระดับ 2":
			sword_atk = 35
			sword.texture = preload("res://image/sword/sword_level2.png")

		"ดาบระดับ 3":
			sword_atk = 50
			sword.texture = preload("res://image/sword/sword_level3.png")

	update_all_stats()

func update_stats():
	update_all_stats()
	
func update_all_stats():
	max_health = BASE_HP + level_hp_bonus + helmet_hp
	attack = BASE_ATK + level_atk_bonus + sword_atk
	def = BASE_DEF + level_def_bonus + chestplate_def
	speed = BASE_SPEED + level_speed_bonus + boots_speed
	global.max_health = max_health
	update_health()
	update_status_ui()

func update_attack():
	attack = BASE_ATK + level_atk_bonus + sword_atk

	if skill_active:
		attack *= skill_damage_multiplier
	
func update_defense():
	def = BASE_DEF + level_def_bonus + chestplate_def

func update_speed():
	speed = BASE_SPEED + level_speed_bonus + boots_speed

func update_status_ui():
	if has_node("status/attack2"):
		$status/attack2.text = ": " + str(attack)
	if has_node("status/def2"):
		$status/def2.text = ": " + str(def)
	if has_node("status/speed2"):
		$status/speed2.text = ": " + str(speed)
	if has_node("status/Label"):
		$status/Label.text = "Lv." + str(level)

#-----------------dash--------------------
var can_dash := true

func add_ghost():
	var ghost = dash_ghost_node.instantiate()
	get_parent().add_child(ghost)

	ghost.copy_from_player($AnimatedSprite2D)



func _on_dash_ghost_timer_timeout() -> void:
	add_ghost()

func dash():
	if not can_dash:
		return
	if velocity == Vector2.ZERO:
		return

	can_dash = false
	$Dash_Cooldown.start()

	dash_ghost_timer.start()

	var dash_dir := velocity.normalized()
	var tween := get_tree().create_tween()
	tween.tween_property(
		self,
		"position",
		position + dash_dir * DASH_DISTANCE,
		DASH_TIME
	)

	await tween.finished
	dash_ghost_timer.stop()

	
func _input(event):
	if event.is_action_pressed("dash"):
		dash()


func _on_dash_cooldown_timeout() -> void:
	can_dash = true

# ============================
# 🔥 RESET INVENTORY ทั้งหมด
# ============================
func reset_inventory():
	var inv_ui = $Inv_UI

	# รีเซ็ต inv_main
	for slot in inv_ui.inv_main.slots:
		if slot == null:
			continue
		slot.item = null
		slot.amount = 0

	# รีเซ็ต inv_misc
	for slot in inv_ui.inv_misc.slots:
		if slot == null:
			continue
		slot.item = null
		slot.amount = 0

	inv_ui.inv_main.update.emit()
	inv_ui.inv_misc.update.emit()
	inv_ui.update_slots()

	update_coin_ui()

	print("✅ Inventory reset (ไม่ทำลาย slot)")

func reset_inventory_keep_coin():
	var inv_ui = $Inv_UI

	for slot in inv_ui.inv_main.slots:
		if slot == null:
			continue
		slot.item = null
		slot.amount = 0

	for slot in inv_ui.inv_misc.slots:
		if slot == null:
			continue

		# ❗ เก็บ coin ไว้
		if slot.item != null and slot.item.name == "coin":
			continue

		slot.item = null
		slot.amount = 0

	inv_ui.inv_main.update.emit()
	inv_ui.inv_misc.update.emit()
	inv_ui.update_slots()

	print("🧹 Clear inventory (keep coin)")

func save_coin_to_global():
	var inv_ui = $Inv_UI
	if inv_ui == null:
		return

	var current_stage_coin := 0

	for slot in inv_ui.inv_misc.slots:
		if slot != null and slot.item != null and slot.item.name == "coin":
			current_stage_coin = slot.amount
			break

	# ✅ เอาเงินด่านนี้ไปรวมกับเงินถาวร
	global.saved_coin += current_stage_coin

	print("💰 Add to saved_coin =", global.saved_coin)

func load_coin_from_global():
	var inv_ui = $Inv_UI
	if inv_ui == null:
		return

	if global.saved_coin <= 0:
		return

	inv_ui.add_misc_item("coin", "res://inventory/coin.png")
	inv_ui.set_item_count_misc("coin", global.saved_coin)

	print("💰 Load saved_coin =", global.saved_coin)

	update_coin_ui()

func change_scene_clean(path: String):

	save_player_progress()   # ⭐ เพิ่มบรรทัดนี้
	save_coin_to_global()

	reset_inventory_keep_coin()
	get_tree().change_scene_to_file(path)

# ============================
# ⭐ EXP SYSTEM
# ============================
func gain_exp(amount: int):

	if level >= MAX_LEVEL:
		return

	exp += amount
	check_level_up()

	update_status_ui()
	update_exp_bar()   # ⭐ เพิ่ม

func check_level_up():

	while exp >= exp_to_next and level < MAX_LEVEL:

		exp -= exp_to_next
		level += 1

		apply_level_up_bonus()
		scale_next_level_exp()

		update_exp_bar()   # ⭐ เพิ่ม

		print("🎉 LEVEL UP →", level)

	if level >= MAX_LEVEL:
		exp = 0

func apply_level_up_bonus():

	level_atk_bonus += 2
	level_def_bonus += 1
	level_speed_bonus += 1
	level_hp_bonus += 5

	update_all_stats()

	save_player_progress()

func scale_next_level_exp():
	exp_to_next = int(50 + pow(level, 2) * 20)

func load_player_progress():

	# ถ้าเข้าฉากครั้งแรกของเกม → ใช้ค่า default
	if not global.player_initialized:
		save_player_progress()
		global.player_initialized = true
		return

	# โหลดค่าที่เคยมี
	level = global.player_level
	exp = global.player_exp
	exp_to_next = global.player_exp_to_next

	level_atk_bonus = global.player_level_attack_bonus
	level_def_bonus = global.player_level_def_bonus
	level_speed_bonus = global.player_level_speed_bonus
	level_hp_bonus = global.player_level_hp_bonus

func save_player_progress():

	global.player_level = level
	global.player_exp = exp
	global.player_exp_to_next = exp_to_next

	global.player_level_attack_bonus = level_atk_bonus
	global.player_level_def_bonus = level_def_bonus
	global.player_level_speed_bonus = level_speed_bonus
	global.player_level_hp_bonus = level_hp_bonus

func enemy_in_range() -> bool:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == null:
			continue

		if enemy.is_dead:
			continue

		if global_position.distance_to(enemy.global_position) <= attack_range:
			return true

	return false

func update_exp_bar():

	if exp_bar == null:
		return

	exp_bar.max_value = exp_to_next
	exp_bar.value = exp

	if exp_label != null:
		exp_label.text = str(exp) + " / " + str(exp_to_next)

func load_equipment_from_global():

	if global.helmet_index > 0:
		var helmet_list = ["หมวกทองแดง","หมวกเหล็ก","หมวกทอง","หมวกเพชร"]
		helmet_show(helmet_list[global.helmet_index - 1])

	if global.chestplate_index > 0:
		var chest_list = ["เกราะทองแดง","เกราะเหล็ก","เกราะทอง","เกราะเพชร"]
		chestplate_show(chest_list[global.chestplate_index - 1])

	if global.boots_index > 0:
		var boots_list = ["รองเท้าทองแดง","รองเท้าเหล็ก","รองเท้าทอง","รองเท้าเพชร"]
		boots_show(boots_list[global.boots_index - 1])

	if global.sword_index > 0:
		var sword_list = ["ดาบระดับ 1","ดาบระดับ 2","ดาบระดับ 3"]
		sword_show(sword_list[global.sword_index - 1])
