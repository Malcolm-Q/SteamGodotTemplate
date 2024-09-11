extends Node

@onready var audio : AudioStreamPlayer = $StaticAudio/UIAudio
@onready var musicAudio : AudioStreamPlayer = $StaticAudio/MusicAudio
@export var ui_move : AudioStream
@onready var music_dict : Dictionary = {
	#'title':preload('example.mp3')
}

func _ready() -> void:
	GameManager.main = self
	SignalBus.ui_focus_changed.connect(_on_ui_focus_changed)
	SignalBus.play_music.connect(_play_music)
	if music_dict.get('title'):
		musicAudio.stream = music_dict['title']
		musicAudio.play()

func _play_music(track : String) -> void:
	if !music_dict.get(track):
		print(track + ' is not a key in the music dict!')
		return
	musicAudio.stream = music_dict['title']
	musicAudio.play()

func _on_ui_focus_changed() -> void:
	if ui_move:
		audio.stream = ui_move
	else:
		return
	audio.play()
