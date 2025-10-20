extends Control 

@onready var inv: Inv = preload("res://inventory/playerinv.tres")
@onready var grid_container = $GridContainer
@onready var choices_container = $ChoiceContainer
@onready var hint_button = $HintButton
@onready var next_grid_button = $NextGridButton
@onready var back_button = $BackButton
@onready var setting = $Setting
@export var qid = 0

var correct_answer = []
var current_grid_index = 0
var used_grid_indexes = []
var selected_number = null
var time_remaining = 60 # เวลาทั้งหมดเริ่มต้นที่ 60 วินาที
var time_bonus = 5  # โบนัสเวลา 5 วินาที
var score = 0
var correct_answers = 0
var combo_bonus = 10  
var power_up_threshold = 50 
var hints_available = 80 
var freeze_available = 3 
var previous_selected_number = null
var last_pressed_button = null
var timer_running = true
var grid = []
var choices = []
var check_for_horizontal = []
var check_for_vertical = []

func _ready():
	for i in range(1, 100):  # ใช้ range(start, end) จะเริ่มจาก 1 และไปถึง 99
		correct_answer.append(i)
	print(correct_answer)
	
	switch_to_next_grid()
	$ImportQuestion.request("https://raw.githubusercontent.com/Natwarawit9025/mathcross/refs/heads/main/data/level"+ str(qid) +".json")
	$ImportChoice.request("https://raw.githubusercontent.com/Natwarawit9025/mathcross/refs/heads/main/data/choice"+ str(qid) +".json")
	$ImportCheckHorizontal.request("https://raw.githubusercontent.com/Natwarawit9025/mathcross/refs/heads/main/data/check_horizontal"+ str(qid) +".json")
	$ImportCheckVertical.request("https://raw.githubusercontent.com/Natwarawit9025/mathcross/refs/heads/main/data/check_vertical"+ str(qid) +".json")

func set_up_grid() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	for row in range(grid[current_grid_index].size()):
		var row_container = HBoxContainer.new()  # สร้างคอนเทนเนอร์สำหรับแถว
		for col in range(grid[current_grid_index][row].size()):
			var value = grid[current_grid_index][row][col]
			var btn = Button.new() 
			btn.modulate = Color(0.3, 0.8, 1.0)

			if value != null:
				btn.text = str(value)
				if typeof(value) != TYPE_STRING:
					btn.text = str(int(value))  # ตั้งค่าข้อความของปุ่ม
				elif value in ["+","-","*","/","="]:
					btn.modulate = Color(1, 1, 0)  # เปลี่ยนสีถ้าเป็น + หรือ =:
				elif btn.text == "":
					btn.disabled = true  # ปิดการใช้งานถ้าเป็นปุ่มว่าง
			else:
				btn.connect("pressed", Callable(self, "_on_grid_button_pressed").bind(row, col, btn))  # เชื่อมต่อการกดปุ่ม
				btn.modulate = Color(0.4, 1.5, 1.0)  # เปลี่ยนสีสำหรับปุ่มว่าง

			btn.custom_minimum_size = Vector2(50, 50)  # ขนาดขั้นต่ำของปุ่ม
			row_container.add_child(btn)  # เพิ่มปุ่มในแถว
		grid_container.add_child(row_container)  # เพิ่มแถวในคอนเทนเนอร์หลัก

# ฟังก์ชันตั้งค่าตัวเลือก
func set_up_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()  # ลบเด็กในคอนเทนเนอร์
	for choice in choices[current_grid_index]:
		var btn = Button.new()  # สร้างปุ่มใหม่สำหรับตัวเลือก
		btn.text = str(choice)
		btn.connect("pressed", Callable(self, "_on_choice_button_pressed").bind(choice, btn))  # เชื่อมต่อการกดปุ่ม
		btn.modulate = Color(0.3, 0.8, 1.0)  # เปลี่ยนสีของปุ่มตัวเลือก
		btn.custom_minimum_size = Vector2(70, 70)
		choices_container.add_child(btn)  # เพิ่มปุ่มในคอนเทนเนอร์ตัวเลือก

