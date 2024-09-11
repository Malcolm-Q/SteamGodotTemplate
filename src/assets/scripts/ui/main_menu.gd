extends CanvasLayer
class_name UIManager

var current_panel : String = 'start'
var play_select : bool = false
var panels : Dictionary = {}

func _ready() -> void:
	GameManager.main_menu = self
	Steam.join_requested.connect(_on_lobby_join_requested)
	SignalBus.display_error.connect(_display_error)
	$Settings/Apply.pressed.connect(Settings.change_settings)
	for child : Node in get_children():
		if child is UIState:
			panels[child.name.to_lower()] = child
			child.show()
			child.master = self
			if child.name.to_lower() != 'start':
				remove_child(child)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		panels[current_panel].back()

func enter() -> void:
	transition('start')

func _display_error(error : String) -> void:
	transition('error')
	panels['error'].get_node('RichTextLabel').text = '[center]' + error + '[/center]'

func _on_lobby_join_requested(_this_lobby_id: int, _friend_id: int) -> void:
	transition('loading')

func _on_quit() -> void:
	get_tree().quit()

func transition(to: String) -> void:
	play_select = true
	remove_child(panels[current_panel])
	add_child(panels[to])
	panels[to].enter(current_panel)
	current_panel = to

func _set_music(value: float) -> void:
	Settings.music_vol = value

func _set_sfx(value: float) -> void:
	Settings.sfx_vol = value

func _set_fps() -> void:
	Settings.iterate_fps()
	$Settings/options/FPS.text = '>FPS TARGET :  ' + 'UNLIMITED' if Settings.fps == 0 else str(Settings.fps)

func _set_vsync() -> void:
	Settings.iterate_vsync()
	$Settings/options/VSync.text = '>VSYNC      :  ' + Settings.vsync_modes[Settings.vsync]

func _toggle_fullscreen() -> void:
	Settings.fullscreen = !Settings.fullscreen
	$Settings/options/Fullscreen.text = '>WINDOW     :  ' + ('FULLSCREEN' if Settings.fullscreen else 'WINDOWED')

func _on_join_lan() -> void:
	transition('loading')
	NetworkManager._on_join_lan()

func _on_host(lan : bool) -> void:
	transition('loading')
	if lan:
		NetworkManager._on_host_lan()
	else:
		NetworkManager._on_host_steam()

func _on_mouse_sensitivity(value:float) -> void:
	Settings.mouse_sensitivity = value
