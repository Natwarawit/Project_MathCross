extends Control

@onready var game = $"."
@onready var mode_node = $"../Mode"
@onready var mode_answer = $"../Mode/Choice"
@onready var mode_answer2 = $"../Mode/Input"
@onready var question_label = $QuestionLabel
@onready var choice_buttons = [$ButtonA, $ButtonB, $ButtonC, $ButtonD]
@onready var answer_input = $AnswerInput
@onready var submit_button = $SubmitButton
@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel
@onready var time_question_label = $TimeQuestionLabel
@onready var timer = $Timer
@onready var change_mode_button = $ChangeMode
@onready var correct_answer_sound = $"../CorrectAnswerSound"
@onready var incorrect_answer_sound = $"../IncorrectAnswerSound"
@onready var exit_button = $Exit

var current_question
var used_questions = []
var default_mode = "easy"
var default_mode_answer = "choice"
var score = 0
var global_time = 180
var question_time = 30

var correct_answer_sounds = [
	preload("res://sound/luvvoice.com-20240902-as0T.mp3"),
	preload("res://sound/luvvoice.com-20240902-FtMv.mp3"),
	preload("res://sound/luvvoice.com-20240902-i9KV.mp3"),
	preload("res://sound/luvvoice.com-20240902-VoSd.mp3")
]

var incorrect_answer_sounds = [
	preload("res://sound/luvvoice.com-20240902-48T2.mp3"),
	preload("res://sound/luvvoice.com-20240902-et7R.mp3"),
	preload("res://sound/luvvoice.com-20240902-nN1u.mp3"),
	preload("res://sound/luvvoice.com-20240902-x8TY.mp3")
]

