extends Area2D

const LATERAL_ANIMATION_THRESHOLD = 20.0 ## at what px/s velocity to 
const VELOCITY_X_FILTER_LENGTH: int = 10
var _velocity_x_buffer: Array[float]
var _last_position_x: float = 0.0

@export var max_health: float = 100.0
@onready var current_health: float = max_health
@export var drops: Dictionary[PackedScene, int]

enum Directions{
	CENTER,
	LEFT,
	RIGHT,
}
@export var direction_facing: Directions = Directions.CENTER:
	set(value):
		if direction_facing != value:
			direction_facing = value
			var sprite: AnimatedSprite2D = find_child("AnimatedSprite2D")
			if is_instance_valid(sprite):
				match direction_facing:
					Directions.CENTER:
						sprite.animation = "center"
					Directions.LEFT:
						sprite.animation = "right"
						sprite.flip_h = true
					Directions.RIGHT:
						sprite.animation = "right"
						sprite.flip_h = false


signal hit( damage: float )
signal death

func _on_hit( damage: float ):
	current_health -= damage
	if current_health <= 0.0:
		death.emit()

func _on_death( ):
	get_tree().get_first_node_in_group("PickupServer").spawn(global_position, drops)
	queue_free()

func _physics_process(delta: float) -> void:
	var velocity_x: = global_position.x - _last_position_x
	_last_position_x = global_position.x
	_velocity_x_buffer.push_back(velocity_x)
	while(_velocity_x_buffer.size()) > VELOCITY_X_FILTER_LENGTH:
		_velocity_x_buffer.pop_front()
	var filtered_velocity: float = _velocity_x_buffer.reduce(func(accum, number): return accum + number, 0.0) / _velocity_x_buffer.size()
	if filtered_velocity >= LATERAL_ANIMATION_THRESHOLD: # left
		direction_facing = Directions.LEFT
	elif filtered_velocity <= -LATERAL_ANIMATION_THRESHOLD: # right
		direction_facing = Directions.RIGHT
	else: # center
		direction_facing = Directions.CENTER
