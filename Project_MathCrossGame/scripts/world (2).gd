extends Node2D

const loading = preload("res://scenes/loading.tscn")
@onready var walk: Label = $CanvasLayer/Mission/walk
@onready var attack: Label = $CanvasLayer/Mission/walk2
@onready var inventory: Label = $CanvasLayer/Mission/inventory
@onready var eat: Label = $CanvasLayer/Mission/eat
@onready var open_chest: Label = $CanvasLayer/Mission/walk4
@onready var mathcross: Label = $CanvasLayer/Mission/walk6
@onready var background_mathcross  = $background_mathcross
@onready var background_mathcross2 = $background_mathcross2

var player_in_area := false
var background_changed := false
# ===== Tutorial States =====
var walk_done := false
var attack_done := false
var eat_done := false
var chest_done := false
var math_done := false
var inventory_done := false

func _ready():
	$portal.play("default")

	# ===== Connect signals =====
	if has_node("player"):
		$player.apple_eaten.connect(_on_player_apple_eaten)
		$player.shoote.connect(_on_player_shoot)

	if has_node("mathcross"):
		$mathcross.mathcross_completed.connect(_on_mathcross_completed)

func _process(delta):
	_check_tutorial_conditions()
	if $mathcross.current_grid_index == 1 and not background_changed:
		background_changed = true
		change_background_after_delay()


	if player_in_area and Input.is_action_just_pressed("F"):
		global.last_cleared_stage = 0
		get_tree().change_scene_to_file("res://scenes/story.tscn")


# ===== ตรวจเงื่อนไข tutorial =====
func _check_tutorial_conditions():
	# เดิน
	if not walk_done and (
		Input.is_action_just_pressed("W")
		or Input.is_action_just_pressed("A")
		or Input.is_action_just_pressed("S")
		or Input.is_action_just_pressed("D")
	):
		walk_done = true
		_set_label_done(walk)

	# โจมตี / ยิงธนู / สกิล
	if not attack_done and (
		Input.is_action_just_pressed("attack")
		or Input.is_action_just_pressed("E")
	):
		attack_done = true
		_set_label_done(attack)

	# เปิด inventory
	if not inventory_done and Input.is_action_just_pressed("i"):
		inventory_done = true
		_set_label_done(inventory)

	# เปิดกล่อง
	if not chest_done and $Chest.received_numbers.size() > 0:
		chest_done = true
		_set_label_done(open_chest)


# ===== Signals =====
func _on_player_apple_eaten():
	if eat_done:
		return
	eat_done = true
	_set_label_done(eat)

func _on_player_shoot():
	if attack_done:
		return
	attack_done = true
	_set_label_done(attack)

func _on_mathcross_completed():
	if math_done:
		return
	math_done = true
	_set_label_done(mathcross)


# ===== Utils =====
func _set_label_done(label: Label):
	label.modulate = Color(0, 1, 0) # สีเขียว


func _all_conditions_done() -> bool:
	return (
		walk_done
		or attack_done
		or eat_done
		or chest_done
		or math_done
		or inventory_done
	)


# ===== Portal Area =====
func _on_portal_area_body_entered(body):
	if body.name == "player":
		player_in_area = true


func _on_portal_area_body_exited(body):
	if body.name == "player":
		player_in_area = false

func change_background_after_delay():
	await get_tree().create_timer(3.0).timeout
	background_mathcross.visible = false
	background_mathcross2.visible = true
