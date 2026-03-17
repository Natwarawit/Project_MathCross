extends Control 

@onready var mode = $".."
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
var time_remaining = 60  # เวลาทั้งหมดเริ่มต้นที่ 60 วินาที
var time_bonus = 5  # โบนัสเวลา 5 วินาที
var score = 0
var correct_answers = 0
var combo_bonus = 10  # คะแนนคอมโบสำหรับการตอบถูกต่อเนื่อง
var power_up_threshold = 50  # คะแนนที่ต้องการเพื่อใช้พลังพิเศษ
var hints_available = 80  # จำนวนคำใบ้ที่ใช้ได้
var freeze_available = 3  # จำนวนคำใบ้ที่ใช้ได้
var previous_selected_number = null
var last_pressed_button = null
var timer_running = true  # ตัวแปรเพื่อตรวจสอบว่าสตาร์ทเวลาทำงานอยู่หรือไม่

var grid = [
	[['','','',null,'','','','',''],
	 [6,'*',null,'=',18,'','','',''],
	 ['/','','',1,'',null,'','',''],
	 [null,'','','+','','-','','',''],
	 ['=','','',null,'/',4,'=',2,''],
	 [3,'','','','','=','','+',''],
	 ['',null,'-',13,'=',9,'',null,''],
	 ['','','','','','','','=',''],
	 ['','','','','','','',7,'']]
	,
	[[''   ,''   ,''   ,''   ,32  ,''   ,''   ,''   ,''     ],
	 [''   ,''   ,''   ,''   ,'/'  ,''   ,''   ,''   ,''     ],
	 [null   ,'-'   ,15  ,'='   ,null  ,''   ,''   ,''   ,''     ],
	 [''   ,''   ,'='   ,''   ,'='   ,''   ,''   ,''   ,''     ],
	 [''   ,''   ,8  ,''   ,16  ,'/'   ,null   ,'='   ,2      ],
	 [''   ,''   ,'+'   ,''   ,''   ,''   ,'='   ,''   ,''    ],
	 [''   ,''   ,null   ,'='   ,null  ,'+'   ,1   ,''   ,''     ],
	 [''   ,''   ,''   ,''   ,''   ,''   ,'+'   ,''   ,''   ],
	 [''   ,''   ,''   ,''   ,''   ,''   ,null   ,''   ,''   ]]
	,
]
# ตัวเลือกตัวเลขที่ผู้เล่นสามารถเลือกได้
var choices = [[5,3,2,13,8,22,9],[7,6,8,7,2,17],

]

# ฟังก์ชันที่เรียกเมื่อเริ่มต้น
func _ready():
	start_timer()
	timerlabel.text = str(time_remaining)  # แสดงเวลาที่เหลือเริ่มต้น
	switch_to_next_grid()  # สลับไปยังตารางถัดไปแบบสุ่ม
	hint_button.connect("pressed", Callable(self, "_on_hint_button_pressed"))  # เชื่อมต่อสัญญาณปุ่มคำใบ้
	next_grid_button.connect("pressed", Callable(self, "switch_to_next_grid"))  # เชื่อมต่อการเปลี่ยน grid
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	next_grid_button.hide()  # ซ่อนปุ่มเริ่มต้น

