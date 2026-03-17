extends CharacterBody2D

# ============================================================
# Node References
# ============================================================
@onready var coin      = $coin_collectable
@onready var coin_fix  = $coin_fix_answer_collectable
@onready var damaged   = $damaged
@onready var level_label = $levellabel

# ============================================================
# Arrow System
# ============================================================
@export var shoot_range: float = 220.0
@export var shoot_cooldown: float = 1.5
@export var arrow_scene: PackedScene

var can_shoot := true

# ============================================================
# Exported Data
# ============================================================
@export var itemRes: InvItem
@export var coin_item: InvItem     = preload("res://inventory/items/coin.tres")
@export var coin_fix_item: InvItem = preload("res://inventory/items/coin_fix.tres")
@export var location_respawn = 0
@export var coin_magnet_range: float = 80.0

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
# Enemy State
# ============================================================
var player_chase = false
var player = null
var is_dead = false
var player_inattack_zone = false
var can_take_damage = true
var player_is_dead = false
var is_stunned = false
var was_chasing_before_stun = false

# ============================================================
# Ready
# ============================================================
func _ready():

	randomize()
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

	roll_level()


# ============================================================
# Main Loop
# ============================================================
func _physics_process(delta):

	if player_is_dead:
		$AnimatedSprite2D.play("idle")
		return

	if is_dead:
		return

	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	update_health()

	var distance := global_position.distance_to(player.global_position)

	# ================================
	# AI ระยะยิง
	# ================================
	if distance > shoot_range:

		var dir = (player.global_position - global_position).normalized()

		velocity = dir * speed
		move_and_slide()

		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = dir.x < 0

	else:

		velocity = Vector2.ZERO
		move_and_slide()

		$AnimatedSprite2D.play("idle")

		face_player()
		shoot_arrow()


# ============================================================
# ยิงธนู
# ============================================================
func shoot_arrow():

	if not can_shoot:
		return

	if arrow_scene == null:
		return

	can_shoot = false

	var arrow = arrow_scene.instantiate()
	get_parent().add_child(arrow)

	arrow.global_position = global_position

	var dir = (player.global_position - global_position).normalized()

	arrow.rotation = dir.angle()

	arrow.damage = attack

	await get_tree().create_timer(shoot_cooldown).timeout

	can_shoot = true


func face_player():

	if player == null:
		return

	$AnimatedSprite2D.flip_h = player.global_position.x < global_position.x


# ============================================================
# Damage System
# ============================================================
func take_damage(amount:int):

	if not can_take_damage:
		return

	health -= amount

	$take_damage_cooldown.start()

	can_take_damage = false

	flash_red()

	if health <= 0:
		death()


# ============================================================
# Death
# ============================================================
func death():

	is_dead = true

	velocity = Vector2.ZERO

	$AnimatedSprite2D.visible = false
	$enemy_hitbox/CollisionShape2D.disabled = true
	$detection_area/CollisionShape2D.disabled = true
	$healthbar.visible = false
	#level_label.visible = false

	drop_coin()

	respawn_after_delay(3.0)


# ============================================================
# Respawn
# ============================================================
func respawn_after_delay(time:float):

	await get_tree().create_timer(time).timeout
	respawn()


func respawn():

	player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	global_position = Vector2(
		randf_range(-200,200),
		randf_range(-200,200)
	)

	is_dead = false

	roll_level()

	can_take_damage = true

	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("idle")

	$enemy_hitbox/CollisionShape2D.disabled = false
	$detection_area/CollisionShape2D.disabled = false


# ============================================================
# Level System
# ============================================================
func roll_level():

	level = randi_range(min_level, max_level)

	health  = int(base_health  * (1.0 + level * 0.35))
	attack  = int(base_attack  * (1.0 + level * 0.25))
	defense = int(base_defense * (1.0 + level * 0.20))
	speed   = base_speed + level * 2

	$healthbar.max_value = health
	$healthbar.value = health

	#level_label.text = "Lv." + str(level)


# ============================================================
# Health Bar
# ============================================================
func update_health():

	var healthbar = $healthbar

	healthbar.value = health

	healthbar.visible = health < healthbar.max_value


# ============================================================
# Visual
# ============================================================
func flash_red():

	var sprite = $AnimatedSprite2D

	sprite.modulate = Color(1,0,0)

	await get_tree().create_timer(0.2).timeout

	sprite.modulate = Color(1,1,1)


func _on_take_damage_cooldown_timeout():

	can_take_damage = true


# ============================================================
# Coin Drop
# ============================================================
func drop_coin():

	var drop_fix := randf() < 0.1

	if drop_fix:

		itemRes = coin_fix_item
		coin_fix.visible = true

	else:

		itemRes = coin_item
		coin.visible = true

	$collect_area/CollisionShape2D.disabled = false

	await get_tree().create_timer(0.7).timeout

	coin.visible = false
	coin_fix.visible = false

	var p = get_tree().get_first_node_in_group("player")

	if p and itemRes:

		p.collect(itemRes)
