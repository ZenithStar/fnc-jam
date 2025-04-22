extends Node2D

const CARD_DEPTH: = 1.0

var _camera_3d: Camera3D
var _camera_2d: Camera2D
var _spellcard: SpellcardVFX
func _enter_tree() -> void:
	_camera_3d = get_viewport().get_camera_3d()
	_camera_2d = get_viewport().get_camera_2d()
	_spellcard = _camera_3d.find_child("SpellcardVFX")

func _exit_tree() -> void:
	_spellcard.visible = false

func _ready() -> void:
	_spellcard.visible = true

func _physics_process(delta: float) -> void:
	_spellcard.global_position = _camera_3d.project_position( get_canvas_transform() * global_position , CARD_DEPTH)
