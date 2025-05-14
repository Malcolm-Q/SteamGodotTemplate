extends Node
class_name SettingsController

@export var fps_button : Button
@export var vsync_button : Button
@export var window_button : Button
@export var music_slider : HSlider
@export var sfx_slider : HSlider
@export var mouse_slider : HSlider

func _ready() -> void:
	if fps_button:
		fps_button.text = 'FPS TARGET :  ' + ('UNLIMITED' if Settings.fps == 0 else str(Settings.fps))
		fps_button.pressed.connect(set_fps)
	if vsync_button:
		vsync_button.text = 'VSYNC      :  ' + Settings.vsync_modes[Settings.vsync]
		vsync_button.pressed.connect(set_vsync)
	if window_button:
		window_button.text = 'WINDOW     :  ' + ('FULLSCREEN' if Settings.fullscreen else 'WINDOWED')
		window_button.pressed.connect(toggle_fullscreen)
	if music_slider:
		music_slider.value = Settings.music_vol
		music_slider.value_changed.connect(set_music)
	if sfx_slider:
		sfx_slider.value = Settings.sfx_vol
		sfx_slider.value_changed.connect(set_sfx)
	if mouse_slider:
		mouse_slider.value = Settings.mouse_sensitivity
		mouse_slider.value_changed.connect(set_mouse_sens)

func set_music(value: float) -> void:
	Settings.music_vol = value

func set_sfx(value: float) -> void:
	Settings.sfx_vol = value

func set_mouse_sens(value: float) -> void:
	Settings.mouse_sensitivity = value

func set_fps() -> void:
	Settings.iterate_fps()
	fps_button.text = 'FPS TARGET :  ' + ('UNLIMITED' if Settings.fps == 0 else str(Settings.fps))

func set_vsync() -> void:
	Settings.iterate_vsync()
	vsync_button.text = 'VSYNC      :  ' + Settings.vsync_modes[Settings.vsync]

func toggle_fullscreen() -> void:
	Settings.fullscreen = !Settings.fullscreen
	window_button.text = 'WINDOW     :  ' + ('FULLSCREEN' if Settings.fullscreen else 'WINDOWED')
