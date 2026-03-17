extends CharacterBody2D

@onready var player: Node2D = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var progress_bar: ProgressBar = $UI/ProgressBar
@onready var fsm = $FiniteStateMachine

var can_take_damage := true
var player_inattack_zone := false
var player_is_dead := false
var is_dead := false

var direction: Vector2 = Vector2.ZERO

# ==========================================================
# LEVEL SYSTEM
# ==========================================================

var level := 1
@export var min_level := 1
@export var max_level := 30

# ==========================================================
# BASE STATS
# ==========================================================

var base_health := 300
var base_attack := 30
var base_defense := 10
var base_speed := 10

# ==========================================================
# FINAL STATS
# ==========================================================

var health := 0
var attack := 0
var defense := 0
var speed := 0

# ==========================================================
# READY
# ==========================================================

func _ready():

	add_to_group("enemies")

	if player == null:
		push_warning("Player not found")

	randomize()
	roll_level()

	progress_bar.max_value = health
	progress_bar.value = health


# ==========================================================
# LEVEL SYSTEM
# ==========================================================

func roll_level():

	level = randi_range(min_level,max_level)
	apply_level_scaling()


func apply_level_scaling():

	health  = int(base_health  * (1.0 + level * 0.4))
	attack  = int(base_attack  * (1.0 + level * 0.3))
	defense = int(base_defense * (1.0 + level * 0.25))
	speed   = base_speed + level * 5

	progress_bar.max_value = health
	progress_bar.value = health

	print("👑 Boss Lv.",level,"HP:",health)


# ==========================================================
# PROCESS
# ==========================================================

func _process(_delta):

	if player == null or is_dead:
		return

	direction = player.global_position - global_position
	sprite.flip_h = direction.x < 0


# ==========================================================
# MOVEMENT
# ==========================================================

func _physics_process(delta):

	if is_dead:
		return

	if player_is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if player:

		var dir = (player.global_position - global_position).normalized()

		velocity = dir * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	check_player_attack()


# ==========================================================
# DAMAGE
# ==========================================================

func take_damage(damage):

	if is_dead:
		return

	health -= damage
	progress_bar.value = health

	print("Boss HP =",health)

	if health <= 0:
		die()

	can_take_damage = false
	await get_tree().create_timer(0.3).timeout
	can_take_damage = true


func check_player_attack():

	if not can_take_damage:
		return

	if player == null:
		return

	if not global.player_current_attack:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance > player.attack_range:
		return

	var damage = max(player.attack - defense,1)

	take_damage(damage)


# ==========================================================
# ATTACK
# ==========================================================

func melee_attack():

	if is_dead:
		return

	$AnimationPlayer.play("attack")
	$Hitbox_melee_attack.monitoring = true

	await get_tree().create_timer(0.2).timeout

	$Hitbox_melee_attack.monitoring = false


func _on_hitbox_melee_attack_body_entered(body):

	if body.is_in_group("player"):

		if body.has_method("take_damage"):

			var damage = max(attack - body.def,1)

			body.take_damage(damage)


# ==========================================================
# ATTACK ZONE
# ==========================================================

func _on_area_2d_body_entered(body):

	if body.is_in_group("player"):
		player_inattack_zone = true


func _on_area_2d_body_exited(body):

	if body.is_in_group("player"):
		player_inattack_zone = false


# ==========================================================
# DIE
# ==========================================================

func die():

	is_dead = true
	progress_bar.visible = false
	fsm.change_state("Death")

func _on_laser_body_entered(body):

	if body.is_in_group("player"):

		if body.has_method("take_damage"):

			var damage = max(attack - body.def, 1)

			# ถ้าอยู่ state LaserBeam ให้ดาเมจ x2
			if fsm.current_state.name == "LaserBeam":
				damage *= 2

			body.take_damage(damage)
