extends Node2D

func run():
	$"../..".stop()
	visible = true
	BGMServer.fade_to_new(&"uid://bsxf72i1psbly")
	await create_tween().tween_property(self, "modulate:a", 1.0, 2.0).finished
	
	var tween: = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Title/StageTitle, "modulate:a", 1.0, 1.0)
	await tween.tween_interval(2.0).finished
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property($Title/StageTitle, "modulate:a", 0.0, 2.0).finished
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property($Koakuma, "position:y", -300, 2.0).finished
	Dialogic.start( "stage_two_mid" )
	await Dialogic.timeline_ended
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property($Koakuma, "position:y", -520, 2.0).finished
	
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property($Kadri, "position", Vector2(0, -300.0), 2.0).finished
	Dialogic.start( "stage_two_boss" )
	await Dialogic.timeline_ended
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property($Kadri, "position", Vector2(450, -200.0), 2.0).finished
	
	BGMServer.fade_to_new(&"uid://b2jfobimj67x4")
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Title2/StageTitle, "modulate:a", 1.0, 1.0)
	await tween.tween_interval(2.0).finished
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property($Title2/StageTitle, "modulate:a", 0.0, 2.0).finished
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property($Remi, "position:y", -300, 2.0).finished
	Dialogic.start( "stage_three_mid" )
	await Dialogic.timeline_ended
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property($Remi, "position:y", -520, 2.0).finished
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property($Iele, "position", Vector2(0, -300.0), 2.0).finished
	Dialogic.start( "stage_three" )
	await Dialogic.timeline_ended
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property($Iele, "position", Vector2(450, -200.0), 2.0).finished
	
	
	BGMServer.fade_to_new(&"uid://boab0nsa4uero")
	Dialogic.start( "epilogue" )
	await Dialogic.timeline_ended
	
