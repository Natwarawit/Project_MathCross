extends Control

# เก็บข้อมูลของช่องอุปกรณ์ต่างๆ
var equipment_slots = {
	"hat": null,
	"shirt": null,
	"pants": null,
}

# ไอคอนของหมวกตั้งต้น
var default_hat_icon = preload("res://image/hat.png")

# Reference ไปยังช่อง equipment ต่างๆ
@onready var hat_slot = $Equipment/Hat
@onready var shirt_slot = $Equipment/Shirt
@onready var pants_slot = $Equipment/Pant

# Reference ไปยัง inventory grid
@onready var inventory_grid = $Inventory
var inventory_items = []  # เปลี่ยนเป็น array เปล่าเพื่อเก็บไอเทมแบบไดนามิก

func _ready():
	# สร้างไอเท็มหมวกเริ่มต้น
	var starting_hat = {
		"item_icon": default_hat_icon,
		"item_type": "hat"
	}
	$"../Player/Hat".hide()
	$Player/Hat.hide()
	# เพิ่มไอเทมเริ่มต้นเข้าไปใน inventory
	inventory_items.append(starting_hat)

	# เชื่อมต่อสัญญาณการคลิกของช่องอุปกรณ์
	hat_slot.gui_input.connect(_on_slot_clicked.bind("hat"))
	shirt_slot.gui_input.connect(_on_slot_clicked.bind("shirt"))
	pants_slot.gui_input.connect(_on_slot_clicked.bind("pants"))

	# อัปเดต inventory grid ครั้งแรก
	update_inventory_grid()

# ฟังก์ชันเพิ่มไอเทมลงในอินเวนทอรี
func add_item(item):
	inventory_items.append(item)
	update_inventory_grid()

# อัปเดตการแสดงผล inventory grid
func update_inventory_grid():
	# ลบช่อง inventory เก่าทั้งหมด
	for child in inventory_grid.get_children():
		child.queue_free()

	# สร้างช่องใหม่สำหรับแต่ละไอเทม
	for item in inventory_items:
		var slot = create_inventory_slot(item)
		inventory_grid.add_child(slot)

	# เพิ่มช่องว่างจนครบ 20 ช่อง
	var empty_slots_needed = 20 - inventory_items.size()
	for i in range(empty_slots_needed):
		var empty_slot = create_empty_inventory_slot()
		inventory_grid.add_child(empty_slot)

# สร้างช่อง inventory ที่มีไอเทม
func create_inventory_slot(item) -> Panel:
	var slot = Panel.new()
	slot.custom_minimum_size = Vector2(64, 64)

	if item != null:
		var texture_rect = TextureRect.new()
		texture_rect.texture = item.item_icon
		texture_rect.custom_minimum_size = slot.custom_minimum_size
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.add_child(texture_rect)

		# เพิ่ม signal สำหรับการคลิกที่ไอเทม
		slot.gui_input.connect(_on_item_selected.bind(item))
	
	return slot

# สร้างช่อง inventory ว่าง
func create_empty_inventory_slot() -> Panel:
	var slot = Panel.new()
	slot.custom_minimum_size = Vector2(64, 64)
	return slot

# ฟังก์ชันเมื่อเลือกไอเทม
func _on_item_selected(event: InputEvent, item):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if item.item_type in equipment_slots:
			if equipment_slots[item.item_type] == item:
				unequip_item(item)
			else:
				equip_item(item)

# ฟังก์ชันสำหรับถอดอุปกรณ์
func unequip_item(item):
	if item.item_type in equipment_slots and equipment_slots[item.item_type] == item:
		# ถอดอุปกรณ์ออกจากช่อง
		equipment_slots[item.item_type] = null
		
		# ลบ visual ของไอเทมออกจากช่องอุปกรณ์
		var equipment_slot = get_equipment_slot_node(item.item_type)
		if equipment_slot and equipment_slot.get_child_count() > 0:
			equipment_slot.get_child(0).queue_free()
			$"../Player/Hat".hide()
			$Player/Hat.hide()
		# เพิ่มไอเทมกลับเข้า inventory
		inventory_items.append(item)
		update_inventory_grid()

# ฟังก์ชันสำหรับใส่อุปกรณ์
func equip_item(item):
	if item.item_type in equipment_slots:
		# ถ้ามีไอเทมอยู่ในช่องอยู่แล้ว ให้ถอดออกก่อน
		if equipment_slots[item.item_type] != null:
			unequip_item(equipment_slots[item.item_type])
		
		# ลบไอเทมออกจาก inventory
		inventory_items.erase(item)
		$"../Player/Hat".show()
		$Player/Hat.show()
		# ใส่ไอเทมใหม่
		equipment_slots[item.item_type] = item
		
		# สร้าง visual สำหรับไอเทมในช่องอุปกรณ์
		var equipment_slot = get_equipment_slot_node(item.item_type)
		if equipment_slot:
			var item_visual = create_inventory_slot(item)
			equipment_slot.add_child(item_visual)
		
		update_inventory_grid()

# ฟังก์ชันสำหรับดึง node ของช่องอุปกรณ์
func get_equipment_slot_node(slot_type: String) -> Node:
	match slot_type:
		"hat": return hat_slot
		"shirt": return shirt_slot
		"pants": return pants_slot
	return null

# ฟังก์ชันเมื่อคลิกที่ช่องอุปกรณ์
func _on_slot_clicked(event: InputEvent, slot_type: String):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if equipment_slots[slot_type] != null:
			unequip_item(equipment_slots[slot_type])
