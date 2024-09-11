extends UIState

func enter(s : String) -> void:
	$options/Fullscreen.text = '>WINDOW     :  ' + ('FULLSCREEN' if Settings.fullscreen else 'WINDOWED')
	$options/FPS.text = ' FPS TARGET :  ' + 'UNLIMITED' if Settings.fps == 0 else str(Settings.fps)
	$options/VSync.text = ' VSYNC      :  ' + Settings.vsync_modes[Settings.vsync]
	$options/Music/HSlider.value = Settings.music_vol
	$options/SFX/HSlider.value = Settings.sfx_vol
	$options/Mouse/HSlider.value = Settings.mouse_sensitivity
	super.enter(s)
