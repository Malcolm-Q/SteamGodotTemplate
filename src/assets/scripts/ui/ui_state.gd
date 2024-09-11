extends Panel
class_name UIState

var master : UIManager
var previous_panel : String
@export var can_go_back : bool = true


func enter(previous : String):
	if !previous_panel:
		previous_panel = previous

func back():
	if can_go_back:
		master.transition(previous_panel)
