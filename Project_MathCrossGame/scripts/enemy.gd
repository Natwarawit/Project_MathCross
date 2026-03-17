extends CharacterBody2D

<<<<<<< HEAD
# ============================================================
# Node References
# ============================================================
@onready var coin      = $coin_collectable
@onready var coin_fix  = $coin_fix_answer_collectable
@onready var damaged   = $damaged
@onready var level_label = $levellabel

# ============================================================
# Exported Data
# ============================================================
@export var itemRes: InvItem
@export var coin_item: InvItem     = preload("res://inventory/items/coin.tres")
@export var coin_fix_item: InvItem = preload("res://inventory/items/coin_fix.tres")
@export var location_respawn = 0
@export var coin_magnet_range: float = 80.0
@export var x1 = -20
@export var x2 = 300
@export var y1 = -20
@export var y2 = 200
@export var rank = 50
# ============================================================
# Enemy Base Stats
# ============================================================
var health  = 100
var attack  = 20
var defense = 5
var speed   = 30

# ============================================================
# Level System
# ============================================================
var level := 1
@export var min_level := 1
@export var max_level := 3
var base_health  := 100
var base_attack  := 10
var base_defense := 5
var base_speed   := 30


# ============================================================
# Enemy State Flags
# ============================================================
var target = Vector2.ZERO 
var player_chase         = false
var player               = null
var is_dead              = false
var player_inattack_zone = false
var can_take_damage      = true
var player_is_dead       = false
var is_stunned = false
var was_chasing_before_stun = false
var is_registered_attacker = false
var attack_cooldown := 1.2
var can_attack := true
# ============================================================
# Coin System State
# ============================================================
var coin_ready  = false
var coin_flying = false
var coin_start_pos: Vector2
var coin_fix_start_pos: Vector2


# ============================================================
# Ready
# ============================================================
func _ready():
	randomize()
	add_to_group("enemies")
	coin_start_pos     = coin.position
	coin_fix_start_pos = coin_fix.position
	roll_level()

# ============================================================
# 🔹 Main Physics Loop
# ============================================================
func _physics_process(delta):

	check_coin_magnet()

=======
@onready var coin = $coin_collectable
@onready var coin_fix = $coin_fix_answer_collectable
@export var itemRes: InvItem
@export var coin_item: InvItem = preload("res://inventory/items/coin.tres")
@export var coin_fix_item: InvItem = preload("res://inventory/items/coin_fix.tres")

var health = 100
var attack = 10
var defense = 5
var speed = 30
var player_chase = false
var player = null
var is_dead = false
var player_inattack_zone = false
var can_take_damage = true
var player_is_dead = false

func _ready():
	add_to_group("enemies")

func _physics_process(delta):
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
	if player_is_dead:
		$AnimatedSprite2D.play("idle")
		return

<<<<<<< HEAD
	if is_stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	deal_with_damage()

	if player_inattack_zone:
		attack_player()

=======
	deal_with_damage()
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
	update_health()

	if is_dead:
		return
<<<<<<< HEAD
		
	var dt = position.distance_to(target)
	if dt < 5:
		target.x = randi_range(x1,x2)
		target.y = randi_range(y1,y2)
	
	if player != null:
		var d = position.distance_to(player.position)
		if d < rank:
			target = player.position
		
	if target != Vector2.ZERO:
		
		var direction = (target - position).normalized()

		velocity = direction * speed
		move_and_slide()

		for i in range(get_slide_collision_count()):
			var col = get_slide_collision(i)
			if col.get_collider().is_in_group("player"):
				velocity = -direction * speed
				move_and_slide()
				break

		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = direction.x < 0

	else:

		velocity = Vector2.ZERO
		move_and_slide()
		$AnimatedSprite2D.play("idle")


# ============================================================
# 🔹 Detection
# ============================================================
func _on_detection_area_body_entered(body):

	if not body.is_in_group("player"):
		return
	target = body.position
	player = body
	player_chase = true


func _on_detection_area_body_exited(body):

	if body == player:
		player = null
		player_chase = false
		


# ============================================================
# 🔹 Attack Zone
# ============================================================
func _on_enemy_hitbox_body_entered(body):

	if not body.is_in_group("player"):
		return

	if is_stunned or is_dead:
		return

	player_inattack_zone = true
	is_registered_attacker = true