# ฟังก์ชันเลือกตัวเลือกจากการกดแป้น
func select_choice(choice: int) -> void:
	if choice in choices[current_grid_index]:
		selected_number = choice  # ตั้งค่าตัวเลขที่เลือก
		# อัปเดตการแสดงผลของตัวเลือก
		for btn in choices_container.get_children():
			if btn.text == str(selected_number):
				btn.disabled = true  # ปิดการใช้งานปุ่มที่เลือก
				btn.modulate = Color(0.3, 0.8, 1.0)  # เปลี่ยนสีของปุ่มที่เลือก
			else:
				btn.disabled = false  # เปิดการใช้งานปุ่มที่เหลือ
				btn.modulate = Color(0.3, 0.8, 1.0)  # เปลี่ยนสีปุ่มกลับเป็นปกติ

func _on_choice_button_pressed(choice, btn):
	selected_number = choice  # ตั้งค่าตัวเลขที่เลือก
	
	if last_pressed_button != null:
		last_pressed_button.modulate = Color(0, 1, 0)  # เปลี่ยนสีปุ่มกลับเป็นปกติ
		last_pressed_button.disabled = false  # เปิดการใช้งานปุ่มเดิม
	
	btn.disabled = true  # ปิดการใช้งานปุ่มที่กดล่าสุด
	btn.modulate = Color(1, 1, 1)  # เปลี่ยนสีปุ่มที่กดล่าสุด
	last_pressed_button = btn
	
	if !check_correct(selected_number):  # ถ้าคำตอบไม่ถูกต้อง
		btn.modulate = Color(1, 0, 0)  # เปลี่ยนสีปุ่มเป็นสีแดง
	else:
		btn.modulate = Color(0, 1, 0)  # สีเขียวถ้าคำตอบถูกต้อง

# === ตรวจจำนวน coin_fix ใน inv_misc ===
func get_coin_fix_count() -> int:
	var inv_ui = $"../player/Inv_UI2"# 👈 ตรวจว่า node ชื่อ Inv_UI จริงไหม ถ้าไม่ใช่เปลี่ยนตรงนี้
	if inv_ui == null:
		print("❌ ไม่พบ Inv_UI")
		return 0
	
	# ใช้ inv_misc ในการนับจำนวน coin_fix
	for invslot in inv_ui.inv_misc.slots:
		if invslot != null and invslot.item != null and invslot.item.name == "coin_fix":
			return invslot.amount
	return 0


# === ใช้ coin_fix จาก inv_misc ===
func use_coin_fix() -> bool:
	var inv_ui = $"../player/Inv_UI2"  # 👈 ตรงนี้ด้วย
	if inv_ui == null:
		print("❌ ไม่พบ Inv_UI")
		return false

	var count = get_coin_fix_count()
	if count > 0:
		inv_ui.remove_item_from_inventory_misc("coin_fix")  # ✅ ใช้ฟังก์ชันใน inventory.gd ที่คุณมีอยู่แล้ว
		print("✅ ใช้ coin_fix แล้ว - คงเหลือ:", count - 1)
		return true
	else:
		print("❌ ไม่มี coin_fix ให้ใช้")
		return false

func _on_grid_button_pressed(row, col, btn): 
	# ถ้าวางเลขลงไป
	if selected_number != null and grid[current_grid_index][row][col] == null:
		grid[current_grid_index][row][col] = selected_number
		btn.text = str(selected_number)
		
		choices[current_grid_index].erase(selected_number)
		set_up_choices()

		# ตรวจสอบถูก/ผิด
		if is_valid_move(row, col):
			btn.modulate = Color(0, 1, 0)  # สีเขียวถ้าถูก
			check_and_disable_buttons(row, col)
		else:
			btn.modulate = Color(1, 0, 0)  # สีแดงถ้าผิด

		# เช็คว่าเติมเต็มทุกช่องหรือยัง
		if all_cells_filled():
			if check_win_condition():
				show_correct()
				switch_to_next_grid()
			else:
				show_loss_message()

	# ถ้าช่องนี้มีค่าแล้ว → ดึงออกจากกริด 
	elif grid[current_grid_index][row][col] != null:
		var value = grid[current_grid_index][row][col]

		if is_valid_move(row, col):
			# ตัวเลขถูก → ลบออกปกติ
			grid[current_grid_index][row][col] = null
			btn.text = ""
			btn.modulate = Color(0, 2, 0)  # สีปกติ

			# คืนค่ากลับไปยัง inventory
			$"../player/Inv_UI2".add_choice_to_inventory(value)

			# เพิ่มค่ากลับเข้า choices
			if not (value in choices[current_grid_index]):
				choices[current_grid_index].append(value)
				choices[current_grid_index].sort()

			set_up_choices()
			check_and_disable_buttons(row, col)
			print("ตัวเลขถูก ดึงออกโดยไม่ลด coin_fix")

		else:
			# ตัวเลขผิด → ต้องใช้ coin_fix
			if get_coin_fix_count() > 0:
				use_coin_fix()
				grid[current_grid_index][row][col] = null
				btn.text = ""
				btn.modulate = Color(0, 2, 0)

				$"../player/Inv_UI2".add_choice_to_inventory(value)
				
				if not (value in choices[current_grid_index]):
					choices[current_grid_index].append(value)
					choices[current_grid_index].sort()

				set_up_choices()
				check_and_disable_buttons(row, col)
				print("ใช้ coin_fix ดึงคำตอบผิดออก เหลือ:", get_coin_fix_count())
			else:
				print("ไม่มี coin_fix เหลือ ดึงออกไม่ได้")
				btn.modulate = Color(1, 0, 0)  # ยังคงสีแดง



