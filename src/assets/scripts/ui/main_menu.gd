extends CanvasLayer
class_name MainMenu

@onready var state_chart : StateChart = $StateChart
@onready var error_text : RichTextLabel = $Error/RichTextLabel
@onready var settings_controller : SettingsController = $Settings/SettingsController
@onready var sfx : AudioStreamPlayer = $SFX

var current_panel : String = 'title'
var play_select : bool = false
var panels : Dictionary = {}
var lan = false

func _ready() -> void:
	GameManager.main_menu = self
	Steam.join_requested.connect(_on_lobby_join_requested)
	NetworkManager.display_error.connect(_display_error)
	_setup_buttons()
	_setup_state_chart()
	_enforce_visibility()
	$StateChartDebugger.hide()

func _enforce_visibility() -> void:
	$Title.show()
	$Main.hide()
	$LobbyType.hide()
	$HostJoin.hide()
	$Settings.hide()
	$Loading.hide()
	$Error.hide()

func _setup_state_chart() -> void:
	$StateChart/Root.state_input.connect(_main_input)
	$StateChart/Root/Title.state_input.connect(_title_input)
	var state_definitions = [
		# add enter_sound if you want that
		# could also add functionality for anim_string or something
		{ "state": $StateChart/Root/Title, "node": $Title },
		{ "state": $StateChart/Root/Main/Root, "node": $Main },
		{ "state": $StateChart/Root/Main/LobbyType, "node": $LobbyType },
		{ "state": $StateChart/Root/Main/HostJoin, "node": $HostJoin },
		{ "state": $StateChart/Root/Settings, "node": $Settings },
		{ "state": $StateChart/Root/Loading, "node": $Loading },
		{ "state": $StateChart/Root/Error, "node": $Error },
	]
	for s in state_definitions:
		_connect_state_signals(
			s["state"],
			s["node"],
			s.get("enter_sound", null)
		)

func _setup_buttons() -> void:
	$Settings/Apply.pressed.connect(Settings.change_settings)
	# Further settings buttons handled by settings_controller.gd
	$LobbyType/Options/Steam.pressed.connect(func(): _on_lobby_type(false))
	$LobbyType/Options/LAN.pressed.connect(func(): _on_lobby_type(true))
	$Main/Options/Play.pressed.connect(func(): state_chart.send_event("play"))
	$Main/Options/Settings.pressed.connect(func(): state_chart.send_event("settings"))
	$Main/Options/Quit.pressed.connect(func(): get_tree().quit())
	$HostJoin/Options/Host.pressed.connect(_on_host)
	$HostJoin/Options/Join.pressed.connect(_on_join)
	$Error/Return.pressed.connect(func(): state_chart.send_event("back"))

func _connect_state_signals(
	state_node: Node,
	target_node: Node,
	enter_sound: AudioStream = null,
) -> void:
	state_node.state_entered.connect(func():
		target_node.show()
		if enter_sound:
			_play_sound(enter_sound)
	)
	state_node.state_exited.connect(func(): target_node.hide())

func _play_sound(sound: AudioStream) -> void:
	sfx.steam = sound
	sfx.play()

func _on_lobby_type(_lan : bool) -> void:
	state_chart.send_event("decision")
	lan = _lan

func enter() -> void:
	state_chart.send_event("enter")

func _main_input(event : InputEvent) -> void:
	if event.is_action_pressed("back"):
		state_chart.send_event("back")
		lan = false

func _title_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		state_chart.send_event("enter")

func _display_error(error : String) -> void:
	state_chart.send_event("error")
	error_text.text = '[center]' + error + '[/center]'

func _on_lobby_join_requested(_this_lobby_id: int, _friend_id: int) -> void:
	state_chart.send_event("loading")

func _on_join() -> void:
	if lan:
		state_chart.send_event('loading')
		NetworkManager._on_join_lan()
	else:
		Steam.activateGameOverlay("Friends")

func _on_host() -> void:
	state_chart.send_event('loading')
	if lan:
		NetworkManager._on_host_lan()
	else:
		NetworkManager._on_host_steam()

func _on_mouse_sensitivity(value:float) -> void:
	Settings.mouse_sensitivity = value
