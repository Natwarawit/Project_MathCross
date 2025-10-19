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
