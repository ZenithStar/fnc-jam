extends AnimatedSprite2D

@export var lateral_animation_threshold = 50.0
const VELOCITY_X_FILTER_LENGTH: int = 5
var _velocity_x_buffer: Array[float]
var _last_position_x: float = 0.0

enum Directions{
	CENTER,
	LEFT,
	RIGHT,
}

@export var direction_facing: Directions = Directions.CENTER:
	set(value):
		if direction_facing != value:
			direction_facing = value
			match direction_facing:
				Directions.CENTER:
					animation = &"center"
				Directions.LEFT:
					if sprite_frames.has_animation(&"left"):
						animation = &"left"
						flip_h = false
					elif sprite_frames.has_animation(&"right"):
						animation = &"right"
						flip_h = true
				Directions.RIGHT:
					if sprite_frames.has_animation(&"right"):
						animation = &"right"
						flip_h = false
					elif sprite_frames.has_animation(&"left"):
						animation = &"left"
						flip_h = true
						
func _physics_process(delta: float) -> void:
	var velocity_x: = (global_position.x - _last_position_x) / delta
	_last_position_x = global_position.x
	_velocity_x_buffer.push_back(velocity_x)
	while(_velocity_x_buffer.size()) > VELOCITY_X_FILTER_LENGTH:
		_velocity_x_buffer.pop_front()
	var filtered_velocity: float = _velocity_x_buffer.reduce(func(accum, number): return accum + number, 0.0) / _velocity_x_buffer.size()
	if filtered_velocity <= -lateral_animation_threshold: # left
		direction_facing = Directions.LEFT
	elif filtered_velocity >= lateral_animation_threshold: # right
		direction_facing = Directions.RIGHT
	else: # center
		direction_facing = Directions.CENTER
