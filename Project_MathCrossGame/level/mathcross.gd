extends Control

signal mathcross_completed(incorrect_count)

# ==================================================
# Resource
# ==================================================
@onready var inv: Inv = preload("res://inventory/playerinv.tres")

# ==================================================
# Nodes
# ==================================================
@onready var grid_container = $GridContainer
@onready var choices_container = $ChoiceContainer
@onready var hint_button = $HintButton
@onready var next_grid_button = $NextGridButton
@onready var back_button = $BackButton
@onready var setting = $Setting

# ==================================================
# Export
# ==================================================
@export var qid = 0

# ==================================================
# Variables
# ==================================================
var grid = []
var choices = []
var check_for_horizontal = []
var check_for_vertical = []
var correct_answer = []
var used_grid_indexes = []
var selected_number = null
var previous_selected_number = null
var last_pressed_button = null
var timer_running = true
var current_grid_index = 0
var incorrect_count := 0
# ==================================================
# Lifecycle
# ==================================================
func _ready():
	for i in range(1, 100):
		correct_answer.append(i)
	print(correct_answer)
	
	switch_to_next_grid()
	
	$ImportQuestion.request("https://raw.githubusercontent.com/Natwarawit9025/mathcross/refs/heads/main/data/level"+ str(qid) +".json")
	$ImportChoice.request("https://raw.githubusercontent.com/Natwarawit9025/mathcross/refs/heads/main/data/choice.json")
	$ImportCheckHorizontal.request("https://raw.githubusercontent.com/Natwarawit9025/mathcross/refs/heads/main/horizontal/check_horizontal"+ str(qid) +".json")
	$ImportCheckVertical.request("https://raw.githubusercontent.com/Natwarawit9025/mathcross/refs/heads/main/vertical/check_vertical"+ str(qid) +".json")

# ==================================================
# Grid/Choice Setup
# ==================================================
func set_up_grid():
	for child in grid_container.get_children():
		child.queue_free()

	for row in range(grid[current_grid_index].size()):
		var row_container = HBoxContainer.new() 
		for col in range(grid[current_grid_index][row].size()):
			var value = grid[current_grid_index][row][col]
			var btn = Button.new()
			btn.focus_mode = Control.FOCUS_NONE
			btn.mouse_filter = Control.MOUSE_FILTER_STOP
			btn.modulate = Color(0.3, 0.8, 1.0)

			if value != null:
				btn.text = str(value)
				if typeof(value) != TYPE_STRING:
					btn.text = str(int(value))
				elif value in ["+","-","*","/","="]:
					btn.modulate = Color(1, 1, 0) 
				elif btn.text == "":
					btn.disabled = true
			else:
				btn.connect("pressed", Callable(self, "_on_grid_button_pressed").bind(row, col, btn))
				btn.modulate = Color(0.4, 1.5, 1.0)

			btn.custom_minimum_size = Vector2(50, 50)
			row_container.add_child(btn)
		grid_container.add_child(row_container)

func set_up_choices():
	for child in choices_container.get_children():
		child.queue_free()
	for choice in choices[0]:
		var btn = Button.new()
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_default_cursor_shape = Control.CURSOR_ARROW
		btn.text = str(choice)
		btn.connect("pressed", Callable(self, "_on_choice_button_pressed").bind(choice, btn))
		choices_container.add_child(btn)

