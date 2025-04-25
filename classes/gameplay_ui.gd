extends Control

# these parameters should be set before adding to the tree
@export var difficulty: Global.Difficulty 
@export var character: Global.Character
@export var stage: Global.Stage

const DIFFICULTY_COLORS: Dictionary[Global.Difficulty, Color]={
	Global.Difficulty.EASY: Color.AQUA,
	Global.Difficulty.NORMAL: Color.REBECCA_PURPLE,
	Global.Difficulty.HARD: Color.SALMON,
	Global.Difficulty.LUNATIC: Color.CRIMSON,
}

func _enter_tree() -> void:
	%GameServer.difficulty = difficulty
	%GameServer.player_scene = Global.CHARACTER_SCENES[character]
	%GameServer.stage_scene = Global.STAGE_SCENES[stage]

func _ready() -> void:
	$HUD/Stats/Difficulty.text = Global.Difficulty.keys()[difficulty]
	$HUD/Stats/Difficulty.add_theme_color_override(&"font_outline_color", DIFFICULTY_COLORS[difficulty])

func post_transition() -> void:
	if %GameServer.stage and %GameServer.stage.has_method(&"post_transition"):
		%GameServer.stage.post_transition()
	var border_tween: = create_tween()
	for i in 32:
		border_tween.tween_callback($GameplayArea/BorderLine.set.bind("modulate", Color.TRANSPARENT)).set_delay(0.08)
		border_tween.tween_callback($GameplayArea/BorderLine.set.bind("modulate", Color.WHITE)).set_delay(0.02)
	border_tween.tween_callback($GameplayArea/BorderLine.queue_free)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		if !get_tree().paused:
			$GameplayArea/PauseMenu.show_pause()
		else:
			$GameplayArea/PauseMenu.hide_pause()
