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