# ==================================================
# Input Grid/Choice
# ==================================================
func _on_grid_button_pressed(row, col, btn):
	# ===============================
	# กรณีวางตัวเลขใหม่
	# ===============================
	if selected_number != null and grid[current_grid_index][row][col] == null:
		grid[current_grid_index][row][col] = selected_number
		btn.text = str(selected_number)
		set_up_choices()

		# ---------- ตรวจผิดทันที ----------
		if is_move_wrong(row, col):
			btn.modulate = Color(1, 0, 0)
			show_incorrect()
			return
		else:
			btn.modulate = Color(0, 1, 0)
			check_and_disable_buttons(row, col)

		# ---------- ตรวจว่ากรอกครบหรือยัง ----------
		if all_cells_filled():
			if check_win_condition():
				show_correct()

				# ⭐ เปลี่ยนทุกปุ่มเป็นสีเขียว
				mark_all_buttons_correct()

				# ---------- กริดสุดท้าย ----------
				if used_grid_indexes.size() + 1 >= grid.size():
					show_victory_message()
				else:
					await get_tree().create_timer(1.0).timeout
					switch_to_next_grid()
			else:
				show_loss_message()


	elif grid[current_grid_index][row][col] != null:
		var value = grid[current_grid_index][row][col]

		if is_valid_move(row, col):
			grid[current_grid_index][row][col] = null
			btn.text = ""
			btn.modulate = Color(0, 2, 0)
			$"../player/Inv_UI2".add_choice_to_inventory(value)

			if not (value in choices[0]):
				choices[0].append(value)
				choices[0].sort()

			set_up_choices()
			check_and_disable_buttons(row, col)
			print("ตัวเลขถูก ดึงออกโดยไม่ลด coin_fix")

		else:
			if get_coin_fix_count() > 0:
				use_coin_fix()
				grid[current_grid_index][row][col] = null
				btn.text = ""
				btn.modulate = Color(0, 2, 0)
				$"../player/Inv_UI2".add_choice_to_inventory(value)

				set_up_choices()
				check_and_disable_buttons(row, col)
				print("ใช้ coin_fix ดึงคำตอบผิดออก เหลือ:", get_coin_fix_count())
			else:
				print("ไม่มี coin_fix เหลือ ดึงออกไม่ได้")
				btn.modulate = Color(1, 0, 0) 

func _on_choice_button_pressed(choice, btn):
	selected_number = choice 
	
	if last_pressed_button != null:
		last_pressed_button.modulate = Color(0, 1, 0)
		last_pressed_button.disabled = false 
	
	btn.disabled = true
	btn.modulate = Color(1, 1, 1)
	last_pressed_button = btn
	
	if !check_correct(selected_number):
		btn.modulate = Color(1, 0, 0)
	else:
		btn.modulate = Color(0, 1, 0)

func select_choice(choice: int) -> void:
	if choice in choices[0]:
		selected_number = choice  # ตั้งค่าตัวเลขที่เลือก
		# อัปเดตการแสดงผลของตัวเลือก
		for btn in choices_container.get_children():
			if btn.text == str(selected_number):
				btn.disabled = true  # ปิดการใช้งานปุ่มที่เลือก
				btn.modulate = Color(0.3, 0.8, 1.0)  # เปลี่ยนสีของปุ่มที่เลือก
			else:
				btn.disabled = false  # เปิดการใช้งานปุ่มที่เหลือ
				btn.modulate = Color(0.3, 0.8, 1.0)  # เปลี่ยนสีปุ่มกลับเป็นปกติ

# ==================================================
# Inventory 
# ==================================================
func get_coin_fix_count():
	var inv_ui = $"../player/Inv_UI2"
	if inv_ui == null:
		print("❌ ไม่พบ Inv_UI")
		return 0
	
	for invslot in inv_ui.inv_misc.slots:
		if invslot != null and invslot.item != null and invslot.item.name == "coin_fix":
			return invslot.amount
	return 0

func use_coin_fix():
	var inv_ui = $"../player/Inv_UI2" 
	if inv_ui == null:
		print("❌ ไม่พบ Inv_UI")
		return false

	var count = get_coin_fix_count()
	if count > 0:
		inv_ui.remove_item_from_inventory_misc("coin_fix")
		print("✅ ใช้ coin_fix แล้ว - คงเหลือ:", count - 1)
		return true
	else:
		print("❌ ไม่มี coin_fix ให้ใช้")
		return false

# ==================================================
# Validation/Check Logic
# ==================================================

func is_valid_move(row: int, col: int) -> bool:
	if is_move_wrong(row, col):
		return false

	for check in get_horizontal_checks():
		if check[0] == row and not is_horizontal_check_correct(check):
			return false

	for check in get_vertical_checks():
		if check[0] == col and not is_vertical_check_correct(check):
			return false

	return true

func is_move_wrong(row: int, col: int) -> bool:
	for check in get_horizontal_checks():
		if typeof(check) != TYPE_ARRAY:
			continue
		if check.size() == 0:
			continue

		if check[0] == row:
			if all_cells_in_row_filled(row) and not is_horizontal_check_correct(check):
				return true

	for check in get_vertical_checks():
		if typeof(check) != TYPE_ARRAY:
			continue
		if check.size() == 0:
			continue

		if check[0] == col:
			if all_cells_in_column_filled(col) and not is_vertical_check_correct(check):
				return true

	return false

func check_win_condition():
	return check_horizontal() and check_vertical() 

