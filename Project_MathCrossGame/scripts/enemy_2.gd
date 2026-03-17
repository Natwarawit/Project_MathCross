extends CharacterBody2D

@onready var coin = $coin_collectable
@onready var coin_fix = $coin_fix_answer_collectable
@export var itemRes: InvItem
@export var coin_item: InvItem = preload("res://inventory/items/coin.tres")
@export var coin_fix_item: InvItem = preload("res://inventory/items/coin_fix.tres")
@export var location_respawn = 0

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
	if player_is_dead:
		$AnimatedSprite2D.play("idle")
		return

	deal_with_damage()
	update_health()

	if is_dead:
		return

	if player_chase and player != null:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		move_and_slide()
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
		move_and_slide()
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
		if can_take_damage and player != null and not is_dead:  # เพิ่มการตรวจสอบว่า enemy ตายหรือยัง
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
	if player == null:
		print("Respawn failed: player not found.")
		return

	# === กำหนดตำแหน่งที่มอนสามารถเกิดได้ ===
	var spawn_positions: Array = []

	if location_respawn == 1:
		spawn_positions = [
			Vector2(345,235),
			Vector2(449, -93),
			Vector2(427, 86),
			Vector2(344, 13),
			Vector2(194, 102),
			Vector2(-17, 20)
		]
	elif location_respawn == 2:
		spawn_positions = [
			Vector2(345,235),
			Vector2(184,192),
			Vector2(558,113),
			Vector2(82,171),
			Vector2(262,438),
			Vector2(439,300)
		]
	elif location_respawn == 3:
		spawn_positions = [
			Vector2(785, -167),
			Vector2(715, 60),
			Vector2(1063, 33),
			Vector2(836, 253),
			Vector2(475, 278)
		]
	else:
		# กำหนดค่า default กรณี location_respawn ผิด
		spawn_positions = [
			Vector2(345,235)
		]

	# === เลือกตำแหน่งที่ x ใกล้กับผู้เล่นที่สุด ===
	var closest_pos = spawn_positions[0]
	var min_diff = abs(player.position.x - closest_pos.x)

	for pos in spawn_positions:
		var diff = abs(player.position.x - pos.x)
		if diff < min_diff:
			min_diff = diff
			closest_pos = pos

	# === สุ่มเกิดจากตำแหน่งที่ใกล้ผู้เล่น ===
	position = closest_pos

	# === Reset state ===
	is_dead = false
	health = 100
	can_take_damage = true
	player_chase = false
	player_inattack_zone = false
	player_is_dead = false

	# === เปิด hitbox และ detection กลับมา ===
	$enemy_hitbox/CollisionShape2D.disabled = false
	$detection_area/CollisionShape2D.disabled = false

	# === แสดง sprite ===
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("idle")

	print("Enemy respawned at ", position)



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
