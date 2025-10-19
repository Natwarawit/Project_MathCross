extends CharacterBody2D

var player = null
var can_interact = false  # ตัวแปรบอกว่าสามารถกด F ได้ไหม

func _ready():
	$NPC.play("idle")
	$NPC.flip_h = true
	$Label.visible = false

func _on_npc_area_body_entered(body):
	if body.name == "player":
		player = body
		can_interact = true
		$Label.visible = true

func _on_npc_area_body_exited(body):
	if body.name == "player":
		can_interact = false
		player = null
		$Label.visible = false
		#$"../mathcross_level1".visible = false

func _process(delta):
	# --- หันหน้า NPC ตามตำแหน่งของ player ---
	if player:
		if player.global_position.x < global_position.x:
			$NPC.flip_h = true  # player อยู่ซ้าย → หันซ้าย
		else:
			$NPC.flip_h = false  # player อยู่ขวา → หันขวา

	# --- ตรวจสอบการกด F เพื่อเปิดหน้าต่าง ---
	if can_interact and Input.is_action_just_pressed("F"):
		$"../mathcross_level1".visible = true