func check_correct(selected_choice):
	return selected_choice in correct_answer

func _calc_match(values: Array, answer: int) -> bool:

	# ===============================
	# กรณี 2 ตัว
	# ===============================
	if values.size() == 2:
		var a = values[0]
		var b = values[1]

		if a + b == answer: return true
		if a - b == answer: return true
		if a * b == answer: return true
		if b != 0 and a / b == answer: return true

	# ===============================
	# กรณี 3 ตัว (เรียง a → b → c)
	# ===============================
	elif values.size() == 3:
		var a = values[0]
		var b = values[1]
		var c = values[2]

		# ---------- บวก / ลบ ----------
		if a + b + c == answer: return true
		if a + b - c == answer: return true
		if a - b + c == answer: return true
		if a - b - c == answer: return true

		# ---------- คูณ ----------
		if a * b * c == answer: return true

		# ---------- (a * b) op c ----------
		if (a * b) + c == answer: return true
		if (a * b) - c == answer: return true
		if c != 0 and (a * b) / c == answer: return true

		# ---------- a op (b * c) ----------
		if a + (b * c) == answer: return true
		if a - (b * c) == answer: return true
		if (b * c) != 0 and a / (b * c) == answer: return true

		# ---------- หาร (เรียงตรง a → b → c) ----------
		if b != 0 and a / b + c == answer: return true
		if b != 0 and a / b - c == answer: return true
		if b != 0 and c != 0 and a / b / c == answer: return true

	return false



# ==================================================
# Horizontal/Vertical Check
# ==================================================
func check_horizontal() -> bool:
	for check in check_for_horizontal[current_grid_index]:

		# ---------- 2 ตัว ----------
		if check.size() == 5:
			var row = check[0]
			var col1 = check[1]
			var col2 = check[2]
			var col_result = check[3]
			var answer = check[4]

			var value1 = grid[current_grid_index][row][col1]
			var value2 = grid[current_grid_index][row][col2]
			var result = grid[current_grid_index][row][col_result]

			if value1 == null or value2 == null or result == null:
				return false

			value1 = int(value1)
			value2 = int(value2)
			result = int(result)

			if not _calc_match([value1, value2], answer) or result != answer:
				print("ผิด:", value1, value2, "=", result, "ควรเป็น", answer)
				return false

		# ---------- 3 ตัว ----------
		elif check.size() == 6:
			var row = check[0]
			var col1 = check[1]
			var col2 = check[2]
			var col3 = check[3]
			var col_result = check[4]
			var answer = check[5]

			var value1 = grid[current_grid_index][row][col1]
			var value2 = grid[current_grid_index][row][col2]
			var value3 = grid[current_grid_index][row][col3]
			var result = grid[current_grid_index][row][col_result]

			if value1 == null or value2 == null or value3 == null or result == null:
				return false

			value1 = int(value1)
			value2 = int(value2)
			value3 = int(value3)
			result = int(result)

			if not _calc_match([value1, value2, value3], answer) or result != answer:
				print("ผิด (3 ตัว):", value1, value2, value3, "=", result)
				return false

	return true

func check_vertical() -> bool:
	for check in check_for_vertical[current_grid_index]:

		if check.size() == 5:
			var col = check[0]
			var row1 = check[1]
			var row2 = check[2]
			var row_result = check[3]
			var answer = check[4]

			var value1 = grid[current_grid_index][row1][col]
			var value2 = grid[current_grid_index][row2][col]
			var result = grid[current_grid_index][row_result][col]

			if value1 == null or value2 == null or result == null:
				return false

			value1 = int(value1)
			value2 = int(value2)
			result = int(result)

			if not _calc_match([value1, value2], answer) or result != answer:
				print("แนวตั้งผิด:", value1, value2, "=", result)
				return false

		elif check.size() == 6:
			var col = check[0]
			var row1 = check[1]
			var row2 = check[2]
			var row3 = check[3]
			var row_result = check[4]
			var answer = check[5]

			var value1 = grid[current_grid_index][row1][col]
			var value2 = grid[current_grid_index][row2][col]
			var value3 = grid[current_grid_index][row3][col]
			var result = grid[current_grid_index][row_result][col]

			if value1 == null or value2 == null or value3 == null or result == null:
				return false

			value1 = int(value1)
			value2 = int(value2)
			value3 = int(value3)
			result = int(result)

			if not _calc_match([value1, value2, value3], answer) or result != answer:
				print("แนวตั้งผิด (3 ตัว):", value1, value2, value3, "=", result)
				return false

	return true