var easy_questions_choices = [
	{"question": "71 - 19 = ?", "choices": ["50", "51", "52", "53"], "correct_answer": "52", "type": "multiple_choice"},
	{"question": "25 + 37 = ?", "choices": ["62", "63", "64", "65"], "correct_answer": "62", "type": "multiple_choice"},
	{"question": "48 + 19 = ?", "choices": ["66", "67", "68", "69"], "correct_answer": "67", "type": "multiple_choice"},
	{"question": "56 + 34 = ?", "choices": ["89", "90", "91", "92"], "correct_answer": "90", "type": "multiple_choice"},
	{"question": "72 + 18 = ?", "choices": ["89", "90", "91", "92"], "correct_answer": "90", "type": "multiple_choice"},
	{"question": "81 + 22 = ?", "choices": ["102", "103", "104", "105"], "correct_answer": "103", "type": "multiple_choice"},
	{"question": "34 + 29 = ?", "choices": ["62", "63", "64", "65"], "correct_answer": "63", "type": "multiple_choice"},
	{"question": "27 + 43 = ?", "choices": ["69", "70", "71", "72"], "correct_answer": "70", "type": "multiple_choice"},
	{"question": "63 + 21 = ?", "choices": ["82", "83", "84", "85"], "correct_answer": "84", "type": "multiple_choice"},
	{"question": "91 + 17 = ?", "choices": ["107", "108", "109", "110"], "correct_answer": "108", "type": "multiple_choice"},
	{"question": "52 + 37 = ?", "choices": ["88", "89", "90", "91"], "correct_answer": "89", "type": "multiple_choice"},
	{"question": "83 - 29 = ?", "choices": ["53", "54", "55", "56"], "correct_answer": "54", "type": "multiple_choice"},
	{"question": "92 - 45 = ?", "choices": ["45", "46", "47", "48"], "correct_answer": "47", "type": "multiple_choice"},
	{"question": "67 - 38 = ?", "choices": ["28", "29", "30", "31"], "correct_answer": "29", "type": "multiple_choice"},
	{"question": "79 - 23 = ?", "choices": ["55", "56", "57", "58"], "correct_answer": "56", "type": "multiple_choice"},
	{"question": "64 - 27 = ?", "choices": ["36", "37", "38", "39"], "correct_answer": "37", "type": "multiple_choice"},
	{"question": "80 - 22 = ?", "choices": ["56", "57", "58", "59"], "correct_answer": "58", "type": "multiple_choice"},
	{"question": "90 - 34 = ?", "choices": ["56", "57", "58", "59"], "correct_answer": "56", "type": "multiple_choice"},
	{"question": "71 - 19 = ?", "choices": ["50", "51", "52", "53"], "correct_answer": "52", "type": "multiple_choice"},
	{"question": "99 - 45 = ?", "choices": ["52", "53", "54", "55"], "correct_answer": "54", "type": "multiple_choice"},
	{"question": "60 - 26 = ?", "choices": ["32", "33", "34", "35"], "correct_answer": "34", "type": "multiple_choice"},
	{"question": "12 × 15 = ?", "choices": ["170", "180", "190", "200"], "correct_answer": "180", "type": "multiple_choice"},
	{"question": "23 × 17 = ?", "choices": ["386", "387", "388", "389"], "correct_answer": "391", "type": "multiple_choice"},
	{"question": "8 × 25 = ?", "choices": ["200", "210", "220", "230"], "correct_answer": "200", "type": "multiple_choice"},
	{"question": "14 × 13 = ?", "choices": ["180", "182", "184", "186"], "correct_answer": "182", "type": "multiple_choice"},
	{"question": "19 × 11 = ?", "choices": ["201", "202", "203", "204"], "correct_answer": "209", "type": "multiple_choice"},
	{"question": "7 × 12 = ?", "choices": ["84", "85", "86", "87"], "correct_answer": "84", "type": "multiple_choice"},
	{"question": "5 × 15 = ?", "choices": ["70", "71", "72", "73"], "correct_answer": "75", "type": "multiple_choice"},
	{"question": "9 × 9 = ?", "choices": ["78", "79", "80", "81"], "correct_answer": "81", "type": "multiple_choice"},
	{"question": "11 × 8 = ?", "choices": ["84", "85", "86", "87"], "correct_answer": "88", "type": "multiple_choice"},
	{"question": "6 × 14 = ?", "choices": ["80", "82", "84", "86"], "correct_answer": "84", "type": "multiple_choice"},
	{"question": "144 ÷ 12 = ?", "choices": ["11", "12", "13", "14"], "correct_answer": "12", "type": "multiple_choice"},
	{"question": "96 ÷ 8 = ?", "choices": ["11", "12", "13", "14"], "correct_answer": "12", "type": "multiple_choice"},
	{"question": "81 ÷ 9 = ?", "choices": ["8", "9", "10", "11"], "correct_answer": "9", "type": "multiple_choice"},
	{"question": "72 ÷ 6 = ?", "choices": ["11", "12", "13", "14"], "correct_answer": "12", "type": "multiple_choice"},
	{"question": "56 ÷ 7 = ?", "choices": ["7", "8", "9", "10"], "correct_answer": "8", "type": "multiple_choice"},
	{"question": "100 ÷ 25 = ?", "choices": ["3", "4", "5", "6"], "correct_answer": "4", "type": "multiple_choice"},
	{"question": "36 ÷ 6 = ?", "choices": ["5", "6", "7", "8"], "correct_answer": "6", "type": "multiple_choice"},
	{"question": "72 ÷ 9 = ?", "choices": ["7", "8", "9", "10"], "correct_answer": "8", "type": "multiple_choice"},
	{"question": "54 ÷ 9 = ?", "choices": ["5", "6", "7", "8"], "correct_answer": "6", "type": "multiple_choice"},
	{"question": "81 ÷ 3 = ?", "choices": ["26", "27", "28", "29"], "correct_answer": "27", "type": "multiple_choice"},
	{"question": "3/4 + 2/4 = ?", "choices": ["1/2", "3/4", "5/4", "2"], "correct_answer": "5/4", "type": "multiple_choice"},
	{"question": "5/8 - 1/4 = ?", "choices": ["1/8", "3/8", "5/8", "7/8"], "correct_answer": "3/8", "type": "multiple_choice"},
	{"question": "7/10 × 2/5 = ?", "choices": ["1/2", "7/25", "14/50", "1"], "correct_answer": "7/25", "type": "multiple_choice"},
	{"question": "3/5 ÷ 2/3 = ?", "choices": ["3/5", "1/2", "9/10", "1 1/2"], "correct_answer": "9/10", "type": "multiple_choice"},
	{"question": "1/2 + 3/6 = ?", "choices": ["1/3", "1/2", "5/6", "1"], "correct_answer": "1", "type": "multiple_choice"},
	{"question": "4/5 - 1/5 = ?", "choices": ["2/5", "3/5", "4/5", "5/5"], "correct_answer": "3/5", "type": "multiple_choice"},
	{"question": "2/3 + 1/6 = ?", "choices": ["3/6", "4/6", "5/6", "1"], "correct_answer": "5/6", "type": "multiple_choice"},
	{"question": "1/4 × 3/2 = ?", "choices": ["3/8", "1/2", "3/4", "1"], "correct_answer": "3/8", "type": "multiple_choice"},
	{"question": "5/6 ÷ 1/3 = ?", "choices": ["1", "5/3", "10/6", "5/2"], "correct_answer": "5/2", "type": "multiple_choice"},
	{"question": "7/8 - 1/4 = ?", "choices": ["5/8", "3/4", "7/12", "1"], "correct_answer": "5/8", "type": "multiple_choice"},
	{"question": "√121 = ?", "choices": ["10", "11", "12", "13"], "correct_answer": "11", "type": "multiple_choice"},
	{"question": "√144 = ?", "choices": ["11", "12", "13", "14"], "correct_answer": "12", "type": "multiple_choice"},
	{"question": "√169 = ?", "choices": ["12", "13", "14", "15"], "correct_answer": "13", "type": "multiple_choice"},
	{"question": "√196 = ?", "choices": ["13", "14", "15", "16"], "correct_answer": "14", "type": "multiple_choice"},
	{"question": "√225 = ?", "choices": ["14", "15", "16", "17"], "correct_answer": "15", "type": "multiple_choice"},
	{"question": "√64 = ?", "choices": ["7", "8", "9", "10"], "correct_answer": "8", "type": "multiple_choice"},
	{"question": "√81 = ?", "choices": ["8", "9", "10", "11"], "correct_answer": "9", "type": "multiple_choice"},
	{"question": "√100 = ?", "choices": ["9", "10", "11", "12"], "correct_answer": "10", "type": "multiple_choice"},
	{"question": "√49 = ?", "choices": ["6", "7", "8", "9"], "correct_answer": "7", "type": "multiple_choice"},
	{"question": "√36 = ?", "choices": ["5", "6", "7", "8"], "correct_answer": "6", "type": "multiple_choice"},
	{"question": "45 + (-23) = ?", "choices": ["22", "23", "24", "25"], "correct_answer": "22", "type": "multiple_choice"},
	{"question": "-56 + 32 = ?", "choices": ["-24", "-25", "-26", "-27"], "correct_answer": "-24", "type": "multiple_choice"},
	{"question": "67 - (-18) = ?", "choices": ["85", "86", "87", "88"], "correct_answer": "85", "type": "multiple_choice"},
	{"question": "-45 + (-33) = ?", "choices": ["-75", "-76", "-77", "-78"], "correct_answer": "-78", "type": "multiple_choice"},
	{"question": "98 - (-22) = ?", "choices": ["115", "116", "117", "118"], "correct_answer": "120", "type": "multiple_choice"},
	{"question": "30 + (-15) = ?", "choices": ["12", "13", "14", "15"], "correct_answer": "15", "type": "multiple_choice"},
	{"question": "-24 - 16 = ?", "choices": ["-36", "-38", "-40", "-42"], "correct_answer": "-40", "type": "multiple_choice"},
	{"question": "50 + (-20) = ?", "choices": ["28", "30", "32", "35"], "correct_answer": "30", "type": "multiple_choice"},
	{"question": "-60 + 25 = ?", "choices": ["-34", "-35", "-36", "-37"], "correct_answer": "-35", "type": "multiple_choice"},
	{"question": "80 - (-40) = ?", "choices": ["110", "120", "130", "140"], "correct_answer": "120", "type": "multiple_choice"},
	{"question": "20 + 3 × 4 = ?", "choices": ["32", "33", "34", "35"], "correct_answer": "32", "type": "multiple_choice"},
	{"question": "(15 + 5) × 2 = ?", "choices": ["40", "50", "60", "70"], "correct_answer": "40", "type": "multiple_choice"},
	{"question": "25 ÷ (5 + 5) = ?", "choices": ["2", "3", "4", "5"], "correct_answer": "2", "type": "multiple_choice"},
	{"question": "18 - (6 ÷ 2) = ?", "choices": ["12", "13", "14", "15"], "correct_answer": "15", "type": "multiple_choice"},
	{"question": "(8 + 4) × 3 = ?", "choices": ["30", "32", "34", "36"], "correct_answer": "36", "type": "multiple_choice"},
	{"question": "6 × (4 + 2) = ?", "choices": ["24", "30", "32", "36"], "correct_answer": "36", "type": "multiple_choice"},
	{"question": "15 ÷ (3 + 2) = ?", "choices": ["2", "3", "4", "5"], "correct_answer": "3", "type": "multiple_choice"},
	{"question": "(12 - 4) × 2 = ?", "choices": ["12", "14", "16", "18"], "correct_answer": "16", "type": "multiple_choice"},
	{"question": "9 + (3 × 5) = ?", "choices": ["24", "25", "26", "27"], "correct_answer": "24", "type": "multiple_choice"},
	{"question": "30 ÷ (2 + 3) = ?", "choices": ["5", "6", "7", "8"], "correct_answer": "6", "type": "multiple_choice"}
]

