extends Control

# these parameters should be set before adding to the tree
@export var difficulty: Global.Difficulty 
@export var character: Global.Character
@export var stage: Global.Stage

func _enter_tree() -> void:
	%GameServer.difficulty = difficulty
	%GameServer.player_scene = Global.CHARACTER_SCENES[character]
	%GameServer.stage_scene = Global.STAGE_SCENES[stage]

func post_transition() -> void:
	if %GameServer.stage and %GameServer.stage.has_method(&"post_transition"):
		%GameServer.stage.post_transition()
	var border_tween: = create_tween()
	for i in 32:
		border_tween.tween_callback($GameplayArea/BorderLine.set.bind("modulate", Color.TRANSPARENT)).set_delay(0.08)
		border_tween.tween_callback($GameplayArea/BorderLine.set.bind("modulate", Color.WHITE)).set_delay(0.02)
	border_tween.tween_callback($GameplayArea/BorderLine.queue_free)