func is_horizontal_check_correct(check: Array) -> bool:
	# ---------- 2 ตัว ----------
	if check.size() == 5:
		var row = check[0]
		var col1 = check[1]
		var col2 = check[2]
		var col_result = check[3]
		var answer = check[4]

		var value1 = grid[current_grid_index][row][col1]
		var value2 = grid[current_grid_index][row][col2]
		var result = grid[current_grid_index][row][col_result]

		if value1 == null or value2 == null or result == null:
			return false

		value1 = int(value1)
		value2 = int(value2)
		result = int(result)

		return _calc_match([value1, value2], answer) and result == answer

	# ---------- 3 ตัว ----------
	elif check.size() == 6:
		var row = check[0]
		var col1 = check[1]
		var col2 = check[2]
		var col3 = check[3]
		var col_result = check[4]
		var answer = check[5]

		var value1 = grid[current_grid_index][row][col1]
		var value2 = grid[current_grid_index][row][col2]
		var value3 = grid[current_grid_index][row][col3]
		var result = grid[current_grid_index][row][col_result]

		if value1 == null or value2 == null or value3 == null or result == null:
			return false

		value1 = int(value1)
		value2 = int(value2)
		value3 = int(value3)
		result = int(result)

		return _calc_match([value1, value2, value3], answer) and result == answer

	return false

func is_vertical_check_correct(check: Array) -> bool:

	# ---------- 2 ตัว ----------
	if check.size() == 5:
		var col = check[0]
		var row1 = check[1]
		var row2 = check[2]
		var row_result = check[3]
		var answer = check[4]

		var value1 = grid[current_grid_index][row1][col]
		var value2 = grid[current_grid_index][row2][col]
		var result = grid[current_grid_index][row_result][col]

		if value1 == null or value2 == null or result == null:
			return false

		value1 = int(value1)
		value2 = int(value2)
		result = int(result)

		return _calc_match([value1, value2], answer) and result == answer

	# ---------- 3 ตัว ----------
	elif check.size() == 6:
		var col = check[0]
		var row1 = check[1]
		var row2 = check[2]
		var row3 = check[3]
		var row_result = check[4]
		var answer = check[5]

		var value1 = grid[current_grid_index][row1][col]
		var value2 = grid[current_grid_index][row2][col]
		var value3 = grid[current_grid_index][row3][col]
		var result = grid[current_grid_index][row_result][col]

		if value1 == null or value2 == null or value3 == null or result == null:
			return false

		value1 = int(value1)
		value2 = int(value2)
		value3 = int(value3)
		result = int(result)

		return _calc_match([value1, value2, value3], answer) and result == answer
	return false

# ==================================================
# Grid State Checking
# ==================================================
func all_cells_filled():
	for row in grid[current_grid_index]:
		for element in row:
			if element == null:
				return false
	return true

func all_cells_in_row_filled(row: int):
	for col in range(grid[current_grid_index][row].size()):
		if grid[current_grid_index][row][col] == null:
			return false
	return true

func all_cells_in_column_filled(col: int):
	for row in range(grid[current_grid_index].size()):
		if grid[current_grid_index][row][col] == null:
			return false
	return true

func mark_all_buttons_correct():
	for row in range(grid_container.get_child_count()):
		var row_container = grid_container.get_child(row)
		for col in range(row_container.get_child_count()):
			var btn = row_container.get_child(col)
			if btn is Button:
				btn.modulate = Color(0, 1, 0)

# ==================================================
# Row / Column Validation Flow
# ==================================================
func check_and_disable_buttons(row: int, col: int):

	# ==============================
	# Horizontal checks
	# ==============================
	for check in get_horizontal_checks():

		# 🔴 กันพัง (สำคัญมาก)
		if typeof(check) != TYPE_ARRAY:
			continue
		if check.size() < 3:
			continue

		if check[0] == row:

			var start_col = check[1]
			var end_col = check[check.size() - 2]

			if is_horizontal_check_correct(check):
				for c in range(start_col, end_col + 1):
					var btn = grid_container.get_child(row).get_child(c)
					if btn is Button:
						btn.modulate = Color(0, 1, 0)
			else:
				for c in range(start_col, end_col + 1):
					var btn = grid_container.get_child(row).get_child(c)
					if btn is Button:
						set_button_color(btn, grid[current_grid_index][row][c])

	# ==============================
	# Vertical checks
	# ==============================
	for check in get_vertical_checks():

		# 🔴 กันพัง
		if typeof(check) != TYPE_ARRAY:
			continue
		if check.size() < 3:
			continue

		if check[0] == col:

			var start_row = check[1]
			var end_row = check[check.size() - 2]

			if is_vertical_check_correct(check):
				for r in range(start_row, end_row + 1):
					var btn = grid_container.get_child(r).get_child(col)
					if btn is Button:
						btn.modulate = Color(0, 1, 0)
			else:
				for r in range(start_row, end_row + 1):
					var btn = grid_container.get_child(r).get_child(col)
					if btn is Button:
						set_button_color(btn, grid[current_grid_index][r][col])


