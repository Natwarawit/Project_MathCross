extends CanvasLayer

# ===============================
# UI
# ===============================
@onready var label_coin: Label = $CoinLabel
@onready var inv_ui = $Inv_UI
@onready var not_enough_coins_label: Label = $NotEnoughCoinsLabel
@onready var purchase_success_label: Label = $PurchaseSuccessLabel

# Emotion Sprites
@onready var idle: Sprite2D = $Idle
@onready var happy: Sprite2D = $Happy
@onready var sad: Sprite2D = $Sad

# TextureRect
@onready var helmet: TextureRect = $Helmet
@onready var chestplate: TextureRect = $Chestplate
@onready var boots: TextureRect = $Boots
@onready var sword: TextureRect = $Sword

# LABELS
@onready var helmet_name = $HelmetLabel
@onready var helmet_detail = $HelmetLabel/HelmetDetail
@onready var helmet_price = $HelmetLabel/HelmetPrice

@onready var chest_name = $ChestplateLabel
@onready var chest_detail = $ChestplateLabel/ChestplateDetail
@onready var chest_price = $ChestplateLabel/ChestplatePrice

@onready var boots_name = $BootsLabel
@onready var boots_detail = $BootsLabel/BootsDetail
@onready var boots_price = $BootsLabel/BootsPrice

@onready var sword_name = $SwordLabel
@onready var sword_detail = $SwordLabel/SwordDetail
@onready var sword_price = $SwordLabel/SwordPrice

# ===============================
# TEXTURES
# ===============================
@export var helmet_textures: Array[Texture2D] = []
@export var chestplate_textures: Array[Texture2D] = []
@export var boots_textures: Array[Texture2D] = []
@export var sword_textures: Array[Texture2D] = []


# ===============================
# ITEM DATA
# ===============================
var helmet_order = [
	{ "name": "หมวกทองแดง", "price": 2, "detail": "+ พลังชีวิต 50" },
	{ "name": "หมวกเหล็ก", "price": 5, "detail": "+ พลังชีวิต 75" },
	{ "name": "หมวกทอง", "price": 20, "detail": "+ พลังชีวิต 100" },
	{ "name": "หมวกเพชร", "price": 30, "detail": "+ พลังชีวิต 150" }
]

var chestplate_order = [
	{ "name": "เกราะทองแดง", "price": 5, "detail": "+ พลังป้องกัน 10" },
	{ "name": "เกราะเหล็ก", "price": 10, "detail": "+ พลังป้องกัน 20" },
	{ "name": "เกราะทอง", "price": 20, "detail": "+ พลังป้องกัน 25" },
	{ "name": "เกราะเพชร", "price": 30, "detail": "+ พลังป้องกัน 35" }
]

var boots_order = [
	{ "name": "รองเท้าทองแดง", "price": 5, "detail": "+ ความเร็วเคลื่อนที่ 5" },
	{ "name": "รองเท้าเหล็ก", "price": 10, "detail": "+ ความเร็วเคลื่อนที่ 10" },
	{ "name": "รองเท้าทอง", "price": 15, "detail": "+ ความเร็วเคลื่อนที่ 15" },
	{ "name": "รองเท้าเพชร", "price": 20, "detail": "+ ความเร็วเคลื่อนที่ 20" }
]

var sword_order = [
	{ "name": "ดาบระดับ 1", "price": 15, "detail": "+ พลังโจมตี 15" },
	{ "name": "ดาบระดับ 2", "price": 20, "detail": "+ พลังโจมตี 25" },
	{ "name": "ดาบระดับ 3", "price": 30, "detail": "+ พลังโจมตี 40" }
]

