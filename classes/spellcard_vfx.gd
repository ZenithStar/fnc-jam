class_name SpellcardVFX extends Node3D
const X_BASE: = PI/2.0
const X_MIN: = -PI/8.0
const X_MAX: = PI/8.0
const Y_MIN: = -PI/8.0
const Y_MAX: = PI/8.0
const SPIN_SPEED_MIN: = PI/4.0
const SPIN_SPEED_MAX: = TAU

@export var noise: Noise
@onready var _noise_x_offset: float = randf()
@onready var _noise_y_offset: float = 1000.0+randf()
@onready var _noise_z_offset: float = 2000.0+randf()
var elapsed: float

var _circle_tween: Tween
@export var spell_circle: bool = false:
	set(value):
		if spell_circle != value:
			spell_circle = value
			_circle_tween = create_tween()
			_circle_tween.tween_property($Visuals/MagicCircle, "material:albedo_color:a", 1.0 if spell_circle else 0.0, 0.5)

func _ready():
	noise.seed = randi()

func _process(delta: float) -> void:
	elapsed+=delta
	$Visuals.rotation.x = X_BASE + lerp(X_MIN, X_MAX, noise.get_noise_1d(_noise_x_offset+elapsed))
	$Visuals.rotation.y = lerp(Y_MIN, Y_MAX, noise.get_noise_1d(_noise_y_offset+elapsed))
	$Visuals/MagicCircle.rotate(Vector3.UP, lerp(SPIN_SPEED_MIN, SPIN_SPEED_MAX, noise.get_noise_1d(_noise_z_offset+elapsed))*delta )