var easy_questions_input = [
	{"question": "8 × __ = 64", "correct_answer": "8", "type": "fill_in"},
	{"question": "15 ÷ __ = 5", "correct_answer": "3", "type": "fill_in"},
	{"question": "__ + 7 = 20", "correct_answer": "13", "type": "fill_in"},
	{"question": "50 - __ = 22", "correct_answer": "28", "type": "fill_in"},
	{"question": "9 × __ = 81", "correct_answer": "9", "type": "fill_in"},
	{"question": "__ ÷ 4 = 12", "correct_answer": "48", "type": "fill_in"},
	{"question": "7 + __ = 19", "correct_answer": "12", "type": "fill_in"},
	{"question": "__ - 14 = 29", "correct_answer": "43", "type": "fill_in"},
	{"question": "36 ÷ __ = 6", "correct_answer": "6", "type": "fill_in"},
	{"question": "__ × 5 = 45", "correct_answer": "9", "type": "fill_in"},
	{"question": "12 × 2 + __ = 30", "correct_answer": "6", "type": "fill_in"},
	{"question": "15 - __ = 7", "correct_answer": "8", "type": "fill_in"},
	{"question": "__ × 3 = 18", "correct_answer": "6", "type": "fill_in"},
	{"question": "7 × 3 = __", "correct_answer": "21", "type": "fill_in"},
	{"question": "__ ÷ 2 = 5", "correct_answer": "10", "type": "fill_in"},
	{"question": "8 × __ = 56", "correct_answer": "7", "type": "fill_in"},
	{"question": "__ - 5 = 10", "correct_answer": "15", "type": "fill_in"},
	{"question": "5 × __ = 30", "correct_answer": "6", "type": "fill_in"},
	{"question": "20 ÷ __ = 4", "correct_answer": "5", "type": "fill_in"},
	{"question": "__ ÷ 4 = 3", "correct_answer": "12", "type": "fill_in"},
	{"question": "14 + __ = 20", "correct_answer": "6", "type": "fill_in"},
	{"question": "12 × __ = 96", "correct_answer": "8", "type": "fill_in"},
	{"question": "30 ÷ __ = 6", "correct_answer": "5", "type": "fill_in"},
	{"question": "7 × __ = 35", "correct_answer": "5", "type": "fill_in"},
	{"question": "__ + 6 = 14", "correct_answer": "8", "type": "fill_in"},
	{"question": "12 ÷ __ = 4", "correct_answer": "3", "type": "fill_in"},
	{"question": "20 ÷ __ = 4", "correct_answer": "5", "type": "fill_in"},
	{"question": "12 × __ = 180", "correct_answer": "15", "type": "fill_in"},
	{"question": "12 × 6 = ___", "correct_answer": "72", "type": "fill_in"},
	{"question": "8 ÷ (2 × 2) = __", "correct_answer": "2", "type": "fill_in"},
	{"question": "__ - (5 ÷ 1) = 7", "correct_answer": "12", "type": "fill_in"},
	{"question": "7 + __ = 12", "correct_answer": "5", "type": "fill_in"},
	{"question": "__ - 9 = 4", "correct_answer": "13", "type": "fill_in"},
	{"question": "√36 + __ = 11", "correct_answer": "5", "type": "fill_in"},
	{"question": "4 × 3 - __ = 10", "correct_answer": "2", "type": "fill_in"},
	{"question": "15 ÷ __ = 3", "correct_answer": "5", "type": "fill_in"},
	{"question": "__ - 1/2 = 1/4", "correct_answer": "3/4", "type": "fill_in"},
	{"question": "√81 = __", "correct_answer": "9", "type": "fill_in"},
	{"question": "-10 + __ = -3", "correct_answer": "7", "type": "fill_in"},
	{"question": "5 × __ = 35", "correct_answer": "7", "type": "fill_in"},
	{"question": "16 ÷ __ = 4", "correct_answer": "4", "type": "fill_in"},
	{"question": "__ + 3/4 = 1", "correct_answer": "1/4", "type": "fill_in"},
	{"question": "√__ = 3", "correct_answer": "9", "type": "fill_in"},
	{"question": "12 - __ = 5", "correct_answer": "7", "type": "fill_in"},
	{"question": "__ × 1/2 = 7/8", "correct_answer": "7/4", "type": "fill_in"},
	{"question": "√__ = 10", "correct_answer": "100", "type": "fill_in"},
	{"question": "-2 + __ = 1", "correct_answer": "3", "type": "fill_in"},
	{"question": "3/4 × __ = 9/16", "correct_answer": "3/4", "type": "fill_in"},
	{"question": "(5 + __) ÷ 2 = 6", "correct_answer": "7", "type": "fill_in"},
	{"question": "7 + __ = 12", "correct_answer": "5", "type": "fill_in"},
	{"question": "__ - 9 = 4", "correct_answer": "13", "type": "fill_in"},
	{"question": "√36 + __ = 11", "correct_answer": "5", "type": "fill_in"},
	{"question": "4 × 3 - __ = 10", "correct_answer": "2", "type": "fill_in"},
	{"question": "15 ÷ __ = 3", "correct_answer": "5", "type": "fill_in"},
	{"question": "__ - 1/2 = 1/4", "correct_answer": "3/4", "type": "fill_in"},
	{"question": "√81 = __", "correct_answer": "9", "type": "fill_in"},
	{"question": "-10 + __ = -3", "correct_answer": "7", "type": "fill_in"},
	{"question": "12 × 2 + __ = 30", "correct_answer": "6", "type": "fill_in"},
	{"question": "15 - __ = 7", "correct_answer": "8", "type": "fill_in"},
	{"question": "__ × 3 = 18", "correct_answer": "6", "type": "fill_in"},
	{"question": "√__ = 5", "correct_answer": "25", "type": "fill_in"},
	{"question": "-6 + __ = -2", "correct_answer": "4", "type": "fill_in"},
	{"question": "8 ÷ (2 × 2) = __", "correct_answer": "2", "type": "fill_in"},
	{"question": "__ - (5 ÷ 1) = 7", "correct_answer": "12", "type": "fill_in"},
	{"question": "7 × 3 = __", "correct_answer": "21", "type": "fill_in"},
	{"question": "__ + 5 = 15", "correct_answer": "10", "type": "fill_in"},
	{"question": "18 ÷ __ = 6", "correct_answer": "3", "type": "fill_in"},
	{"question": "__ - 8 = 7", "correct_answer": "15", "type": "fill_in"},
	{"question": "√__ = 4", "correct_answer": "16", "type": "fill_in"},
	{"question": "__ ÷ 3 = 7", "correct_answer": "21", "type": "fill_in"},
	{"question": "5 + __ = 14", "correct_answer": "9", "type": "fill_in"},
	{"question": "__ - 3 = 11", "correct_answer": "14", "type": "fill_in"},
	{"question": "√49 = __", "correct_answer": "7", "type": "fill_in"},
	{"question": "8 × __ = 64", "correct_answer": "8", "type": "fill_in"},
	{"question": "__ ÷ 4 = 3", "correct_answer": "12", "type": "fill_in"},
	{"question": "14 + __ = 20", "correct_answer": "6", "type": "fill_in"},
	{"question": "5 × __ = 30", "correct_answer": "6", "type": "fill_in"},
	{"question": "__ ÷ 2 = 5", "correct_answer": "10", "type": "fill_in"},
	{"question": "√__ = 7", "correct_answer": "49", "type": "fill_in"},
	{"question": "12 × __ = 96", "correct_answer": "8", "type": "fill_in"},
	{"question": "__ - 5 = 10", "correct_answer": "15", "type": "fill_in"},
	{"question": "20 ÷ __ = 4", "correct_answer": "5", "type": "fill_in"},
	{"question": "__ + 2 = 8", "correct_answer": "6", "type": "fill_in"},
	{"question": "√__ = 25", "correct_answer": "625", "type": "fill_in"},
	{"question": "30 ÷ __ = 6", "correct_answer": "5", "type": "fill_in"},
	{"question": "7 × __ = 35", "correct_answer": "5", "type": "fill_in"},
	{"question": "__ - 9 = 7", "correct_answer": "16", "type": "fill_in"},
	{"question": "8 × __ = 56", "correct_answer": "7", "type": "fill_in"},
	{"question": "__ + 6 = 14", "correct_answer": "8", "type": "fill_in"},
	{"question": "12 ÷ __ = 4", "correct_answer": "3", "type": "fill_in"},
	{"question": "√__ = 81", "correct_answer": "6561", "type": "fill_in"},
	{"question": "15 - __ = 9", "correct_answer": "6", "type": "fill_in"}
]


