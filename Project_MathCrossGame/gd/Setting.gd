extends Control

@onready var setting = $"."
@onready var buttonSound = $ButtonSound

func _ready():
	setting.visible = false
	
func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(0, value / 5)

func _on_resolutions_item_selected(index):
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2:
			DisplayServer.window_set_size(Vector2i(1440, 900))
		3:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		4:
			DisplayServer.window_set_size(Vector2i(800, 600))


func _on_button_pressed():
	buttonSound.play()
	setting.hide()
	if $"../ControlButton":
		$"../ControlButton".show()
	if $"..":
		$"..".show()
	if $"..":
		$"..".show()
	if $"..":
		$"..".show()

func _on_full_screen_toggled(toggled_on):
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
func _on_mute_check_toggled(toggled_on):
	AudioServer.set_bus_mute(0, toggled_on)
