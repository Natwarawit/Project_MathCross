extends Control 

@onready var grid_container = $GridContainer
@onready var choices_container = $ChoiceContainer
@onready var hint_button = $HintButton
@onready var next_grid_button = $NextGridButton
@onready var back_button = $BackButton
@onready var timerlabel = $TimerLabel
@onready var freeze = $FreezeTime
@onready var setting = $Setting

var current_grid_index = 0
var used_grid_indexes = []
var selected_number = null
var time_remaining = 60 # เวลาทั้งหมดเริ่มต้นที่ 60 วินาที
var time_bonus = 5  # โบนัสเวลา 5 วินาที
var score = 0
var correct_answers = 0
var combo_bonus = 10  # คะแนนคอมโบสำหรับการตอบถูกต่อเนื่อง
var power_up_threshold = 50  # คะแนนที่ต้องการเพื่อใช้พลังพิเศษ
var hints_available = 80 # จำนวนคำใบ้ที่ใช้ได้
var freeze_available = 3  # จำนวนคำใบ้ที่ใช้ได้
var previous_selected_number = null
var last_pressed_button = null
var timer_running = true  # ตัวแปรเพื่อตรวจสอบว่าสตาร์ทเวลาทำงานอยู่หรือไม่

# กำหนดตารางค่าของเกม
var grid = [
	[[14, '+', null, '=', 15],
	 ['', '', '+', '', ''],
	 ['', '', 4, '', ''],
	 ['', '', '=', '', ''],
	 ['', '', 5, '','']]
	,
	[['',null,'+',8,'=',17,''],
	['', '', '', '+', '', '', ''],
	['', 7, '', null, '', '', ''],
	[5, '+', null, '=', 13, '', ''],
	['', 4, '', 13, '', '', ''],
	['', '=', '', '', '', '', ''],
	['', null,'+', 8, '=', null, '']]
	,
	[[17,'+',null,'=',21,'',''],
	 ['+','','=','','=','',''],
	 ['9','',null,'',null,'',''],
	 ['=','','+','','+','',''],
	 [null,'',2,'+',6,'=',null],
	 ['','','','','','',''],
	 ['','','','','','','']]
	,
]

var choices = [[1,2],[17,9,8,9,5],[2,26,8,15,4]]

# ฟังก์ชันที่เรียกเมื่อเริ่มต้น
func _ready():
	switch_to_next_grid()  # สลับไปยังตารางถัดไปแบบสุ่ม
	
# ฟังก์ชันตั้งค่าตาราง
func set_up_grid() -> void:
	for child in grid_container.get_children():
		child.queue_free()  # ลบเด็กในคอนเทนเนอร์

	for row in range(grid[current_grid_index].size()):
		var row_container = HBoxContainer.new()  # สร้างคอนเทนเนอร์สำหรับแถว
		for col in range(grid[current_grid_index][row].size()):
			var value = grid[current_grid_index][row][col]
			var btn = Button.new()  # สร้างปุ่มใหม่
			btn.modulate = Color(0, 1, 0)   # เปลี่ยนสีปุ่ม

			if value != null:
				btn.text = str(value)  # ตั้งค่าข้อความของปุ่ม
				if value in ['+','-','*','/','=']:
					btn.modulate = Color(1, 1, 0)  # เปลี่ยนสีถ้าเป็น + หรือ =
				elif btn.text == "":
					btn.disabled = true  # ปิดการใช้งานถ้าเป็นปุ่มว่าง
			else:
				btn.connect("pressed", Callable(self, "_on_grid_button_pressed").bind(row, col, btn))  # เชื่อมต่อการกดปุ่ม
				btn.modulate = Color(0, 2, 0)  # เปลี่ยนสีสำหรับปุ่มว่าง

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
		btn.modulate = Color(0,1,0)  # เปลี่ยนสีของปุ่มตัวเลือก
		btn.custom_minimum_size = Vector2(70, 70)
		choices_container.add_child(btn)  # เพิ่มปุ่มในคอนเทนเนอร์ตัวเลือก
# ฟังก์ชันตรวจสอบการกดแป้น
func _process(delta):
	for i in range(9):  # ตรวจสอบการกดหมายเลข 1-9
		var action_name = "key_" + str(i + 1)
		if InputMap.has_action(action_name) and Input.is_action_just_pressed(action_name):
			select_choice(i + 1)


