extends Panel

signal slot_clicked(number: int)

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label

var slot_data: Invslot

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func update(slot: Invslot):
	slot_data = slot
	if !slot.item:
		item_visual.visible = false
		amount_text.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
		if slot.amount > 1:
			amount_text.visible = true
		amount_text.text = str(slot.amount)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if slot_data.item != null:
			# ตัวอย่าง: ถ้า item.name เป็น "ปุ่มหมายเลข 1"
			if slot_data.item.name.begins_with("ปุ่มหมายเลข "):
				var num = int(slot_data.item.name.replace("ปุ่มหมายเลข ", ""))
				emit_signal("slot_clicked", num)
				print("คลิกที่ Panel ที่มี","ปุ่มหมายเลข ",num)