var normal_questions_choices  = [
	{"question": "2^3 = ?", "choices": ["6", "8", "9", "12"], "correct_answer": "8", "type": "multiple_choice"},
	{"question": "0.75 × 100 = ?", "choices": ["7.5", "75", "750", "0.75"], "correct_answer": "75", "type": "multiple_choice"},
	{"question": "5/8 + 1/4 = ?", "choices": ["3/8", "1/2", "7/8", "1"], "correct_answer": "7/8", "type": "multiple_choice"},
	{"question": "10^2 = ?", "choices": ["10", "20", "100", "1000"], "correct_answer": "100", "type": "multiple_choice"},
	{"question": "1.25 ÷ 0.5 = ?", "choices": ["0.25", "1.5", "2.5", "5"], "correct_answer": "2.5", "type": "multiple_choice"},
	{"question": "3^2 = ?", "choices": ["6", "9", "12", "15"], "correct_answer": "9", "type": "multiple_choice"},
	{"question": "4 × 0.25 = ?", "choices": ["0.1", "0.25", "1", "2"], "correct_answer": "1", "type": "multiple_choice"},
	{"question": "1/2 + 3/4 = ?", "choices": ["1", "1/2", "3/4", "5/4"], "correct_answer": "5/4", "type": "multiple_choice"},
	{"question": "5^3 = ?", "choices": ["25", "75", "125", "150"], "correct_answer": "125", "type": "multiple_choice"},
	{"question": "0.1 × 1000 = ?", "choices": ["10", "100", "0.1", "1000"], "correct_answer": "100", "type": "multiple_choice"},
	{"question": "7/8 - 1/2 = ?", "choices": ["1/8", "3/8", "1/2", "5/8"], "correct_answer": "3/8", "type": "multiple_choice"},
	{"question": "64 ÷ 8 = ?", "choices": ["6", "7", "8", "9"], "correct_answer": "8", "type": "multiple_choice"},
	{"question": "6 × 10^2 = ?", "choices": ["6", "60", "600", "6000"], "correct_answer": "600", "type": "multiple_choice"},
	{"question": "3^4 = ?", "choices": ["9", "27", "81", "243"], "correct_answer": "81", "type": "multiple_choice"},
	{"question": "0.6 ÷ 0.2 = ?", "choices": ["0.3", "2", "3", "4"], "correct_answer": "3", "type": "multiple_choice"},
	{"question": "8 ÷ 2^2 = ?", "choices": ["1", "2", "4", "8"], "correct_answer": "2", "type": "multiple_choice"}

]

