extends CanvasLayer

@onready var shop = $Shop
@onready var label = $Label7
@onready var inv_ui = $Inv_UI
@onready var not_enough_coins_label = $NotEnoughCoinsLabel
@onready var purchase_success_label = $PurchaseSuccessLabel
@export var inv: Inv
@export var hat_texture: Texture2D
@export var sword_texture: Texture2D
@export var armor_texture: Texture2D

var item_prices = {
	"หมวก": 2,
	"ดาบ": 5,
	"ชุด": 10
}

var selected_item = ""

func _ready():
	
	$Inv_UI.hide()
	
	# เรียกอัปเดตครั้งแรกแบบหน่วง เพื่อให้ inv_ui โหลดข้อมูลเสร็จก่อน
	await get_tree().create_timer(0.2).timeout
	update_coin_display()
	
	# ตั้ง Timer ให้อัปเดต coin บ่อย ๆ (ทุก 0.2 วินาที)
	var coin_timer = Timer.new()
	coin_timer.wait_time = 0.2
	coin_timer.autostart = true
	coin_timer.one_shot = false
	add_child(coin_timer)
	coin_timer.connect("timeout", Callable(self, "update_coin_display"))

	# เชื่อมปุ่ม
	$ShopConrol/Hat.connect("pressed", Callable(self, "_on_hat_pressed"))
	$ShopConrol/Sword.connect("pressed", Callable(self, "_on_sword_pressed"))
	$ShopConrol/Armor.connect("pressed", Callable(self, "_on_armor_pressed"))
	$Button.connect("pressed", Callable(self, "_on_button_pressed"))

	not_enough_coins_label.visible = false
	purchase_success_label.visible = false


# === แสดงจำนวน coin ===
func update_coin_display():
	if inv_ui == null:
		return
	var coin_count = inv_ui.get_item_count_misc("coin")
	label.text = str(coin_count)


# === ซื้อของ ===
func buy_item(item_name: String):
	var price = item_prices[item_name]
	var coin_count = inv_ui.get_item_count_misc("coin")
	var new_coin_count = coin_count - price

	inv_ui.set_item_count_misc("coin", new_coin_count)
	if inv_ui.get_item_count_misc("coin") == 0:
		inv_ui.remove_item_from_inventory_misc("coin")

	var new_item = InvItem.new()
	new_item.name = item_name

	match item_name:
		"หมวก":
			new_item.texture = hat_texture
		"ดาบ":
			new_item.texture = sword_texture
		"ชุด":
			new_item.texture = armor_texture

	update_coin_display()
	print("ซื้อ " + item_name + " สำเร็จ! เหรียญเหลือ:", inv_ui.get_item_count_misc("coin"))

	purchase_success_label.visible = true
	not_enough_coins_label.visible = false


# === ปุ่มกด ===
func _on_hat_pressed():
	selected_item = "หมวก"
	if _check_and_buy(selected_item):
		global.player_has_helmet = true
		$"../player".helmet_show()

func _on_sword_pressed():
	selected_item = "ดาบ"
	_check_and_buy(selected_item)

func _on_armor_pressed():
	selected_item = "ชุด"
	_check_and_buy(selected_item)

func _check_and_buy(item_name: String) -> bool:
	var price = item_prices[item_name]
	var coin_count = inv_ui.get_item_count_misc("coin")

	if coin_count >= price:
		buy_item(item_name)
		return true
	else:
		not_enough_coins_label.visible = true
		purchase_success_label.visible = false
		return false

func _on_button_pressed():
	hide()
