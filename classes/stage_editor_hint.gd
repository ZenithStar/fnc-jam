@tool
class_name StageEditorHint extends Node2D

@export var bounds: Rect2 = Global.GAMEPLAY_AREA
@export var color: Color = Color.REBECCA_PURPLE

func _ready():
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(bounds, color)