# ฟังก์ชันตรวจสอบการวางตัวเลข
func is_valid_move(row: int, col: int) -> bool:
	return check_horizontal() and check_vertical()

# ฟังก์ชันตรวจสอบความถูกต้องแนวนอน
func check_horizontal() -> bool:
	var checks = [
		[[1, 0, 2, 28]],  # กริดที่ 1
		[[0, 1, 3, 17], [3, 0, 2, 11]], # กริดที่ 2
		[[0, 3, 5, 7, 16], [3, 0, 2, 4,20]], # กริดที่ 3
	]
	
	for check in check_for_horizontal[current_grid_index]:
		if check.size() < 4:
			continue

		var row = check[0]
		var value1 = grid[current_grid_index][row][check[1]]
		var value2 = grid[current_grid_index][row][check[2]]

		if typeof(value1) == TYPE_STRING: value1 = int(value1)
		if typeof(value2) == TYPE_STRING: value2 = int(value2)

		# ==== กรณีตรวจ 2 ตัว ====
		if check.size() == 4:
			var result = check[3]
			if typeof(result) == TYPE_STRING: result = int(result)
			
			if value1 == null or value2 == null:
				continue

			if not (
				value1 + value2 == result
				or value1 - value2 == result
				or value1 * value2 == result
				or (value2 != 0 and value1 / value2 == result)
			):
				print("แนวนอนผิด:", check, "ค่าที่ใส่:", value1, value2, "ผลที่ต้องได้:", result)
				return false

		# ==== กรณีตรวจ 3 ตัว ====
		elif check.size() == 5:
			var value3 = grid[current_grid_index][row][check[3]]
			var result = check[4]

			if typeof(value3) == TYPE_STRING: value3 = int(value3)
			if typeof(result) == TYPE_STRING: result = int(result)
			
			if value1 == null or value2 == null or value3 == null:
				continue

			if not (
				value1 + value2 + value3 == result
				or value1 - value2 - value3 == result
				or value1 * value2 * value3 == result
				or (value2 != 0 and value3 != 0 and value1 / value2 / value3 == result)
			):
				print("แนวนอนผิดมากกว่า 3:", check, "ค่าที่ใส่:", value1, value2, value3, "ผลที่ต้องได้:", result)
				return false

	return true


func check_vertical() -> bool:
	var checks = [
		[[]],  # กริดที่ 1
		[[1, 2, 4, 7], [3, 0, 2, 13]], # กริดที่ 2
		[[1, 2, 4, 7], [5, 0, 2, 13]], # กริดที่ 3
	]
	
	for check in check_for_vertical[current_grid_index]:
		if check.size() < 4:
			continue

		var col = check[0]
		var row1 = check[1]
		var row2 = check[2]
		var value1 = grid[current_grid_index][row1][col]
		var value2 = grid[current_grid_index][row2][col]

		if typeof(value1) == TYPE_STRING: value1 = int(value1)
		if typeof(value2) == TYPE_STRING: value2 = int(value2)

		# ==== กรณีตรวจ 2 ตัว ====
		if check.size() == 4:
			print(check.size())
			var result = check[3]
			if typeof(result) == TYPE_STRING: result = int(result)

			if value1 == null or value2 == null:
				continue

			if not (
				value1 + value2 == result
				or value1 - value2 == result
				or value1 * value2 == result
				or (value2 != 0 and value1 / value2 == result)
			):
				return false

		# ==== กรณีตรวจ 3 ตัว ====
		elif check.size() == 5:
			var value3 = grid[current_grid_index][check[3]][col]
			var result = check[4]

			if typeof(value3) == TYPE_STRING: value3 = int(value3)
			if typeof(result) == TYPE_STRING: result = int(result)

			if value1 == null or value2 == null or value3 == null:
				continue

			if not (
				value1 + value2 + value3 == result
				or value1 - value2 - value3 == result
				or value1 * value2 * value3 == result
				or (value2 != 0 and value3 != 0 and value1 / value2 / value3 == result)
			):
				return false
	return true

