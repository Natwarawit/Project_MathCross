extends CharacterBody2D

var speed = 30
var player_chase = false
var player = null
var is_dead = false
var health = 100
var player_inattack_zone = false
var can_take_damage = true

func _physics_process(delta):
	deal_with_damage()
	update_health()
	
	if player_chase and player != null:
		var direction = (player.position - position).normalized()
		position += direction * speed * delta  # เดินทีละนิดตาม speed
		
		$AnimatedSprite2D.play("walk")
		
		# หมุน sprite ตามทิศทาง
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
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

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_inattack_zone= false

func deal_with_damage():
	if player_inattack_zone and global.player_current_attack:
		if can_take_damage:
			take_damage(40)   # โดนดาบ

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
	drop_coin()

# drop coin
@onready var coin = $coin_collectable
@export var itemRes: InvItem

func drop_coin():
	coin.visible = true
	$coin_collect_area/CollisionShape2D.disabled = false
	coin_collect()

func coin_collect():
	await get_tree().create_timer(0.7).timeout
	coin.visible = false

	var p = get_tree().get_first_node_in_group("player")
	if p == null:
		print("ERROR: player is null (did you add Player to group 'player'?)")
	elif itemRes == null:
		print("ERROR: itemRes is null, please assign it in Inspector")
	else:
		p.collect(itemRes)

	queue_free()



func _on_take_damage_cooldown_timeout():
	can_take_damage = true
	
func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	healthbar.visible = health < 100

func _on_coin_collect_area_body_entered(body):
	player = body

# ทำให้ enemy กระพริบแดงเวลาถูกตี
func flash_red():
	var sprite = $AnimatedSprite2D
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1)
