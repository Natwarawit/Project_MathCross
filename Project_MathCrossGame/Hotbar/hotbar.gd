extends Control

@onready var grid = $GridContainer
var current_index := 0

func _ready():
	# 🔹 ปิดการรับเมาส์ของ Hotbar และลูกทั้งหมด
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

	update_selection()

func _process(delta):
	if Input.is_action_just_pressed("switch_weapon"):
		swap_weapon()

func swap_weapon():
	current_index += 1
	if current_index >= grid.get_child_count():
		current_index = 0
	update_selection()

func update_selection():
	# วนทุกปุ่มใน GridContainer
	for i in range(grid.get_child_count()):
		var button = grid.get_child(i)
		# ถ้าเป็นปุ่มที่เลือกอยู่ ให้เปลี่ยนกรอบหรือสไตล์ให้ต่างออกไป
		if i == current_index:
			button.add_theme_stylebox_override("normal", get_highlight_style())
		else:
			button.add_theme_stylebox_override("normal", get_normal_style())

func get_highlight_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.2)
	style.border_color = Color(1, 1, 1)
	style.set_border_width_all(2)
	style.draw_center = true
	style.border_blend = true
	style.content_margin_left = 2
	style.content_margin_top = 2
	style.content_margin_right = 2
	style.content_margin_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

func get_normal_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.5)
	style.border_color = Color(0, 0, 0, 0)
	style.set_border_width_all(2)
	style.draw_center = true
	style.border_blend = true
	style.content_margin_left = 2
	style.content_margin_top = 2
	style.content_margin_right = 2
	style.content_margin_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style
