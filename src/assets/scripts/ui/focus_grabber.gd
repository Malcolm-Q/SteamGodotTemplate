extends HSlider

@export var _focused : bool = false
var loaded : bool = false
@export var affected_text : RichTextLabel


func _ready() -> void:
	focus_entered.connect(_on_focus_entered)
	mouse_entered.connect(_on_focus_entered)
	SignalBus.ui_focus_changed.connect(_remove_marker)

func _enter_tree() -> void:
	if _focused and loaded:
		grab_focus()
	loaded = true

func _on_focus_entered() -> void:
	SignalBus.ui_focus_changed.emit()
	affected_text.text[0] = ">"

func _remove_marker() -> void:
	affected_text.text[0] = " "