func _on_enemy_hitbox_body_exited(body):

	if body.is_in_group("player"):

		player_inattack_zone = false
		is_registered_attacker = false


# ============================================================
# 🔹 Damage System
# ============================================================
func deal_with_damage():

	if is_stunned or is_dead:
		return

	if player == null:
		return

	if not player_inattack_zone:
		return

	if not global.player_current_attack:
		return

	if not can_take_damage:
		return

	var player_attack = player.attack
	var damage = player_attack - defense
	damage = max(damage,1)

	take_damage(damage)

func attack_player():

	if not can_attack:
		return

	if player == null:
		return

	if is_dead or is_stunned:
		return

	can_attack = false

	var damage = attack - player.def
	damage = max(damage, 1)

	player.take_damage(damage)

	await get_tree().create_timer(attack_cooldown).timeout

	can_attack = true

func take_damage(amount: int) -> void:

	if not can_take_damage:
		return

	show_damage(amount)

	health -= amount

	$take_damage_cooldown.start()
	can_take_damage = false

	flash_red()
	apply_hit_stun(1.0)

	print("slime health = ", health)

	if health <= 0:
		death()


# ============================================================
# 🔹 Death / Respawn
# ============================================================
func death():

	is_dead = true
	player_chase = false
	velocity = Vector2.ZERO

	$AnimatedSprite2D.visible = false
	$enemy_hitbox/CollisionShape2D.disabled = true
	$detection_area/CollisionShape2D.disabled = true
	$healthbar.visible = false
	level_label.visible = false

	disable_enemy()
	drop_coin()

	give_exp_to_player()

	respawn_after_delay(3.0)


func respawn_after_delay(delay_time: float):

	await get_tree().create_timer(delay_time).timeout
	respawn()


# ============================================================
# 🔹 Respawn Logic
# ============================================================
func respawn():

	player = get_tree().get_first_node_in_group("player")

=======

	if player_chase and player != null:
		var direction = (player.position - position).normalized()
		position += direction * speed * delta
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = direction.x < 0
	else:
		$AnimatedSprite2D.play("idle")

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false

func enemy():
	pass

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_inattack_zone= true
		global.enemy_attacker = self

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_inattack_zone= false

func deal_with_damage():
	if player_inattack_zone and global.player_current_attack:
		if can_take_damage and player != null:
			var player_attack = player.attack
			var damage = player_attack - defense
			take_damage(damage)

# ใช้ได้ทั้งดาบและธนู
func take_damage(amount: int) -> void:
	if can_take_damage:
		health -= amount
		$take_damage_cooldown.start()
		can_take_damage = false
		flash_red()
		print("slime health = ", health)
		if health <= 0:
			death()

func death():
	is_dead = true
	player_chase = false
	$AnimatedSprite2D.visible = false
	$enemy_hitbox/CollisionShape2D.disabled = true
	$detection_area/CollisionShape2D.disabled = true
	drop_coin()
	
	respawn_after_delay(3.0)

func respawn_after_delay(delay_time: float):
	await get_tree().create_timer(delay_time).timeout
	respawn()

func respawn():
	# === หาผู้เล่นอีกครั้ง ===
	player = get_tree().get_first_node_in_group("player")
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
	if player == null:
		print("Respawn failed: player not found.")
		return

<<<<<<< HEAD
	set_physics_process(false)
	velocity = Vector2.ZERO

	disable_enemy()

	await get_tree().physics_frame

	var spawn_positions: Array = []

	if location_respawn == 1:

		spawn_positions = [
			Vector2(-27,24), Vector2(99,82), Vector2(243,125),
			Vector2(338,16), Vector2(188,-34)
		]

	elif location_respawn == 2:

		spawn_positions = [
			Vector2(345,235), Vector2(184,192), Vector2(558,113),
			Vector2(82,171), Vector2(262,438), Vector2(439,300)
		]

	elif location_respawn == 3:

		spawn_positions = [
			Vector2(785,-167), Vector2(715,60),
			Vector2(1063,33), Vector2(836,253),
			Vector2(475,278)
		]

	else:
		spawn_positions = [Vector2(182, 416)]


	# ⭐ สุ่มตำแหน่งเกิด
	var spawn_pos = spawn_positions.pick_random()

	# ⭐ random offset กันมอนซ้อน
	var offset = Vector2(
		randf_range(-25,25),
		randf_range(-25,25)
	)

	global_position = spawn_pos + offset
	velocity = Vector2.ZERO

	await get_tree().physics_frame

	move_and_slide()

	is_dead = false

	roll_level()

