extends AnimationPlayer
# a collection of functions to be used with 



func change_bgm( name : String ):
	get_tree().get_first_node_in_group("BGMServer").set("switch_to_clip", name)
	get_tree().get_first_node_in_group("BGMServer").play()

func play_dialogic_timeline( name : String ):
	pause()
	Dialogic.start_timeline( name )
	await Dialogic.timeline_ended
	play()
