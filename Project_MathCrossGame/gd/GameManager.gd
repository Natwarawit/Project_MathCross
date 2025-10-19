extends Node

# ประกาศสัญญาณสำหรับการเปลี่ยนแปลงอุปกรณ์
signal equipment_changed(equipment_type, item)

# โฟลเดอร์ของอุปกรณ์
var equipment_slots = {
	"hat": null,
	"shirt": null,
	"pants": null,
}

# ฟังก์ชันสำหรับการเปลี่ยนอุปกรณ์
func change_equipment(equipment_type: String, item):
	if equipment_type in equipment_slots:
		equipment_slots[equipment_type] = item
		# ส่งสัญญาณเมื่อมีการเปลี่ยนแปลงอุปกรณ์
		emit_signal("equipment_changed", equipment_type, item)