=======
	# === สุ่มตำแหน่งรอบผู้เล่นในระยะไม่เกิน 300 px ===
	var max_distance = 100
	var random_offset = Vector2(randf_range(-max_distance, max_distance), randf_range(-max_distance, max_distance))
	position = player.position + random_offset

	# === Reset state ===
	is_dead = false
	health = 100
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
	can_take_damage = true
	player_chase = false
	player_inattack_zone = false
	player_is_dead = false
<<<<<<< HEAD
	is_stunned = false

	$healthbar.max_value = health
	$healthbar.value = health
	$healthbar.visible = false
	level_label.visible = true

	enable_enemy()

	set_physics_process(true)

	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("idle")

	coin.position     = coin_start_pos
	coin_fix.position = coin_fix_start_pos

	coin.visible = false
	coin_fix.visible = false

	coin_flying = false
	coin_ready  = false

	print("Enemy respawned at ", global_position)


# ============================================================
# 🔹 Enable / Disable Enemy
# ============================================================
func disable_enemy():

	$enemy_hitbox/CollisionShape2D.disabled = true
	$detection_area/CollisionShape2D.disabled = true
	$collect_area/CollisionShape2D.disabled = true

	$enemy_hitbox.monitoring = false
	$detection_area.monitoring = false
	$collect_area.monitoring = false


func enable_enemy():

	$enemy_hitbox/CollisionShape2D.disabled = false
	$detection_area/CollisionShape2D.disabled = false

	$enemy_hitbox.monitoring = true
	$detection_area.monitoring = true

	set_physics_process(true)


# ============================================================
# 🔹 Visual Feedback
# ============================================================
func flash_red():

	var sprite = $AnimatedSprite2D

	sprite.modulate = Color(1,0,0)

	await get_tree().create_timer(0.2).timeout

	sprite.modulate = Color(1,1,1)


func _on_take_damage_cooldown_timeout():
	can_take_damage = true

func update_health():

	if is_dead:
		return

	var healthbar = $healthbar

	healthbar.value = health
	healthbar.visible = health < healthbar.max_value

	var percent = health / healthbar.max_value

	# เปลี่ยนสีตามเลือด
	if percent > 0.6:
		healthbar.modulate = Color(0.2,1,0.2) # เขียว
	elif percent > 0.3:
		healthbar.modulate = Color(1,0.8,0.2) # เหลือง
	else:
		healthbar.modulate = Color(1,0.2,0.2) # แดง


# ============================================================
# 🔹 Coin Drop System
# ============================================================
func drop_coin():

	coin.position     = coin_start_pos
	coin_fix.position = coin_fix_start_pos

	var drop_fix := randf() < 0.1

	if drop_fix:

		itemRes = coin_fix_item
		coin_fix.visible = true
		print("ดรอป coin_fix")

	else:

		itemRes = coin_item
		coin.visible = true
		print("ดรอป coin ปกติ")

	$collect_area/CollisionShape2D.disabled = false

	coin_ready  = true
	coin_flying = false


# ============================================================
# 🔹 Coin Magnet System
# ============================================================
func check_coin_magnet():

	if not coin_ready or coin_flying:
		return

	var p = get_tree().get_first_node_in_group("player")

	if p == null:
		return

	var coin_node = coin if coin.visible else coin_fix

	if not coin_node.visible:
		return

	var dist = coin_node.global_position.distance_to(p.global_position)

	if dist <= coin_magnet_range:
		start_coin_fly()


func start_coin_fly():

	if coin_flying:
		return

	coin_flying = true

	var p = get_tree().get_first_node_in_group("player")

	if p == null:
		return

	var coin_node = coin if coin.visible else coin_fix

	coin_node.scale = Vector2.ONE

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(coin_node,"global_position",p.global_position,0.25)
	tween.parallel().tween_property(coin_node,"scale",Vector2(0.3,0.3),0.25)

	await tween.finished

	finish_collect(p)


