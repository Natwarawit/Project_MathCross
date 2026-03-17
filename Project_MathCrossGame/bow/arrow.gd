extends Node2D

# ==================================================
# Config
# ==================================================
const SPEED: int = 200

# ==================================================
# Damage Stats
# ==================================================
@export var base_damage = 20
var final_damage = 0

# ==================================================
# Movement System
# ==================================================
func _process(delta):
	position += transform.x * SPEED * delta

# ==================================================
# Damage System
# ==================================================
func set_damage_multiplier(multiplier: float):
	final_damage = int(base_damage * multiplier)

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(final_damage)
		queue_free()

# ==================================================
# Cleanup System
# ==================================================
func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()
