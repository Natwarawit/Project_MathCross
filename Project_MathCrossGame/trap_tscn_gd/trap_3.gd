extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var hitbox = $hitbox
@onready var player_in = $player_in

@export var damage_amount: int = 20

var can_damage = false
var is_attacking = false

func _ready():
	anim.stop()
	hitbox.monitoring = false

	player_in.body_entered.connect(_on_player_enter)
	hitbox.body_entered.connect(_on_body_entered)

	anim.animation_finished.connect(_on_anim_finished)


func _process(_delta):
	var frame = anim.frame

	if frame >= 1 and frame <= 3:
		can_damage = true
		hitbox.monitoring = true
	else:
		can_damage = false
		hitbox.monitoring = false


func _on_player_enter(body):
	if body.name == "player" and !is_attacking:
		is_attacking = true
		anim.play("default")


func _on_player_exit(body):
	if body.name == "player":
		is_attacking = false


func _on_anim_finished():
	anim.stop()
	anim.frame = 3

func _on_body_entered(body):
	if can_damage and "health" in body:
		body.health -= damage_amount
		if body.has_method("flash_red"):
			body.flash_red()

		print("Trap โจมตี! เหลือ HP =", body.health)