func _on_hint_button_pressed() -> void:
	if hints_available > 0:  # ถ้ามีคำใบ้ที่ใช้ได้
		give_hint()  # ให้คำใบ้
		hints_available -= 1  # ลดจำนวนคำใบ้ที่ใช้ได้
	else:
		show_hint_message("No hints left!")  # แสดงข้อความไม่มีคำใบ้เหลือ

# ฟังก์ชันให้คำใบ้
func give_hint() -> void:
	for choice in choices[current_grid_index]:  # ใช้ current_grid_index
		for row in range(grid[current_grid_index].size()):  # ใช้ current_grid_index
			for col in range(grid[current_grid_index][row].size()):  # ใช้ current_grid_index
				if grid[current_grid_index][row][col] == null:  # ถ้าช่องว่าง
					grid[current_grid_index][row][col] = choice  # ใส่ตัวเลขเป็นคำใบ้
					if check_horizontal() and check_vertical():  # ตรวจสอบความถูกต้อง
						choices[current_grid_index].erase(choice)  # ลบตัวเลือกที่ใช้แล้ว
						set_up_choices()  # อัปเดตตัวเลือก
						set_up_grid()  # อัปเดตตาราง

						if all_cells_filled():
							if check_win_condition():
								show_victory_message()
						return
					else:
						grid[current_grid_index][row][col] = null  # ถ้าผิด ให้คืนค่าช่องว่าง
	show_hint_message("No valid hints available.")  # แสดงข้อความไม่มีคำใบ้ที่ใช้ได้

# ฟังก์ชันตรวจสอบเงื่อนไขชนะ
func check_win_condition() -> bool:
	return check_horizontal() and check_vertical()  # ตรวจสอบเงื่อนไขชนะในแนวนอนและแนวตั้ง

# ฟังก์ชันตรวจสอบว่าแต่ละช่องในกริดเต็มหรือไม่
func all_cells_filled() -> bool:
	for row in grid[current_grid_index]:
		for element in row:
			if element == null:
				return false
	return true

# ฟังก์ชันตรวจสอบว่าแต่ละช่องในแถวเต็มหรือไม่
func all_cells_in_row_filled(row: int) -> bool:
	for col in range(grid[current_grid_index][row].size()):
		if grid[current_grid_index][row][col] == null:
			return false
	return true

# ฟังก์ชันตรวจสอบว่าแต่ละช่องในคอลัมน์เต็มหรือไม่
func all_cells_in_column_filled(col: int) -> bool:
	for row in range(grid[current_grid_index].size()):
		if grid[current_grid_index][row][col] == null:
			return false
	return true

# ฟังก์ชันตรวจสอบว่ามีปุ่มทำงานในแถวหรือไม่
func has_active_in_row(row: int) -> bool:
	for col in range(grid[current_grid_index][row].size()):
		if grid[current_grid_index][row][col] in ['+', '-', '*', '/', '=']:
			return true
	return false

# ฟังก์ชันตรวจสอบว่ามีปุ่มทำงานในคอลัมน์หรือไม่
func has_active_in_column(col: int) -> bool:
	for row in range(grid[current_grid_index].size()):
		if grid[current_grid_index][row][col] in ['+', '-', '*', '/', '=']:
			return true
	return false

# ฟังก์ชันปิดปุ่มในแถวเฉพาะของโจทย์ปัจจุบัน
func disable_buttons_in_row(row: int):
	for col in range(grid[current_grid_index][row].size()):
		if grid[current_grid_index][row][col] != null:
			var btn = grid_container.get_child(row).get_child(col)
			if btn and not btn.disabled:
				btn.disabled = false
				btn.modulate = Color(0, 1, 0)