# ฟังก์ชันตั้งค่าตาราง
func set_up_grid() -> void:
	for child in grid_container.get_children():
		child.queue_free()  # ลบเด็กในคอนเทนเนอร์

	for row in range(grid[current_grid_index].size()):
		var row_container = HBoxContainer.new()  # สร้างคอนเทนเนอร์สำหรับแถว
		for col in range(grid[current_grid_index][row].size()):
			var value = grid[current_grid_index][row][col]
			var btn = Button.new()  # สร้างปุ่มใหม่
			btn.modulate = Color(0.5, 0.7, 1)  # เปลี่ยนสีปุ่ม

			if value != null:
				btn.text = str(value)  # ตั้งค่าข้อความของปุ่ม
				if value in ['+','-','*','/','=']:
					btn.modulate = Color(1, 1, 0)  # เปลี่ยนสีถ้าเป็น + หรือ =
				elif btn.text == "":
					btn.disabled = true  # ปิดการใช้งานถ้าเป็นปุ่มว่าง
			else:
				btn.connect("pressed", Callable(self, "_on_grid_button_pressed").bind(row, col, btn))  # เชื่อมต่อการกดปุ่ม
				btn.modulate = Color(0, 2, 0)  # เปลี่ยนสีสำหรับปุ่มว่าง

			btn.custom_minimum_size = Vector2(45, 45)  # ขนาดขั้นต่ำของปุ่ม
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
		btn.modulate = Color(0, 0, 1)  # เปลี่ยนสีของปุ่มตัวเลือก
		choices_container.add_child(btn)  # เพิ่มปุ่มในคอนเทนเนอร์ตัวเลือก

func _on_choice_button_pressed(choice, btn):
	selected_number = choice  # ตั้งค่าตัวเลขที่เลือก
	
	if last_pressed_button != null:
		last_pressed_button.modulate = Color(0, 0, 1)  # เปลี่ยนสีปุ่มกลับเป็นปกติ
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
			add_time_bonus()  # เพิ่มโบนัสเวลาเมื่อทำคำตอบถูก
			track_combo()  # ตรวจสอบคอมโบ
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
		[[1,0,2,18],[4,3,5,2],[6,1,3,9]],  # กริดที่ 1
		[[2,0,2,2],[4,4,6,2],[6,4,6,7]],
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
		[[0,1,3,3],[3,2,4,9],[5,2,4,9],[7,4,6,7]],  # กริดที่ 1
		[[2,4,6,15],[4,0,2,16],[6,6,8,8]]
		
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

# ฟังก์ชันเริ่มต้นนับเวลา
func start_timer():
	time_remaining = 60  # เริ่มต้นเวลาที่ 60 วินาที
	timerlabel.text = "เวลาคงเหลือ : " + str(time_remaining)  # แสดงเวลาที่เหลือใน label

	while time_remaining > 0:  # เช็คว่าเวลายังเหลืออยู่
		await get_tree().create_timer(1).timeout  # รอ 1 วินาที

		if timer_running:  # ตรวจสอบว่าสถานะของ timer_running เป็นจริง
			time_remaining -= 1  # ลดเวลาที่เหลือ
			timerlabel.text = "เวลาคงเหลือ : " + str(time_remaining)  # อัปเดตข้อความใน Label

	if time_remaining <= 0:
		end_game()  # จบเกมเมื่อเวลาเหลือ 0
	
func reset_timer():
	time_remaining = 60  # เริ่มต้นเวลาที่ 60 วินาที
	timerlabel.text = "เวลาคงเหลือ : " + str(time_remaining)  # แสดงเวลาที่เหลือ

func _on_freeze_time_pressed():
	if freeze_available > 0 and timer_running:  # เช็คว่ามี freeze และ timer กำลังทำงาน
		freeze_available -= 1  # ลดจำนวน freeze
		timer_running = false  # เปลี่ยนสถานะให้ไม่ทำงาน
		timerlabel.text = "Time frozen!"  # อัปเดตข้อความบน label
		await get_tree().create_timer(10).timeout  # รอ 10 วินาที
		timer_running = true  # เปลี่ยนสถานะให้ทำงานต่อ
		timerlabel.text = "Time resumed!"  # อัปเดตข้อความเมื่อเริ่มต้นใหม่

func add_time_bonus():
	time_remaining += time_bonus

func track_combo():
	correct_answers += 1
	if correct_answers % 3 == 0:  # ทุกครั้งที่ตอบถูก 3 ข้อ
		score += combo_bonus
		print("Combo! Score: ", score)

