extends Node2D

@onready var shop_area = $ShopArea
@onready var earth_area = $EarthArea
@onready var shop_label = $ShopLabel
@onready var earth_label = $EarthLabel
@onready var shop_scene = $Shop
@onready var level_state_scene = $Level_State

var player = null
<<<<<<< HEAD
var shop_interaction_text = "กด F เพื่อเปิดร้านค้า"
var earth_interaction_text = "กด F เพื่อเปิดแผนที่"
=======
var shop_interaction_text = "กด F เพื่อเปิดร้าน"
var earth_interaction_text = "กด F เพื่อโต้ตอบกับโลก"
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
var is_near_shop = false
var is_near_earth = false

func _ready():
<<<<<<< HEAD
=======
	$portal.play("default")
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
	shop_label.text = ""
	shop_label.hide()
	earth_label.text = ""
	earth_label.hide()

func _process(delta):
<<<<<<< HEAD
	if is_near_shop and Input.is_action_just_pressed("F"):
		enter_shop()

	elif is_near_earth and Input.is_action_just_pressed("F"):
=======
	if is_near_shop and Input.is_action_just_pressed("ui_accept"):
		enter_shop()
	elif is_near_earth and Input.is_action_just_pressed("ui_accept"):
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
		enter_level()

func enter_shop():
	shop_scene.visible = true

func enter_level():
	level_state_scene.visible = true

func _on_shop_area_body_entered(body):
	if body.name == "player":
		player = body
		shop_label.text = shop_interaction_text
		shop_label.visible = true
		is_near_shop = true

func _on_shop_area_body_exited(body):
	if body.name == "player":
		shop_label.visible = false
		is_near_shop = false

func _on_earth_area_body_entered(body):
	if body.name == "player":
		player = body
		earth_label.text = earth_interaction_text
		earth_label.visible = true
		is_near_earth = true

func _on_earth_area_body_exited(body):
	if body.name == "player":
		earth_label.visible = false
		is_near_earth = false