func finish_collect(p):

	coin.visible = false
	coin_fix.visible = false

	if p != null and itemRes != null:
		p.collect(itemRes)

	coin.scale = Vector2.ONE
	coin_fix.scale = Vector2.ONE

	coin_flying = false
	coin_ready  = false


# ============================================================
# 🔹 Hit Stun
# ============================================================
func apply_hit_stun(duration: float = 0.25):

	if is_dead or is_stunned:
		return

	was_chasing_before_stun = player_chase

	is_stunned = true
	player_chase = false

	velocity = Vector2.ZERO

	player_inattack_zone = false

	is_registered_attacker = false

	$enemy_hitbox.set_deferred("monitoring", false)
	$enemy_hitbox/CollisionShape2D.set_deferred("disabled", true)

	$AnimatedSprite2D.play("idle")

	await get_tree().create_timer(duration).timeout

	is_stunned = false

	$enemy_hitbox/CollisionShape2D.set_deferred("disabled", false)
	$enemy_hitbox.set_deferred("monitoring", true)

	if player != null:
		player_chase = was_chasing_before_stun


# ============================================================
# 🔹 Level System
# ============================================================
func roll_level():

	level = randi_range(min_level, max_level)
	apply_level_scaling()

func apply_level_scaling():

	health  = int(base_health  * (1.0 + level * 0.35))
	attack  = int(base_attack  * (1.0 + level * 0.25))
	defense = int(base_defense * (1.0 + level * 0.20))
	speed   = base_speed + level * 2

	$healthbar.max_value = health
	$healthbar.value = health
	level_label.text = "Lv." + str(level)

	print("👾 Monster Lv.", level, "HP:", health)


# ============================================================
# 🔹 EXP Reward
# ============================================================
func give_exp_to_player():

	var p = get_tree().get_first_node_in_group("player")

	if p == null:
		return

	if not p.has_method("gain_exp"):
		return

	var exp_reward = 15 + level * 10

	p.gain_exp(exp_reward)

	print("🎁 Give EXP =", exp_reward)


# ============================================================
# 🔹 Damage Text
# ============================================================
func show_damage(amount:int):

	damaged.text = str(amount)
	damaged.visible = true

	damaged.modulate = Color(1,0.3,0.3)

	var start_pos = damaged.position

	var tween = create_tween()

	tween.tween_property(
		damaged,
		"position",
		start_pos + Vector2(0,-30),
		0.5
	)

	tween.parallel().tween_property(
		damaged,
		"modulate:a",
		0,
		0.5
	)

	await tween.finished

	damaged.visible = false
	damaged.modulate.a = 1
	damaged.position = start_pos
=======

	# === เปิด hitbox และ detection กลับมา ===
	$enemy_hitbox/CollisionShape2D.disabled = false
	$detection_area/CollisionShape2D.disabled = false

	# === แสดง sprite ===
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("idle")

	print("Enemy respawned near player at ", position)

# ทำให้ enemy กระพริบแดงเวลาถูกตี
func flash_red():
	var sprite = $AnimatedSprite2D
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1)
	
func _on_take_damage_cooldown_timeout():
	can_take_damage = true
	
func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	healthbar.visible = health < 100

func drop_coin():
	var drop_fix := false
	
	# โอกาส 30% ดรอป coin_fix
	if randf() < 0.1:
		drop_fix = true

	if drop_fix:
		itemRes = coin_fix_item
		coin_fix.visible = true
		$collect_area/CollisionShape2D.disabled = false
		print("ดรอป coin_fix")
	else:
		itemRes = coin_item
		coin.visible = true
		$collect_area/CollisionShape2D.disabled = false
		print("ดรอป coin ปกติ")

	coin_collect()

func coin_collect():
	await get_tree().create_timer(0.7).timeout
	coin.visible = false
	coin_fix.visible = false

	var p = get_tree().get_first_node_in_group("player")
	if p == null:
		print("ERROR: player is null (did you add Player to group 'player'?)")
	elif itemRes == null:
		print("ERROR: itemRes is null, please assign it in Inspector")
	else:
		p.collect(itemRes)


func _on_collect_area_body_entered(body):
	player = body
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