# ===============================
# READY
# ===============================
func _ready():

	_set_emotion("idle")

	not_enough_coins_label.visible = false
	purchase_success_label.visible = false


	update_coin_display()
	update_all_shop_ui()

	var coin_timer := Timer.new()
	coin_timer.wait_time = 0.2
	coin_timer.autostart = true
	add_child(coin_timer)
	coin_timer.timeout.connect(update_coin_display)

	$ShopConrol/Helmet.pressed.connect(_on_helmet_pressed)
	$ShopConrol/Chestplate.pressed.connect(_on_chestplate_pressed)
	$ShopConrol/Boots.pressed.connect(_on_boots_pressed)
	$ShopConrol/Sword.pressed.connect(_on_sword_pressed)

# ===============================
# EMOTION SYSTEM
# ===============================
func _set_emotion(state: String):
	idle.visible = state == "idle"
	happy.visible = state == "happy"
	sad.visible = state == "sad"

func _play_emotion(state: String, time := 3.0) -> void:
	_set_emotion(state)
	await get_tree().create_timer(time).timeout
	_set_emotion("idle")

# ===============================
# COIN
# ===============================
func update_coin_display():
	label_coin.text = str(inv_ui.get_item_count_misc("coin"))

# ===============================
# LABEL HELPERS
# ===============================
func _show_label(label: Label, time := 3.0) -> void:
	if not label:
		return
	label.visible = true
	await get_tree().create_timer(time).timeout
	if label:
		label.visible = false

# ===============================
# BUTTON CALLBACKS
# ===============================
func _on_helmet_pressed():
	_buy(global.helmet_index, helmet_order, helmet_textures, helmet, "helmet_index")

func _on_chestplate_pressed():
	_buy(global.chestplate_index, chestplate_order, chestplate_textures, chestplate, "chestplate_index")

func _on_boots_pressed():
	_buy(global.boots_index, boots_order, boots_textures, boots, "boots_index")

func _on_sword_pressed():
	_buy(global.sword_index, sword_order, sword_textures, sword, "sword_index")

# ===============================
# BUY CORE
# ===============================
func _buy(index, order, textures, node, global_key):

	if index >= order.size():
		return

	var data = order[index]
	var coin = inv_ui.get_item_count_misc("coin")

	# ❌ เงินไม่พอ
	if coin < data.price:
		purchase_success_label.visible = false
		_show_label(not_enough_coins_label, 3)
		_play_emotion("sad", 3)
		return

	# ✅ ซื้อสำเร็จ
	inv_ui.set_item_count_misc("coin", coin - data.price)
	global.set(global_key, index + 1)

	var player = get_tree().get_first_node_in_group("player")
	if player:
		match global_key:
			"helmet_index": player.helmet_show(data.name)
			"chestplate_index": player.chestplate_show(data.name)
			"boots_index": player.boots_show(data.name)
			"sword_index": player.sword_show(data.name)

	not_enough_coins_label.visible = false
	_show_label(purchase_success_label, 3)
	_play_emotion("happy", 3)

	update_coin_display()
	update_all_shop_ui()

# ===============================
# UPDATE UI
# ===============================
func update_all_shop_ui():

	_update_ui(global.helmet_index, helmet_order, helmet_textures, helmet, helmet_name, helmet_detail, helmet_price)
	_update_ui(global.chestplate_index, chestplate_order, chestplate_textures, chestplate, chest_name, chest_detail, chest_price)
	_update_ui(global.boots_index, boots_order, boots_textures, boots, boots_name, boots_detail, boots_price)
	_update_ui(global.sword_index, sword_order, sword_textures, sword, sword_name, sword_detail, sword_price)

func _update_ui(index, order, textures, node, name_l, detail_l, price_l):

	if index >= order.size():
		node.visible = false
		name_l.text = "ซื้อครบแล้ว"
		detail_l.text = "-"
		price_l.text = "-"
		return

	var data = order[index]

	if textures.is_empty() or index >= textures.size():
		node.visible = false
		name_l.text = data.name
		detail_l.text = data.detail
		price_l.text = str(data.price)
		return

	node.visible = true
	node.texture = textures[index]

	name_l.text = data.name
	detail_l.text = data.detail
	price_l.text = str(data.price)

# ===============================
# CLOSE
# ===============================
func _on_close_pressed():
	hide()