# ฟังก์ชันปิดปุ่มในคอลัมน์เฉพาะของโจทย์ปัจจุบัน
func disable_buttons_in_column(col: int):
	for row in range(grid[current_grid_index].size()):
		if grid[current_grid_index][row][col] != null:
			var btn = grid_container.get_child(row).get_child(col)
			if btn and not btn.disabled:
				btn.disabled = false
				btn.modulate = Color(0, 1, 0)

func enable_buttons_in_row(row: int): 
	for col in range(grid[current_grid_index][row].size()):
		if grid[current_grid_index][row][col] != null:
			var btn = grid_container.get_child(row).get_child(col)
			if btn and not btn.disabled:
				btn.disabled = false

				# ตรวจสอบว่า cell เป็นเครื่องหมายคณิตศาสตร์ (+, -, *, /, =)
				var value = grid[current_grid_index][row][col]
				if value in ["+", "-", "*", "/", "="]:
					btn.modulate = Color(1, 1, 0)  # เปลี่ยนเป็นสีเหลือง
				else:
					btn.modulate = Color(0.3, 0.8, 1.0)

func enable_buttons_in_column(col: int):
	for row in range(grid[current_grid_index].size()):
		if grid[current_grid_index][row][col] != null:
			var btn = grid_container.get_child(row).get_child(col)
			if btn and not btn.disabled:
				btn.disabled = false

				# ตรวจสอบว่า cell เป็นเครื่องหมายคณิตศาสตร์ (+, -, *, /, =)
				var value = grid[current_grid_index][row][col]
				if value in ["+", "-", "*", "/", "="]:
					btn.modulate = Color(1, 1, 0)  # เปลี่ยนเป็นสีเหลือง
				else:
					btn.modulate = Color(0.3, 0.8, 1.0)


# อัปเดตฟังก์ชัน check_and_disable_buttons
func check_and_disable_buttons(row: int, col: int) -> void:
	# เช็คแนวนอน (ทั้งแถว) และ เช็คแนวตั้ง (ทั้งคอลัมน์)
	if is_row_fully_correct(row):
		if has_active_in_row(row):
			print("ปิดปุ่มแนวนอน row =", row)
			disable_buttons_in_row(row)
			return
	
	elif is_column_fully_correct(col):
		if has_active_in_column(col):
			print("ปิดปุ่มแนวตั้ง col =", col)
			disable_buttons_in_column(col)
			return
	
	#เปิดปุ่มเมื่อไม่มีการแก้ไขคำตอบ
	if has_active_in_row(row):
		enable_buttons_in_row(row)

	elif has_active_in_column(col):
		enable_buttons_in_column(col)

# ==== ตรวจว่าแถวนี้ถูกครบทุกโจทย์ ====
func is_row_fully_correct(row: int) -> bool:
	var has_check := false
	for check in get_horizontal_checks():
		if check[0] == row:
			has_check = true
			if not is_horizontal_check_correct(check):
				return false  # ถ้ามีสักข้อยังไม่ถูก → ห้ามปิด
	return has_check  # ต้องมีโจทย์ และถูกครบ

# ==== ตรวจว่าคอลัมน์นี้ถูกครบทุกโจทย์ ====
func is_column_fully_correct(col: int) -> bool:
	var has_check := false
	for check in get_vertical_checks():
		if check[0] == col:
			has_check = true
			if not is_vertical_check_correct(check):
				return false  # ถ้ามีสักข้อยังไม่ถูก → ห้ามปิด
	return has_check  # ต้องมีโจทย์ และถูกครบ

