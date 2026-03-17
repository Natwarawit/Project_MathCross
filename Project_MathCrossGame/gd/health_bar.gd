extends CanvasLayer

var progress_bar: ProgressBar
var value_label: Label

func _ready():
	progress_bar = $ProgressBar
	value_label = $ValueLabel

func _process(delta):
	value_label.text = str(progress_bar.value)
