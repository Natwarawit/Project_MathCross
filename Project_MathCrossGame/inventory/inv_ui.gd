extends CanvasLayer

# === INVENTORY VARIABLES ===
@onready var inv_main: Inv = preload("res://inventory/playerinv.tres")  # Inventory ช่องบน (ตัวเลข MathCross)
@onready var inv_misc: Inv = preload("res://inventory/miscinv.tres")    # Inventory ช่องล่าง (coin, apple, fixcoin)

@onready var slots_main: Array = $Inv_UI/NinePatchRect/GridContainer.get_children()
@onready var slots_misc: Array = $Inv_UI/NinePatchRect2/GridContainer.get_children()

# === GAME / UI REFERENCES ===
@onready var choices_container = $Inv_UI/ChoiceContainer
@onready var game = $tutorialgame
#@onready var level1 = $"../../mathcross_level1"
@onready var level1 = get_node("../../mathcross_level1")

# === STATE VARIABLES ===
var choices = []
var is_open = false
var tracked_item_numbers = [1, 2, 5, 6, 7, 8, 9]

# === READY ===
func _ready():
	inv_main.update.connect(update_slots)
	inv_misc.update.connect(update_slots)
	
	
	
	update_slots()
	close()
	choices_container.visible = false

func _process(delta):
	handle_toggle_inventory()
	check_tracked_items()

# === INVENTORY DISPLAY ===
func open():
	self.visible = true
	is_open = true
	set_up_choices()

func close():
	visible = false
	is_open = false

func update_slots():
	# === ช่องด้านบน (ตัวเลข) ===
	for i in range(min(inv_main.slots.size(), slots_main.size())):
		var slot = slots_main[i]
		slot.update(inv_main.slots[i])
		if not slot.is_connected("slot_clicked", Callable(self, "_on_slot_clicked_main")):
			slot.connect("slot_clicked", Callable(self, "_on_slot_clicked_main"))

	# === ช่องด้านล่าง (coin/apple/fixcoin) ===
	for i in range(min(inv_misc.slots.size(), slots_misc.size())):
		var slot = slots_misc[i]
		slot.update(inv_misc.slots[i])
		if not slot.is_connected("slot_clicked", Callable(self, "_on_slot_clicked_misc")):
			slot.connect("slot_clicked", Callable(self, "_on_slot_clicked_misc"))

# === INVENTORY TOGGLE ===
func handle_toggle_inventory():
	if Input.is_action_just_pressed("i"):
		if is_open:
			close()
		else:
			open()

# === CHOICE SYSTEM (สำหรับ MathCross) ===
func set_up_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()
	for choice in choices:
		var btn = Button.new()
		btn.text = str(choice)
		choices_container.add_child(btn)

func update_choices():
	set_up_choices()

func handle_choice(choice: int) -> void:
	for child in choices_container.get_children():
		if child.text == str(choice):
			child.modulate = Color(1, 0, 0)

func remove_choice_from_grid(choice: int):
	choices.erase(choice)
	update_choices()

# === SLOT CLICK EVENTS ===
func _on_slot_clicked_main(number: int):
	print("Inventory ตัวเลข คลิก:", number)

	if level1 == null:
		print("❌ ไม่พบ node mathcross_level1")
		return

	# ตรวจว่าตารางมีตัวเลขนี้ในตัวเลือกปัจจุบันไหม
	if level1.choices[level1.current_grid_index].has(number):
		level1.select_choice(number)
		print("✅ MathCross เลือกเลข:", number)

		# ลบจากช่อง inventory
		remove_choice_from_inventory(number)
		remove_choice_from_grid(number)
	else:
		print("❌ ตัวเลขนี้ไม่อยู่ในตัวเลือกของ grid ปัจจุบัน")





func _on_slot_clicked_misc(number: int):
	print("Inventory ของทั่วไป คลิก:", number)
	# เช่น ใช้กิน apple หรือใช้ coin ในเกมได้
	# ตัวอย่าง:
	# use_misc_item(number)

# === INVENTORY CHECKING ===
func check_tracked_items():
	for num in tracked_item_numbers:
		var item_name = "ปุ่มหมายเลข " + str(num)
		if has_item_in_inventory_main(item_name) and not choices.has(num):
			choices.append(num)
			update_choices()

func has_item_in_inventory_main(item_name: String) -> bool:
	for invslot in inv_main.slots:
		if invslot.item != null and invslot.item.name == item_name:
			return true
	return false
	
func has_item_in_inventory_misc(item_name: String) -> bool:
	for invslot in inv_main.slots:
		if invslot.item != null and invslot.item.name == item_name:
			return true
	return false

# === INVENTORY MODIFYING (ตัวเลข MathCross) ===
func remove_choice_from_inventory(choice: int):
	var target_name = "ปุ่มหมายเลข " + str(choice)
	for invslot in inv_main.slots:
		if invslot.item != null and invslot.item.name == target_name:
			if invslot.amount > 1:
				invslot.amount -= 1
			else:
				invslot.item = null
			inv_main.update.emit()
			update_slots()
			break

func add_choice_to_inventory(choice: int):
	var item_name = "ปุ่มหมายเลข " + str(choice)
	var added = false
	for invslot in inv_main.slots:
		if invslot.item != null and invslot.item.name == item_name:
			invslot.amount += 1
			added = true
			break
		elif invslot.item == null and not added:
			var texture_path = "res://drop_numbers/number_" + str(choice) + ".png"
			var item_texture: Texture2D = load(texture_path)
			var new_item = InvItem.new()
			new_item.name = item_name
			new_item.texture = item_texture
			inv_main.insert(new_item)
			added = true
			break
	if added:
		inv_main.update.emit()
		update_slots()

# === INVENTORY MODIFYING (ของทั่วไป) ===
func add_misc_item(name: String, texture_path: String):
	var added = false
	for invslot in inv_misc.slots:
		# ป้องกันช่องที่เป็น null
		if invslot == null:
			continue

		if invslot.item != null and invslot.item.name == name:
			invslot.amount += 1
			added = true
			break
		elif invslot.item == null and not added:
			var item_texture = load(texture_path)
			var new_item = InvItem.new()
			new_item.name = name
			new_item.texture = item_texture
			inv_misc.insert(new_item)
			added = true
			break

	if added:
		inv_misc.update.emit()
		update_slots()


func remove_item_from_inventory_misc(name: String):
	for invslot in inv_misc.slots:
		if invslot == null:
			continue

		if invslot.item != null and invslot.item.name == name:
			if invslot.amount > 1:
				invslot.amount -= 1
			else:
				invslot.item = null
			inv_misc.update.emit()
			update_slots()
			break


func set_item_count_misc(name: String, new_count: int) -> void:
	for invslot in inv_misc.slots:
		if invslot == null:
			continue

		if invslot.item != null and invslot.item.name == name:
			invslot.amount = new_count
			inv_misc.update.emit()
			update_slots()
			break

func get_item_count_misc(name: String) -> int:
	for invslot in inv_misc.slots:
		if invslot == null:
			continue

		if invslot.item != null and invslot.item.name == name:
			return invslot.amount
	return 0
