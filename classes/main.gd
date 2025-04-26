extends Node

const TITLE_SCENE: = preload("uid://l6fmd7keqx2k")
const GAMEPLAY_SCENE: = preload("uid://csf8dfafuvl8q")


enum State{
	PRETITLE,
	TITLE,
	GAMEPLAY,
}

var state: State = State.PRETITLE

var current_scene: Node

func _ready() -> void:
	$PreloadShaders/SmallSplatter.emitting = true
	$PreloadShaders/FlanPrimaryShot/HitParticles2D.emitting = true
	$PreloadShaders/FlanCrush/CenterBlood.emitting = true
	Dialogic.Styles.create_layout(preload("uid://mafst78xqouv"))
	Dialogic.start("empty")
	var tween: = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback($PreloadShaders.queue_free)
	tween.tween_callback(go_to_title)

var _transition_tween: Tween

func _set_glitch_fade(value: float):
	$TransitionServer/GlitchFade.material.set_shader_parameter("fade", value)

func transition_to_scene(new_scene: Node) -> Node:
	# TODO: add transitions
	if is_instance_valid(_transition_tween) and _transition_tween.is_running():
		return null
	var first_time: Node = $SubViewport/MainLoadingScreen.find_child("Panel")
	if first_time:
		await get_tree().create_timer(1.0).timeout # this should only happen at the start of the game
	else:
		_transition_tween = create_tween()
		_transition_tween.set_ease(Tween.EASE_IN_OUT)
		_transition_tween.set_trans(Tween.TRANS_QUAD)
		_transition_tween.tween_method(_set_glitch_fade, 0.0, 1.0, 0.5)
		await _transition_tween.finished
	
	
	add_child(new_scene)
	if is_instance_valid(current_scene):
		current_scene.queue_free()
	current_scene = new_scene
	await get_tree().create_timer(2.0).timeout
	
	
	_transition_tween = create_tween()
	_transition_tween.set_ease(Tween.EASE_IN_OUT)
	_transition_tween.set_trans(Tween.TRANS_QUAD)
	_transition_tween.tween_method(_set_glitch_fade, 1.0, 0.0, 0.5)
	await _transition_tween.finished
	
	
	if first_time:
		first_time.queue_free()
		$SubViewport/MainLoadingScreen.texture = preload("uid://cq4xych56bjo4")
	if current_scene.has_method(&"post_transition"):
		current_scene.post_transition()
	return current_scene

func start_game(difficulty: Global.Difficulty = Global.Difficulty.NORMAL, 
			character: Global.Character = Global.Character.FLANDRE_A,
			stage: Global.Stage = Global.Stage.STAGE_ONE):
	var scene: = GAMEPLAY_SCENE.instantiate()
	scene.stage = stage
	scene.difficulty = difficulty
	scene.character = character
	transition_to_scene(scene)

func go_to_title():
	var scene: = TITLE_SCENE.instantiate()
	transition_to_scene(scene)

func change_bgm( path : StringName ):
	BGMServer.fade_to_new(path)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("focus") or event.is_action("fire"):
		if (event.is_echo() and event.is_pressed()) or event.is_released():
			Dialogic.Inputs.auto_skip.enabled = Input.is_action_pressed("focus") or Input.is_action_pressed("fire")
