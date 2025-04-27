extends Node2D

var _tween: Tween
func clear():
	$Clearer.scale = Vector2.ZERO
	$Clearer.set_deferred("monitoring", true)
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property($Clearer, "scale", Vector2.ONE*5.0, 0.1)
	_tween.tween_callback($Clearer.set_deferred.bind("monitoring", false))
	_tween.tween_callback($Clearer.set_deferred.bind("scale", Vector2.ZERO))

func _on_clearer_area_entered(area: Area2D) -> void:
	if area.has_signal(&"hit"):
		area.hit.emit(420.0)
