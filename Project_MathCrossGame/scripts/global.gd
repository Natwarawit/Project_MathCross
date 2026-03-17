extends Node

# ===============================
# Player / Equipment (ของเดิม)
# ===============================
var player_current_attack = false
var player_has_helmet = false 
var player_has_chestplase = false 
var player_has_boots = false
var player_has_sword = false

var helmet_type = ""
var chestplase_type = ""
var boots_type = ""
var sword_type = ""
var last_cleared_stage = -1
var max_health = 100
var max_attack = 0
var max_defense = 0
var max_speed = 0
var carry_coin := 0
var enemy_attacker = null
var saved_coin := 0    # เงินถาวร ข้ามด่าน
var stage_coin := 0    # เงินที่เก็บในด่านปัจจุบัน
var helmet_index := 0
var chestplate_index := 0
var boots_index := 0
var sword_index := 0

# ============================
# ⭐ PLAYER PROGRESS (ถาวรข้ามด่าน)
# ============================

var player_level := 1
var player_exp := 0
var player_exp_to_next := 50

var player_level_attack_bonus := 0
var player_level_def_bonus := 0
var player_level_speed_bonus := 0
var player_level_hp_bonus := 0

var player_initialized := false   # ใช้กัน reset ตอนเข้าเกมครั้งแรก
var pending_chain_unlock := -1
# ===============================
# Mission (ต่อด่าน)
# ===============================
var mission := {
	"q_press": 0,
	"incorrect": 0,
	"cleared": false
}

func reset_mission():
	mission.q_press = 0
	mission.incorrect = 0
	mission.cleared = false


# ===============================
# Progress (ทั้งเกม)
# ===============================
var progress := {
	"stage_clear_count": 0,
	"total_star": 0
}


# ===============================
# Mission Config
# ===============================
var mission_config := {
	"max_q": 3,
	"max_incorrect": 5,
	"min_hp_percent": 75
}
