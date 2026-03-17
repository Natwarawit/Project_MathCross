<<<<<<< HEAD
extends Control

var next_scene: String   # ไม่ต้องกำหนดค่าไว้

@onready var progress_bar = $ProgressBar

func _ready():
	if next_scene != "":
		ResourceLoader.load_threaded_request(next_scene)
		
	$AnimatedSprite2D.play("side_walk")
	
func _process(delta):
	if next_scene == "":
		return

	var progress = []
	var status = ResourceLoader.load_threaded_get_status(next_scene, progress)

	if progress.size() > 0:
		progress_bar.value = progress[0] * 100.0

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_scene)
=======
extends Control 

var next_scene: String = "res://scenes/world.tscn"  # ฉากถัดไปที่จะโหลด

@onready var progress_bar = $ProgressBar  # เชื่อมต่อกับ ProgressBar ใน UI

func _ready():
	ResourceLoader.load_threaded_request(next_scene, "")

func _process(delta: float) -> void:
	var progress = []
	
	# เช็คสถานะของการโหลด
	var loaded_status = ResourceLoader.load_threaded_get_status(next_scene, progress)
	var new_progress = progress[0] * 100.0  # แปลงค่าร้อยละจาก 0.0-1.0 เป็น 0-100%

	progress_bar.value = new_progress  # อัปเดตค่าความคืบหน้าใน ProgressBar

	# เมื่อโหลดเสร็จสมบูรณ์
	if loaded_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		var packed_next_scene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_next_scene)  # เปลี่ยนไปยังฉากใหม่
>>>>>>> 4a2b1f7165990c6d3de7e8ec075bbe66b75e40b9