var normal_questions_input = [
	{"question": "2^__ = 8", "correct_answer": "3", "type": "fill_in"},
	{"question": "0.5 × __ = 0.25", "correct_answer": "0.5", "type": "fill_in"},
	{"question": "5/8 + __/8 = 1", "correct_answer": "3", "type": "fill_in"},
	{"question": "10^__ = 1000", "correct_answer": "3", "type": "fill_in"},
	{"question": "1.2 ÷ __ = 0.6", "correct_answer": "2", "type": "fill_in"},
	{"question": "4^__ = 64", "correct_answer": "3", "type": "fill_in"},
	{"question": "0.75 ÷ __ = 0.25", "correct_answer": "3", "type": "fill_in"},
	{"question": "3/5 + __/5 = 1", "correct_answer": "2", "type": "fill_in"},
	{"question": "5^__ = 25", "correct_answer": "2", "type": "fill_in"},
	{"question": "2.4 ÷ __ = 1.2", "correct_answer": "2", "type": "fill_in"},
	{"question": "9 ÷ __ = 3", "correct_answer": "3", "type": "fill_in"},
	{"question": "6^__ = 36", "correct_answer": "2", "type": "fill_in"},
	{"question": "0.8 × __ = 0.16", "correct_answer": "0.2", "type": "fill_in"},
	{"question": "2/3 × __ = 1", "correct_answer": "3/2", "type": "fill_in"},
	{"question": "81 ÷ __ = 9", "correct_answer": "9", "type": "fill_in"},
	{"question": "7/4 - __/4 = 1", "correct_answer": "3", "type": "fill_in"},
	{"question": "0.4 ÷ __ = 0.1", "correct_answer": "4", "type": "fill_in"}
]