# ==== ตรวจโจทย์แนวนอนทีละ check ====
func is_horizontal_check_correct(check: Array) -> bool:
	if check.size() == 4:
		# กรณีมี 2 ช่อง (value1 + value2 == result)
		var row = check[0]
		var col1 = check[1]
		var col2 = check[2]
		var result = check[3]
		
		var value1 = grid[current_grid_index][row][col1]
		var value2 = grid[current_grid_index][row][col2]
		
		if value1 == null or value2 == null:
			return false
		
		return (
			value1 + value2 == result
			or value1 - value2 == result
			or value1 * value2 == result
			or (value2 != 0 and value1 / value2 == result)
		)
	
	elif check.size() == 5:
		# กรณีมี 3 ช่อง (value1 + value2 + value3 == result)
		var row = check[0]
		var col1 = check[1]
		var col2 = check[2]
		var col3 = check[3]
		var result = check[4]
		
		var value1 = grid[current_grid_index][row][col1]
		var value2 = grid[current_grid_index][row][col2]
		var value3 = grid[current_grid_index][row][col3]
		
		if value1 == null or value2 == null or value3 == null:
			return false
		
		return (
			value1 + value2 + value3 == result
			or value1 - value2 - value3 == result
			or value1 * value2 * value3 == result
			or (value2 != 0 and value3 != 0 and value1 / value2 / value3 == result)
		)
	
	else:
		return false


# ==== ตรวจโจทย์แนวตั้งทีละ check ====
func is_vertical_check_correct(check: Array) -> bool:
	if check.size() == 4:
		# --- กรณีมี 2 ช่อง (value1 + value2 == result) ---
		var col = check[0]
		var row1 = check[1]
		var row2 = check[2]
		var result = check[3]
		
		var value1 = grid[current_grid_index][row1][col]
		var value2 = grid[current_grid_index][row2][col]
		
		if value1 == null or value2 == null:
			return false
		
		return (
			value1 + value2 == result
			or value1 - value2 == result
			or value1 * value2 == result
			or (value2 != 0 and value1 / value2 == result)
		)
	
	elif check.size() == 5:
		# --- กรณีมี 3 ช่อง (value1 + value2 + value3 == result) ---
		var col = check[0]
		var row1 = check[1]
		var row2 = check[2]
		var row3 = check[3]
		var result = check[4]
		
		var value1 = grid[current_grid_index][row1][col]
		var value2 = grid[current_grid_index][row2][col]
		var value3 = grid[current_grid_index][row3][col]
		
		if value1 == null or value2 == null or value3 == null:
			return false
		
		return (
			value1 + value2 + value3 == result
			or value1 - value2 - value3 == result
			or value1 * value2 * value3 == result
			or (value2 != 0 and value3 != 0 and value1 / value2 / value3 == result)
		)
	
	else:
		return false


# helper: คืนค่าลิสต์โจทย์แนวนอน
func get_horizontal_checks() -> Array:
	return check_for_horizontal[current_grid_index]

# helper: คืนค่าลิสต์โจทย์แนวตั้ง
func get_vertical_checks() -> Array:
	return check_for_vertical[current_grid_index]

# ฟังก์ชันแสดงข้อความชนะ
func show_victory_message():
	var victory_label = Label.new()  # สร้าง Label ใหม่
	victory_label.text = "ยินดีด้วยคุณชนะแล้ว!"  # ตั้งข้อความ
	victory_label.modulate = Color(0, 1, 0)  # เปลี่ยนสีข้อความ
	add_child(victory_label)  # เพิ่ม Label ใน Scene

	# รอ 5 วินาที ก่อนที่จะลบ Label
	await get_tree().create_timer(3).timeout
	victory_label.queue_free()  # ลบ Label
	$"../portal".visible = true

# ฟังก์ชันแสดงข้อความแพ้
func show_loss_message():
	var loss_label = Label.new()  # สร้าง Label ใหม่
	loss_label.text = "You Lose!"  # ตั้งข้อความ
	loss_label.modulate = Color(1, 0, 0)  # เปลี่ยนสีข้อความ
	add_child(loss_label)  # เพิ่ม Label ใน Scene

	# รอ 5 วินาที ก่อนที่จะลบ Label
	await get_tree().create_timer(3).timeout
	loss_label.queue_free()  # ลบ Label

func show_incorrect():
	var incorrect_label = Label.new()  # สร้าง Label ใหม่
	incorrect_label.text = "คุณตอบไม่ถูก"  # ตั้งข้อความ
	incorrect_label.modulate = Color(1, 0, 0)  # เปลี่ยนสีข้อความ
	add_child(incorrect_label)  # เพิ่ม Label ใน Scene

	await get_tree().create_timer(1).timeout
	incorrect_label.queue_free()  # ลบ Label