# ==================================================
# Check Data Access
# ==================================================
func get_horizontal_checks():
	return check_for_horizontal[current_grid_index]

func get_vertical_checks():
	return check_for_vertical[current_grid_index]

# ==================================================
# Feedback Messages
# ==================================================
func show_victory_message():
	$Label.text = "ยินดีด้วยคุณชนะแล้ว!"
	$Label.modulate = Color(0, 1, 0)

	# ⭐⭐ จุดเชื่อม Level1 ⭐⭐
	emit_signal("mathcross_completed", incorrect_count)

	await get_tree().create_timer(3).timeout
	$Label.queue_free()
	$"../portal".visible = true

func show_loss_message():
	var loss_label = Label.new()
	loss_label.text = "You Lose!"
	loss_label.modulate = Color(1, 0, 0)
	add_child(loss_label)

	await get_tree().create_timer(3).timeout
	loss_label.queue_free()

func show_incorrect():
	incorrect_count += 1   # ⭐⭐ สำคัญ ⭐⭐

	print("ตอบผิดสะสม =", incorrect_count)

	var incorrect_label = Label.new()
	incorrect_label.text = "คุณตอบไม่ถูก"
	incorrect_label.modulate = Color(1, 0, 0)
	add_child(incorrect_label)

	await get_tree().create_timer(1).timeout
	incorrect_label.queue_free()

func show_correct():
	var correct_label = Label.new()
	correct_label.text = "คุณตอบถูก"
	correct_label.modulate = Color(0, 1, 0)
	add_child(correct_label)

	await get_tree().create_timer(1).timeout
	correct_label.queue_free()

func show_hint_message(msg: String):
	var hint_label = Label.new()
	hint_label.text = msg
	hint_label.modulate = Color(1, 1, 0)
	add_child(hint_label)

	await get_tree().create_timer(3).timeout
	hint_label.queue_free()

func show_completion_message():
	var completion_label = Label.new()
	completion_label.text = "Congratulations! You completed all grids!"
	completion_label.modulate = Color(0, 1, 0)
	add_child(completion_label)

# ==================================================
# Utility
# ==================================================
func set_button_color(btn: Button, value):
	# ถ้าเป็นสีแดงอยู่แล้ว → อย่าเปลี่ยน
	if btn.modulate == Color(1, 0, 0):
		return

	if value == null:
		btn.modulate = Color(0.4, 1.5, 1.0)
	elif value in ["+", "-", "*", "/", "="]:
		btn.modulate = Color(1, 1, 0)
	else:
		btn.modulate = Color(0.3, 0.8, 1.0)

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
		return int(data)
	else:
		return data

# ==================================================
# Grid Control
# ==================================================
func switch_to_next_grid():
	if used_grid_indexes.size() >= grid.size():
		#show_completion_message()
		return

	for i in range(grid.size()):
		if not (i in used_grid_indexes):
			current_grid_index = i+1
			used_grid_indexes.append(i)
			if used_grid_indexes.size() >= grid.size():
				show_victory_message()
			break

	print("Switching to grid index:", current_grid_index)
	await get_tree().create_timer(3.0).timeout
	set_up_grid()
	set_up_choices()

# ==================================================
# HTTP Callbacks
# ==================================================
func _on_http_request_request_completed(result, response_code, headers, body):
	if result == $ImportQuestion.RESULT_SUCCESS and response_code == 200:
		var json_string = body.get_string_from_utf8()
		var parse_result = JSON.parse_string(json_string)
		if parse_result:
			grid = convert_floats_to_int(parse_result)
			print("JSON data loaded:", grid)
			set_up_grid()
			print("Grid size:", grid.size())
			return grid
			
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