var hard_questions_choices = [
	{"question": "A ∩ B = ?", "choices": ["เซตว่าง", "A", "B", "A ∪ B"], "correct_answer": "เซตว่าง", "type": "multiple_choice"},
	{"question": "P ∨ Q เป็นจริงเมื่อใด?", "choices": ["P จริง", "Q จริง", "P และ Q จริง", "P หรือ Q จริง"], "correct_answer": "P หรือ Q จริง", "type": "multiple_choice"},
	{"question": "√16 = ?", "choices": ["2", "4", "8", "16"], "correct_answer": "4", "type": "multiple_choice"},
	{"question": "ฟังก์ชันเอกซ์โพเนนเชียลคืออะไร?", "choices": ["f(x) = x^2", "f(x) = e^x", "f(x) = ln(x)", "f(x) = log(x)"], "correct_answer": "f(x) = e^x", "type": "multiple_choice"},
	{"question": "ลิมิตของลำดับ a_n = 1/n เมื่อ n เข้าใกล้อนันต์คืออะไร?", "choices": ["0", "1", "อนันต์", "ไม่มีค่า"], "correct_answer": "0", "type": "multiple_choice"},
	{"question": "A + A' = ?", "choices": ["1", "0", "A", "A'"], "correct_answer": "1", "type": "multiple_choice"},
	{"question": "จำนวนเชิงซ้อน z = 3 + 4i มีค่าสัมบูรณ์เท่ากับเท่าใด?", "choices": ["5", "3", "4", "7"], "correct_answer": "5", "type": "multiple_choice"},
	{"question": "เวกเตอร์ v = (3, 4) มีขนาดเท่ากับเท่าใด?", "choices": ["5", "7", "3", "4"], "correct_answer": "5", "type": "multiple_choice"},
	{"question": "ดีเทอร์มิแนนต์ของเมทริกซ์ 2×2 คืออะไร?", "choices": ["ad-bc", "a+b", "a-b", "ab+cd"], "correct_answer": "ad-bc", "type": "multiple_choice"},
	{"question": "อนุพันธ์ของ f(x) = x^2 คืออะไร?", "choices": ["2x", "x", "x^3", "2x^2"], "correct_answer": "2x", "type": "multiple_choice"}
]

