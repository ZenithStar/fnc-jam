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
	transition_to_scene(TITLE_SCENE)

func transition_to_scene(scene: PackedScene) -> Node:
	# TODO: add transitions
	match scene:
		TITLE_SCENE, GAMEPLAY_SCENE:
			var new_scene: = scene.instantiate()
			add_child(new_scene)
			if is_instance_valid(current_scene):
				current_scene.queue_free()
			current_scene = new_scene
			return current_scene
		_:
			return null

func start_game(difficulty: Global.Difficulty = Global.Difficulty.NORMAL, 
			character: Global.Character = Global.Character.REIMU_A):
	var new_scene: = transition_to_scene(GAMEPLAY_SCENE)
	# TODO: configure the gameplay scene
