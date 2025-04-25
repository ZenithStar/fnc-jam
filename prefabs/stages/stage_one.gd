extends StageBase

func post_transition():
	$PreloadSong.queue_free()
	$PreloadSong2.queue_free()
	await BGMServer.fade_to_new(Global.SONGS[Global.Song.STAGE_ONE])
	play("stage")