# ฟังก์ชันเลือกตัวเลือกจากการกดแป้น
func select_choice(choice: int) -> void:
	if choice in choices[current_grid_index]:
		selected_number = choice  # ตั้งค่าตัวเลขที่เลือก
		update_choice_button_state()  # อัปเดตสถานะของปุ่มที่เลือก

# อัปเดตการแสดงผลของตัวเลือก
func update_choice_button_state():
	for btn in choices_container.get_children():
		if btn.text == str(selected_number):
			btn.disabled = true  # ปิดการใช้งานปุ่มที่เลือก
			btn.modulate = Color(1, 1, 1)  # เปลี่ยนสีของปุ่มที่เลือก
		else:
			btn.disabled = false  # เปิดการใช้งานปุ่มที่เหลือ
			btn.modulate = Color(0, 1, 0)  # เปลี่ยนสีปุ่มกลับเป็นปกติ

func _on_choice_button_pressed(choice, btn):
	selected_number = choice  # ตั้งค่าตัวเลขที่เลือก
	
	if last_pressed_button != null:
		last_pressed_button.modulate = Color(0, 1, 0)  # เปลี่ยนสีปุ่มกลับเป็นปกติ
		last_pressed_button.disabled = false  # เปิดการใช้งานปุ่มเดิม
	
	btn.disabled = true  # ปิดการใช้งานปุ่มที่กดล่าสุด
	btn.modulate = Color(1, 1, 1)  # เปลี่ยนสีปุ่มที่กดล่าสุด
	last_pressed_button = btn

func _on_grid_button_pressed(row, col, btn):
	if selected_number != null and grid[current_grid_index][row][col] == null:
		var previous_selected_number = selected_number  
		grid[current_grid_index][row][col] = selected_number  # ใส่ตัวเลขในช่อง
		btn.text = str(selected_number)
		btn.modulate = Color(0, 1, 0)

		choices[current_grid_index].erase(selected_number)  # ลบตัวเลขที่เลือกจากตัวเลือก
		set_up_choices()  # อัปเดตตัวเลือก

		if is_valid_move(row, col):
			check_and_disable_buttons(row, col)  # ปิดเฉพาะปุ่มนั้นๆ
		else:
			# ถ้าตรวจสอบแล้วไม่ถูกต้อง ให้คืนค่าก่อนหน้า
			grid[current_grid_index][row][col] = null
			btn.text = ""
			btn.disabled = false
			btn.modulate = Color(0, 2, 0)

			choices[current_grid_index].append(previous_selected_number)
			set_up_choices()
			show_incorrect()

		if all_cells_filled():
			if check_win_condition():
				show_victory_message()
			else:
				show_loss_message()

# ฟังก์ชันตรวจสอบการวางตัวเลข
func is_valid_move(row: int, col: int) -> bool:
	return check_horizontal() and check_vertical()

# ฟังก์ชันตรวจสอบความถูกต้องแนวนอน
#check[0]: เลขแถวในกริดที่ต้องการตรวจสอบ
#check[1]: เลขคอลัมน์ที่หนึ่งในแถวที่ต้องการตรวจสอบ
#check[2]: เลขคอลัมน์ที่สองในแถวที่ต้องการตรวจสอบ
#check[3]: ค่าผลรวมที่คาดหวังจากการบวกค่าของสองคอลัมน์นั้น

func check_horizontal() -> bool:
	var checks = [
		[[0, 0, 2, 15]],  # กริดที่ 1
		[[0,1,3,17],[3,0,2,13],[6,1,3,17]], # กริดที่ 2
		[[0,0,2,21],[4,2,4,8]], # กริดที่ 3
	]
	
	for check in checks[current_grid_index]:
		if len(check) < 4:
			continue  # ถ้า check มีขนาดไม่พอให้ข้าม
		var value1 = grid[current_grid_index][check[0]][check[1]]
		var value2 = grid[current_grid_index][check[0]][check[2]]
		var result = check[3]
		
		if value1 is int and value2 is int:
			# ตรวจสอบการบวก
			if value1 + value2 == result:
				continue
			# ตรวจสอบการลบ
			elif value1 - value2 == result:
				continue
			# ตรวจสอบการคูณ
			elif value1 * value2 == result:
				continue
			# ตรวจสอบการหาร (และตรวจสอบว่าไม่หารด้วยศูนย์)
			elif value2 != 0 and value1 / value2 == result:
				continue
			else:
				return false
	return true

