extends Node

var fps := 0
var vsync := 1
var music := AudioServer.get_bus_index("Music")
var sfx := AudioServer.get_bus_index("SFX")
var music_vol := 1.0
var sfx_vol := 1.0
var mouse_sensitivity := 0.5
var fullscreen := true
var vsync_modes : Dictionary = {
	0 : "DISABLED",
	1 : "ENABLED",
	2 : "ADAPTIVE",
	3 : "MAILBOX"
}

var fps_options : Array = [
	0,
	30,
	60,
	90,
	120,
	240
]

var fps_index := 0

func _ready() -> void:
	if ResourceLoader.exists("user://data.res"):
		var data : SaveData = ResourceLoader.load("user://data.res")
		fps_index = data.fps_index
		fullscreen = data.fullscreen
		vsync = data.vsync
		music_vol = data.music_vol
		sfx_vol = data.sfx_vol
		mouse_sensitivity = data.mouse_sensitivity
		fps = fps_options[fps_index]
		change_settings()
	else:
		var data := SaveData.new()
		fps_index = data.fps_index
		fullscreen = data.fullscreen
		vsync = data.vsync
		music_vol = data.music_vol
		sfx_vol = data.sfx_vol
		mouse_sensitivity = data.mouse_sensitivity
		fps = fps_options[fps_index]
		change_settings()

func iterate_fps():
	fps_index += 1
	if fps_index >= len(fps_options):
		fps_index = 0
	fps = fps_options[fps_index]

func change_settings():
	SignalBus.change_settings.emit()
	Engine.set_max_fps(fps)
	DisplayServer.window_set_vsync_mode(vsync)
	AudioServer.set_bus_volume_db(music, linear_to_db(music_vol))
	AudioServer.set_bus_volume_db(sfx, linear_to_db(sfx_vol))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_MAXIMIZED)
	_save_game()

func _save_game():
	var data = SaveData.new()
	data.fps_index = fps_index
	data.fullscreen = fullscreen
	data.vsync = vsync
	data.music_vol = music_vol
	data.sfx_vol = sfx_vol
	ResourceSaver.save(data, "user://data.res")
