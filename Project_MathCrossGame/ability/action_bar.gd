extends HBoxContainer

func _ready():
	var skills := get_children()

	var key_map = [
		{ "key": KEY_E, "shift": false, "ctrl": false, "text": "E" },
		{ "key": KEY_SPACE, "shift": false, "ctrl": false, "text": "Space" },
	]

	for i in min(skills.size(), key_map.size()):
		var ev := InputEventKey.new()
		ev.keycode = key_map[i].key
		ev.shift_pressed = key_map[i].shift
		ev.ctrl_pressed = key_map[i].ctrl

		skills[i].apply_shortcut(ev, key_map[i].text)
