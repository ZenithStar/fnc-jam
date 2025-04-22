extends StageBase


func test_sequence() -> void:
	_bosses["jane"].position = Vector2(500.0, 0.0)
	GlitchEffect.start()
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(_bosses["jane"], "position", Vector2(0.0, -300.0), 1.5)
	await tween.finished
	Dialogic.start( "test_ipsum" )
	await Dialogic.timeline_ended
	_bosses["jane"].active = true
	while true:
		tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(_bosses["jane"], "position", Vector2(randf_range(-350, 350), randf_range(-100,-380)), randf_range(2.0, 2.5))
		await tween.finished
	