func show_correct():
	var correct_label = Label.new()  # สร้าง Label ใหม่
	correct_label.text = "คุณตอบถูก"  # ตั้งข้อความ
	correct_label.modulate = Color(0, 1, 0)  # เปลี่ยนสีข้อความ
	add_child(correct_label)  # เพิ่ม Label ใน Scene

	await get_tree().create_timer(1).timeout
	correct_label.queue_free()  # ลบ Label

func check_correct(selected_choice):
	return selected_choice in correct_answer

# ฟังก์ชันแสดงข้อความคำใบ้
func show_hint_message(msg: String) -> void:
	var hint_label = Label.new()  # สร้าง Label ใหม่
	hint_label.text = msg  # ตั้งข้อความ
	hint_label.modulate = Color(1, 1, 0)  
	add_child(hint_label)
	await get_tree().create_timer(3).timeout
	hint_label.queue_free()

func show_completion_message():
	var completion_label = Label.new()
	completion_label.text = "Congratulations! You completed all grids!"
	completion_label.modulate = Color(0, 1, 0)
	add_child(completion_label)
	
# ฟังก์ชัน recursive แปลง float -> int
func convert_floats_to_int(data):
	if data is Array:
		var new_array = []
		for v in data:
			new_array.append(convert_floats_to_int(v))
		return new_array
	elif data is Dictionary:
		var new_dict = {}
		for k in data.keys():
			new_dict[k] = convert_floats_to_int(data[k])
		return new_dict
	elif typeof(data) == TYPE_FLOAT:
		# แปลง float เป็น int
		return int(data)
	else:
		return data

func switch_to_next_grid():
	# ถ้าใช้ครบทุก grid แล้ว
	if used_grid_indexes.size() >= grid.size():
		#show_completion_message()
		return

	for i in range(grid.size()):
		if not (i in used_grid_indexes):
			current_grid_index = i+1
			used_grid_indexes.append(i+1)
			if used_grid_indexes.size() >= grid.size():
				show_victory_message()
			break

	print("Switching to grid index:", current_grid_index)
	await get_tree().create_timer(6.0).timeout
	set_up_grid()
	set_up_choices()

func _on_http_request_request_completed(result, response_code, headers, body):
	if result == $ImportQuestion.RESULT_SUCCESS and response_code == 200:
		var json_string = body.get_string_from_utf8()
		var parse_result = JSON.parse_string(json_string)
		if parse_result:
			grid = convert_floats_to_int(parse_result)
			print("JSON data loaded:", grid)
			set_up_grid()
			print("Grid size:", grid.size()) # ตรวจสอบได้ทันที
			return grid   # <== return ค่า grid ออกไป (แม้ engine จะไม่ใช้ต่อ)
			
	else:
		print("HTTP request failed with code:", response_code)
		return []

func _on_http_request_2_request_completed(result, response_code, headers, body): 
	if result == $ImportChoice.RESULT_SUCCESS and response_code == 200:
		var json_string = body.get_string_from_utf8()
		var parse_result = JSON.parse_string(json_string)
		if parse_result:
			choices = convert_floats_to_int(parse_result)
			print("JSON data loaded:", choices)
			set_up_choices()
			print("Choices size:", choices.size())
			return choices
	else:
		print("HTTP request failed with code:", response_code)
		return []


func _on_import_check_horizontal_request_completed(result, response_code, headers, body):
	if result == $ImportCheckHorizontal.RESULT_SUCCESS and response_code == 200:
		var json_string = body.get_string_from_utf8()
		var parse_result = JSON.parse_string(json_string)
		if parse_result:
			check_for_horizontal = convert_floats_to_int(parse_result)
			print("JSON data loaded:", check_for_horizontal)
			print("Check_Horizontal Size:", check_for_horizontal.size())
			return check_for_horizontal
	else:
		print("HTTP request failed with code:", response_code)
		return []


func _on_import_check_vertical_request_completed(result, response_code, headers, body):
	if result == $ImportCheckVertical.RESULT_SUCCESS and response_code == 200:
		var json_string = body.get_string_from_utf8()
		var parse_result = JSON.parse_string(json_string)
		if parse_result:
			check_for_vertical = convert_floats_to_int(parse_result)
			print("JSON data loaded:", check_for_vertical)
			print("Check_Vertical Size:", check_for_vertical.size())
			return check_for_vertical
	else:
		print("HTTP request failed with code:", response_code)
		return []