# ฟังก์ชันที่เรียกเมื่อกดปุ่มคำใบ้
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
	if all_cells_in_column_filled(col) and check_vertical():
		if has_active_in_column(col):
			disable_buttons_in_column(col)  # ปิดปุ่มในคอลัมน์ที่ตรงตามเงื่อนไข

# ฟังก์ชันแสดงข้อความชนะ
func show_victory_message():
	var victory_label = Label.new()  # สร้าง Label ใหม่
	victory_label.text = "You Win!"  # ตั้งข้อความ
	victory_label.modulate = Color(0, 1, 0)  # เปลี่ยนสีข้อความ
	add_child(victory_label)  # เพิ่ม Label ใน Scene
	next_grid_button.show()  # แสดงปุ่มไปยังกริดถัดไป

	# รอ 5 วินาที ก่อนที่จะลบ Label
	await get_tree().create_timer(3).timeout
	victory_label.queue_free()  # ลบ Label

# ฟังก์ชันแสดงข้อความแพ้
func show_loss_message():
	var loss_label = Label.new()  # สร้าง Label ใหม่
	loss_label.text = "You Lose!"  # ตั้งข้อความ
	loss_label.modulate = Color(1, 0, 0)  # เปลี่ยนสีข้อความ
	add_child(loss_label)  # เพิ่ม Label ใน Scene

	# รอ 5 วินาที ก่อนที่จะลบ Label
	await get_tree().create_timer(3).timeout
	loss_label.queue_free()  # ลบ Label

# ฟังก์ชันแสดงข้อความไม่ถูกต้อง
func show_incorrect():
	var incorrect_label = Label.new()  # สร้าง Label ใหม่
	incorrect_label.text = "Incorrect"  # ตั้งข้อความ
	incorrect_label.modulate = Color(1, 0, 0)  # เปลี่ยนสีข้อความ
	add_child(incorrect_label)  # เพิ่ม Label ใน Scene

	# รอ 1 วินาที ก่อนที่จะลบ Label
	await get_tree().create_timer(1).timeout
	incorrect_label.queue_free()  # ลบ Label

# ฟังก์ชันแสดงข้อความคำใบ้
func show_hint_message(msg: String) -> void:
	var hint_label = Label.new()  # สร้าง Label ใหม่
	hint_label.text = msg  # ตั้งข้อความ
	hint_label.modulate = Color(1, 1, 0)  # เปลี่ยนสีข้อความ
	add_child(hint_label)  # เพิ่ม Label ใน Scene
	await get_tree().create_timer(3).timeout
	hint_label.queue_free()

func show_completion_message():
	var completion_label = Label.new()
	completion_label.text = "Congratulations! You completed all grids!"
	completion_label.modulate = Color(0, 1, 0)
	add_child(completion_label)
	GameManager.unlocked_modes["normal"] = true


# ฟังก์ชันเปลี่ยนไปยัง grid ถัดไป
func switch_to_next_grid():
	if used_grid_indexes.size() == grid.size():
		show_completion_message()  # ถ้าตารางหมดแล้ว
		return
	
	# สุ่มตารางใหม่ที่ยังไม่ถูกใช้
	var random_index = randi() % grid.size()
	while random_index in used_grid_indexes:
		random_index = randi() % grid.size()
	
	current_grid_index = random_index
	used_grid_indexes.append(current_grid_index)
	
	set_up_grid()  # ตั้งค่าตารางใหม่
	set_up_choices()  # ตั้งค่าตัวเลือกใหม่
	reset_timer()
	next_grid_button.hide()

func _on_back_button_pressed():
	if used_grid_indexes.size() == grid.size():
		# If all grids are completed, go back to the story
		get_tree().change_scene_to_file("res://tscn/EndNormalStory.tscn")  # Change to the story scene
	else:
		# If not all grids are completed, go back to the mode selection
		get_tree().change_scene_to_file("res://tscn/Mode.tscn")

func end_game():
	print("Game Over!")


func _on_setting_button_pressed():
	setting.show()