var hard_questions_input = [
	{"question": "ถ้าชุด A = {1, 2, 3} และชุด B = {3, 4, 5} แล้ว A ∩ B มีค่าเท่ากับ __", "correct_answer": "3", "type": "fill_in"},
	{"question": "ผลบวกของพจน์ในลำดับเรขาคณิตที่มีพจน์แรกเป็น 1 และตัวคูณร่วมเป็น 2 ใน 4 พจน์แรกเท่ากับ __", "correct_answer": "15", "type": "fill_in"},
	{"question": "ในสมการ x^2 - 4 = 0 มีรากเท่ากับ __", "correct_answer": "2", "type": "fill_in"},
	{"question": "ถ้าชุด A = {1, 2, 3} และชุด B = {3, 4, 5} แล้ว A ∩ B มีค่าเท่ากับ __", "correct_answer": "3", "type": "fill_in"},
	{"question": "ผลบวกของพจน์ในลำดับเรขาคณิตที่มีพจน์แรกเป็น 1 และตัวคูณร่วมเป็น 2 ใน 4 พจน์แรกเท่ากับ __", "correct_answer": "15", "type": "fill_in"},
	{"question": "ในสมการ x^2 - 4 = 0 มีรากเท่ากับ __", "correct_answer": "2", "type": "fill_in"},
	{"question": "หาก f(x) = 2x + 3 และ f(2) เท่ากับ __", "correct_answer": "7", "type": "fill_in"},
	{"question": "ค่าเอกซ์โพเนนเชียลของ 2^3 มีค่าเท่ากับ __", "correct_answer": "8", "type": "fill_in"},
	{"question": "ในสมการลอการิทึม log(100) มีค่าเท่ากับ __", "correct_answer": "2", "type": "fill_in"},
]



func _ready():
	randomize()
	change_mode_button.hide()
	exit_button.hide()
	reset_timer()
	show_question() 
	set_question()
	start_timer()
	for button in choice_buttons:
		button.connect("pressed", Callable(self, "on_choice_button_pressed").bind(button))
	submit_button.connect("pressed", Callable(self, "on_submit_button_pressed"))
	timer.connect("timeout", Callable(self, "on_question_timeout"))
	change_mode_button.connect("pressed", Callable(self, "on_change_mode_pressed"))
	exit_button.connect("pressed", Callable(self, "on_exit_pressed"))

func start_timer():
	timer.start(1.0)

func reset_timer():
	global_time = 180
	question_time = 30
	update_time_label()
	update_time_question_label()

func set_mode(selected_mode: String):
	default_mode = selected_mode
	default_mode_answer = selected_mode
	score = 0
	global_time = 180
	question_time = 30
	change_mode_button.hide()
	exit_button.hide()
	submit_button.disabled = false
	time_label.show()
	answer_input.text = ""
	reset_timer()
	show_question()
	start_timer()

func set_answer_mode(answer_mode: String):
	default_mode_answer = answer_mode
	show_question()

func set_question():
	if current_question["type"] == "multiple_choice":
		mode_answer.visible = false
		mode_answer2.visible = false
		question_label.text = current_question["question"]
		var choices = current_question["choices"]
		for i in range(4):
			choice_buttons[i].text = choices[i]
			choice_buttons[i].show()
	elif current_question["type"] == "fill_in":
		mode_answer.visible = false
		mode_answer2.visible = false
		question_label.text = current_question["question"]
		answer_input.text = ""

