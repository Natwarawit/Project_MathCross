extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var hitbox = $hitbox

@export var damage_amount: int = 50  # ดาเมจที่ trap ทำได้
var can_damage = false

func _ready():
	anim.play("default")
	hitbox.monitoring = false  # ปิด hitbox ตอนเริ่ม
	hitbox.connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	var frame = anim.frame

	# เปิด hitbox เมื่อถึงเฟรม 7-12
	if frame >= 3 and frame <= 10:
		can_damage = true
		hitbox.monitoring = true
	else:
		can_damage = false
		hitbox.monitoring = false

func _on_body_entered(body):
	if can_damage and "health" in body:
		body.health -= damage_amount
		if body.has_method("flash_red"):
			body.flash_red()
		print("Trap โจมตี! เหลือ HP =", body.health)
