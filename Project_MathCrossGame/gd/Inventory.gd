extends Control

@onready var bagContainer: Node = null
@onready var keyBarContainer: Node = null
@onready var equipmentLeft: Node = null
@onready var equipmentRight: Node = null
var inventoryDict = {}
var items = []
var dragged_item: Item = null
var dragged_slot: Node = null

func _ready():
	# โหลด Node และตรวจสอบว่าถูกต้องหรือไม่
	bagContainer = get_node_or_null("TextureRect/BagSlots")
	keyBarContainer = get_node_or_null("TextureRect/KeyBar")
	equipmentLeft = get_node_or_null("TextureRect/EquipmentLeft")
	equipmentRight = get_node_or_null("TextureRect/EquipmentRight")

	print("BagSlots:", bagContainer)
	print("KeyBar:", keyBarContainer)
	print("EquipmentLeft:", equipmentLeft)
	print("EquipmentRight:", equipmentRight)

	inventoryDict = {
		"BagSlots": bagContainer,
		"KeyBar": keyBarContainer,
		"EquipmentLeft": equipmentLeft,
		"EquipmentRight": equipmentRight
	}

	# ตัวอย่างการเพิ่มไอเทม
	var armor = load("res://gd/Armor.tres") as Item
	var letter = load("res://gd/number1.tres") as Item
	add_item(armor)
	add_item(letter)

	refresh_ui()

# ฟังก์ชันที่ใช้ในการเพิ่มไอเทมลงใน inventory
func add_item(item: Item):
	item.inventarSlot = "BagSlots"  # หรือที่คุณต้องการ
	item.inventarPosition = _get_next_empty_bag_slot()
	items.append(item)
	refresh_ui()

# ฟังก์ชันที่ใช้ในการหาตำแหน่งว่างใน "BagSlots"
func _get_next_empty_bag_slot():
	# วนลูปหาทุก slot ใน "BagSlots"
	for slot in inventoryDict["BagSlots"].get_children():
		# ถ้า slot นั้นยังไม่มี texture (ว่าง)
		if slot.texture == null:
			# แยกชื่อ slot เพื่อหาหมายเลขของ slot
			var slotNumber = int(slot.name.split("Slot")[1])
			return slotNumber
	return -1  # ถ้าไม่มีช่องว่างให้คืนค่า -1

# ฟังก์ชันเพื่อแสดงข้อมูล UI
func refresh_ui():
	# ล้างข้อมูลในทุกๆ slot และเติมใหม่
	for item in items:
		var inventarSlot = item.inventarSlot
		var inventarPosition = item.inventarPosition
		var icon = item.icon
		
		# ตรวจสอบทุกช่องใน inventarSlot
		for slot in inventoryDict[inventarSlot].get_children():
			var slotNumber = int(slot.name.split("Slot")[1])
			
			# หาก slotNumber ตรงกับ inventarPosition
			if slotNumber == inventarPosition:
				slot.texture = icon  # ตั้งค่า icon ของไอเทมให้เป็น texture ของ slot

# การจับและลากไอเทม
func _on_slot_input_event(slot, event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# ถ้ากดปุ่มซ้ายจะจับไอเทม
			if slot.texture != null:
				dragged_item = get_item_from_slot(slot)
				dragged_slot = slot
				# เริ่มลากไอเทม
				begin_dragging(slot)

# ฟังก์ชันเริ่มการลาก
func begin_dragging(slot):
	# สร้าง drag preview
	var drag_preview = TextureRect.new()
	drag_preview.texture = slot.texture
	drag_preview.custom_minimum_size = Vector2(68, 68)
	add_child(drag_preview)
	set_drag_preview(drag_preview)

func get_item_from_slot(slot):
	# หาค่าของ item ที่อยู่ใน slot
	for item in items:
		if item.inventarSlot == "BagSlots" and item.inventarPosition == int(slot.name.split("Slot")[1]):
			return item
	return null

# ฟังก์ชันเพื่อจัดการเมื่อปล่อยไอเทม
func _on_slot_drop(slot):
	if dragged_item:
		# เปลี่ยนตำแหน่งของไอเทม
		dragged_item.inventarSlot = "BagSlots"  # หรือ slot ใหม่ที่ต้องการ
		dragged_item.inventarPosition = int(slot.name.split("Slot")[1])
		dragged_slot.texture = null  # ลบ texture จาก slot เดิม
		slot.texture = dragged_item.icon  # เพิ่ม texture ใหม่ลงใน slot
		dragged_item = null  # รีเซ็ตการลาก