func show_question():
	answer_input.text = ""
	for button in choice_buttons:
		button.hide()

	if default_mode == "easy" and default_mode_answer == "choice":
		var new_question = easy_questions_choices[randi() % easy_questions_choices.size()]
		while new_question in used_questions:
			new_question = easy_questions_choices[randi() % easy_questions_choices.size()]
		current_question = new_question
		answer_input.hide()
		submit_button.hide()
	elif default_mode == "easy" and default_mode_answer == "input":
		var new_question = easy_questions_input[randi() % easy_questions_input.size()]
		while new_question in used_questions:
			new_question = easy_questions_input[randi() % easy_questions_input.size()]
		current_question = new_question
		answer_input.show()
		submit_button.show()
	
	
	elif default_mode == "normal":
		if default_mode_answer == "choice":
			var new_question = normal_questions_choices[randi() % normal_questions_choices.size()]
			while new_question in used_questions:
				new_question = normal_questions_choices[randi() % normal_questions_choices.size()]
			current_question = new_question
			answer_input.hide()
			submit_button.hide()
		elif default_mode_answer == "input":
			var new_question = normal_questions_input[randi() % normal_questions_input.size()]
			while new_question in used_questions:
				new_question = normal_questions_input[randi() % normal_questions_input.size()]
			current_question = new_question
			answer_input.show()
			submit_button.show()

	elif default_mode == "hard":
		if default_mode_answer == "choice":
			var new_question = hard_questions_choices[randi() % hard_questions_choices.size()]
			while new_question in used_questions:
				new_question = hard_questions_choices[randi() % hard_questions_choices.size()]
			current_question = new_question
			answer_input.hide()
			submit_button.hide()
		elif default_mode_answer == "input":
			var new_question = hard_questions_input[randi() % hard_questions_input.size()]
			while new_question in used_questions:
				new_question = hard_questions_input[randi() % hard_questions_input.size()]
			current_question = new_question
			answer_input.show()
			submit_button.show()
	
	
	
	
	
	used_questions.append(current_question)
	set_question()
	question_time = 30
	update_time_question_label()

func update_time_label():
	time_label.text = "เวลาคงเหลือทั้งหมด : %d" % global_time

func update_time_question_label():
	time_question_label.text = "เวลาคงเหลือในการตอบต่อข้อ : %d" % question_time

func update_score():
	score_label.text = "Score : %d" % score

func end_game():
	submit_button.disabled = true
	game.hide()
	mode_node.show()
	score_label.text = "Final Score: %d" % score
	change_mode_button.show()
	exit_button.show()

func on_choice_button_pressed(button: Button):
	var user_answer = button.text
	if user_answer.to_lower() == str(current_question["correct_answer"]).to_lower():
		score += 1
		global_time += 5
		var random = randi() % correct_answer_sounds.size()
		correct_answer_sound.stream = correct_answer_sounds[random]
		correct_answer_sound.play()
	else:
		global_time -= 5
		var random2 = randi() % incorrect_answer_sounds.size()
		incorrect_answer_sound.stream = incorrect_answer_sounds[random2]
		incorrect_answer_sound.play()
		
	if global_time <= 0:
		end_game()
	else:
		update_score()
		show_question()
	update_time_label()
	update_time_question_label()

func on_submit_button_pressed():
	var user_answer = answer_input.text
	if user_answer.strip_edges().to_lower() == str(current_question["correct_answer"]).strip_edges().to_lower():
		score += 1
		global_time += 5
		var random = randi() % correct_answer_sounds.size()
		correct_answer_sound.stream = correct_answer_sounds[random]
		correct_answer_sound.play()
	else:
		global_time -= 5
		var random2 = randi() % incorrect_answer_sounds.size()
		incorrect_answer_sound.stream = incorrect_answer_sounds[random2]
		incorrect_answer_sound.play()
	
	if global_time <= 0:
		end_game()
	else:
		update_score()
		show_question()
	update_time_label()
	update_time_question_label()

func on_question_timeout():
	question_time -= 1
	update_time_question_label()
	if question_time <= 0:
		show_question()
		question_time = 30
		update_time_question_label()
	else:
		global_time -= 1
		update_time_label()
		
	if global_time <= 0:
		end_game()

func on_change_mode_pressed():
	mode_node.show()
	game.hide()
	submit_button.disabled = false
	answer_input.text = ""

func on_exit_pressed():
	get_tree().quit()
