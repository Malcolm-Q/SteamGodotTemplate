extends Button
@export var _focused : bool = false

func _ready() -> void:
	focus_entered.connect(_on_focus_entered)
	mouse_entered.connect(_on_focus_entered)
	SignalBus.ui_focus_changed.connect(_remove_marker)

func _enter_tree() -> void:
	if _focused:
		grab_focus()

func _on_focus_entered() -> void:
	SignalBus.ui_focus_changed.emit()
	if not text.begins_with(">"):
		text[0] = ">"

func _remove_marker() -> void:
	if text.begins_with(">"):
		text[0] = " "