# ฟังก์ชันตรวจสอบความถูกต้องแนวตั้ง
#check[0]: เปลี่ยนจากเลขแถวมาเป็นเลขคอลัมน์
#check[1]: เปลี่ยนเป็นเลขแถวที่หนึ่ง
#check[2]: เปลี่ยนเป็นเลขแถวที่สอง
#check[3]: ยังคงเป็นค่าผลรวมที่คาดหวังจากการบวกค่าของแถวทั้งสองในคอลัมน์เดียวกัน
func check_vertical() -> bool:
	var checks = [
		[[0, 0, 2, 5]],  # กริดที่ 1
		[[1,2,4,9],[3,0,2,13]], # กริดที่ 2
		[[0,0,2,26],[2,2,4,4],[4,2,4,21]], # กริดที่ 3
	]
	for check in checks[current_grid_index]:
		if len(check) < 4:
			continue  # ถ้า check มีขนาดไม่พอให้ข้าม
		var value1 = grid[current_grid_index][check[1]][check[0]]
		var value2 = grid[current_grid_index][check[2]][check[0]]
		var result = check[3]
		
		if value1 is int and value2 is int:
			# ตรวจสอบการบวก
			if value1 + value2 == result:
				continue
			# ตรวจสอบการลบ
			elif value1 - value2 == result:
				continue
			# ตรวจสอบการคูณ
			elif value1 * value2 == result:
				continue
			# ตรวจสอบการหาร (และตรวจสอบว่าไม่หารด้วยศูนย์)
			elif value2 != 0 and value1 / value2 == result:
				continue
			else:
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
				btn.disabled = true
				btn.modulate = Color(0.7, 0.7, 0.7)

# ฟังก์ชันปิดปุ่มในคอลัมน์เฉพาะของโจทย์ปัจจุบัน
func disable_buttons_in_column(col: int):
	for row in range(grid[current_grid_index].size()):
		if grid[current_grid_index][row][col] != null:
			var btn = grid_container.get_child(row).get_child(col)
			if btn and not btn.disabled:
				btn.disabled = true
				btn.modulate = Color(0.7, 0.7, 0.7)

# อัปเดตฟังก์ชัน check_and_disable_buttons
func check_and_disable_buttons(row: int, col: int):
	# ตรวจสอบแถว
	if all_cells_in_row_filled(row) and check_horizontal():
		if has_active_in_row(row):
			disable_buttons_in_row(row)  # ปิดปุ่มในแถวที่ตรงตามเงื่อนไข

	# ตรวจสอบคอลัมน์
	if all_cells_in_row_filled(col) and check_vertical():
		if has_active_in_column(col):
			disable_buttons_in_column(col)  # ปิดปุ่มในคอลัมน์ที่ตรงตามเงื่อนไข

# ฟังก์ชันแสดงข้อความชนะ
func show_victory_message():
	var victory_label = Label.new()  # สร้าง Label ใหม่
	victory_label.text = "ยินดีด้วยคุณชนะแล้ว!"  # ตั้งข้อความ
	victory_label.modulate = Color(0, 1, 0)  # เปลี่ยนสีข้อความ
	add_child(victory_label)  # เพิ่ม Label ใน Scene
	

	# รอ 5 วินาที ก่อนที่จะลบ Label
	await get_tree().create_timer(3).timeout
	victory_label.queue_free()  # ลบ Label
	get_tree().change_scene_to_file("res://scenes/rest.tscn")

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

func switch_to_next_grid():
	if used_grid_indexes.size() == grid.size():
		show_completion_message()  # ถ้าตารางหมดแล้ว
		return
	
	# เลือกตารางถัดไปที่ยังไม่ถูกใช้
	for i in range(grid.size()):
		if not (i in used_grid_indexes):
			current_grid_index = i
			used_grid_indexes.append(current_grid_index)
			break
	
	set_up_grid()
	set_up_choices()
