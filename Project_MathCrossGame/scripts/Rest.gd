extends Node2D

@onready var shop_area = $ShopArea
@onready var earth_area = $EarthArea
@onready var shop_label = $ShopLabel
@onready var earth_label = $EarthLabel
@onready var shop_scene = $Shop
@onready var level_state_scene = $Level_State

var player = null
var shop_interaction_text = "กด F เพื่อเปิดร้าน"
var earth_interaction_text = "กด F เพื่อโต้ตอบกับโลก"
var is_near_shop = false
var is_near_earth = false

func _ready():
	$portal.play("default")
	shop_label.text = ""
	shop_label.hide()
	earth_label.text = ""
	earth_label.hide()

func _process(delta):
	if is_near_shop and Input.is_action_just_pressed("ui_accept"):
		enter_shop()
	elif is_near_earth and Input.is_action_just_pressed("ui_accept"):
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
