extends Node
class_name Main

# This mostly exists as a root for scene switches and to play synced music independent of scenes

@onready var musicAudio : AudioStreamPlayer = $MusicAudio
@onready var current_music_dict : Array = main_music_dict.keys()

var special_music_dict : Dictionary = {
	# put special music like a winning theme in here
}
var main_music_dict : Dictionary = {
	# put general music in here
	# 'My Song' : 'res://assets/audio/music/my_song.ogg'
}

var current_song := ""
var sync := false


func _ready() -> void:
	GameManager.main = self

func _start_synced_music() -> void:
	if !multiplayer.is_server():
		return
	await get_tree().create_timer(1.0).timeout
	sync = true
	while sync:
		_play_track.rpc(_get_random_track())
		await musicAudio.finished
		await get_tree().create_timer(0.5).timeout

func _get_random_track() -> String:
	if current_music_dict.size() == 0:
		current_music_dict = main_music_dict.keys()
	return current_music_dict.pop_at(randi() % current_music_dict.size())

@rpc("call_local")
func _play_track(track : String) -> void:
	if !main_music_dict.get(track):
		print(track + ' is not a key in the music dict!')
		return
	musicAudio.stream = load(main_music_dict[track])
	current_song = track
	musicAudio.play()

@rpc("call_local")
func _play_special(track : String) -> void:
	if !special_music_dict.get(track):
		print(track + ' is not a key in the music dict!')
		return
	musicAudio.stream = load(special_music_dict[track])
	musicAudio.play()
