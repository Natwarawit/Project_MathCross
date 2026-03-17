extends TextureButton

@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var timer: Timer = $Timer
@onready var time: Label = $Time
@onready var key_label: Label = $Key

signal cast(spell_name)

func _ready():
	progress_bar.max_value = timer.wait_time
	set_process(false)

func apply_shortcut(event: InputEventKey, display_text: String) -> void:
	key_label.text = display_text

	var sc := Shortcut.new()
	sc.events = [event]
	shortcut = sc   # <- ของ BaseButton ใช้ได้ปกติ

func _process(_delta: float) -> void:
	time.text = "%3.1f" % timer.time_left
	progress_bar.value = timer.time_left

func _on_pressed() -> void:
	timer.start()
	disabled = true
	set_process(true)
	cast.emit(name)

func _on_timer_timeout() -> void:
	disabled = false
	time.text = ""
	set_process(false)
