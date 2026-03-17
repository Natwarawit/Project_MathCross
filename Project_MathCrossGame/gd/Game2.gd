extends Control

# จำนวนโจทย์ที่ต้องการสร้าง
const num_question = 30
var questions = []  #รายการที่จะเก็บโจทย์ทั้งหมด
var current_index = 0  #index ของโจทย์ปัจจุบัน
var score = 0  #คะแนนเริ่มต้น

# ตัวแปรที่เชื่อมต่อกับ UI
@onready var question_label = $QuestionLabel  #Label แสดงข้อความโจทย์
@onready var answer_input = $AnswerInput  #Input สำหรับใส่คำตอบ
@onready var submit_button = $SubmitButton  #ปุ่มสำหรับส่งคำตอบ
@onready var score_label = $ScoreLabel  #Label แสดงคะแนน
@onready var progress_label = $ProgressLabel  #Label แสดงความก้าวหน้า
@onready var feedback_label = $FeedbackLabel  #Label แสดงข้อความตอบกลับ

func _ready():
	randomize()  #เริ่มต้นการสุ่มเลข
	generate_questions()  #สร้างโจทย์ทั้งหมด
	show_question()  #แสดงโจทย์ปัจจุบัน
	
	#เชื่อมต่อสัญญาณของปุ่ม Submit
	submit_button.connect("pressed", Callable(self, "_on_submit_pressed"))

#ฟังก์ชันสุ่มตัวเลข 4 ตัวสำหรับเกม 24
func generate_random_numbers() -> Array:
	var numbers = []
	while numbers.size() < 4:
		var num = randi() % 9 + 1 # สุ่มเลขตั้งแต่ 1 ถึง 9
		if num not in numbers:
			numbers.append(num)
	return numbers

#ฟังก์ชันตรวจสอบว่าสามารถหาผลลัพธ์เป็น 24 ได้หรือไม่
func can_reach_24(numbers: Array) -> bool:
	var ops = ["+", "-", "*", "/"]
	return can_compute_to_24(numbers, ops)

#ฟังก์ชันช่วยในการคำนวณ
func can_compute_to_24(numbers: Array, ops: Array) -> bool:
	if numbers.size() == 1:
		return abs(numbers[0] - 24) < 1e-6

	for i in range(numbers.size()):
		var num1 = numbers[i]
		var new_numbers = numbers.slice(0, i) + numbers.slice(i + 1, numbers.size())
		for j in range(new_numbers.size()):
			var num2 = new_numbers[j]
			var rest_numbers = new_numbers.slice(0, j) + new_numbers.slice(j + 1, new_numbers.size())

			for op in ops:
				var results = []
				if op == "+":
					results.append(num1 + num2)
				elif op == "-":
					results.append(num1 - num2)
					results.append(num2 - num1)
				elif op == "*":
					results.append(num1 * num2)
				elif op == "/":
					if num2 != 0:
						results.append(num1 / num2)
					if num1 != 0:
						results.append(num2 / num1)

				for result in results:
					var new_nums = rest_numbers + [result]
					if can_compute_to_24(new_nums, ops):
						return true

	return false

#ฟังก์ชันสุ่มโจทย์
func generate_question() -> Array:
	var nums = generate_random_numbers()
	while not can_reach_24(nums):
		nums = generate_random_numbers()  #สุ่มใหม่หากไม่ได้ผลลัพธ์ที่ต้องการ
	return nums

#ฟังก์ชันสร้างโจทย์ทั้งหมด
func generate_questions():
	for i in range(num_question):
		questions.append(generate_question())

#ฟังก์ชันแสดงโจทย์ปัจจุบัน
func show_question():
	if current_index < num_question:
		var nums = questions[current_index]
		question_label.text = "Question %d: %s" % [current_index + 1, String(", ").join(nums)]
		answer_input.text = ""
		progress_label.text = "Question %d/%d" % [current_index + 1, num_question]
		feedback_label.text = ""  #ล้างข้อความตอบกลับ
	else:
		end_game()  #จบเกมเมื่อโจทย์หมด

# ฟังก์ชันเมื่อกดปุ่ม Submit
func _on_submit_pressed():
	if current_index >= num_question:
		return
	var user_expression = answer_input.text
	if user_expression == "":
		feedback_label.text = "Please enter your expression."
		return

	#ตรวจสอบคำตอบ
	var is_correct = check_answer(user_expression, questions[current_index])

	if is_correct:
		score += 1
		feedback_label.text = "Correct!"
	else:
		score -= 1
		feedback_label.text = "Incorrect."

	update_score()  #อัปเดตคะแนน
	current_index += 1
	show_question()  #แสดงโจทย์ถัดไป

#ฟังก์ชันอัปเดตคะแนน
func update_score():
	score_label.text = "Score : %d" % score

#ฟังก์ชันสิ้นสุดเกม
func end_game():
	question_label.text = "Game Over!"
	answer_input.editable = false
	answer_input.visible = false
	submit_button.disabled = true
	submit_button.visible = false
	progress_label.text = "You scored %d out of %d" % [score, num_question]
	feedback_label.text = "Thank you for playing!"

#ฟังก์ชันตรวจสอบคำตอบที่ผู้เล่นกรอก
func check_answer(user_expression: String, numbers: Array) -> bool:
	var expression = Expression.new()
	var err = expression.parse(user_expression)

	if err != OK:
		feedback_label.text = "Error in expression syntax."
		return false

	var result = expression.execute()
	if expression.has_execute_failed():
		feedback_label.text = "Error in evaluating expression."
		return false
	#ตรวจสอบว่าผลลัพธ์ที่ได้ใกล้เคียง 24 หรือไม่
	return abs(result - 24) < 1e-6
