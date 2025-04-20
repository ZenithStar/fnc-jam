class_name BossBase extends Area2D
## Typically spawned by a Stage animation player
signal release ## notifies the animation player to continue
signal phase

@export var phases_remaining: int ## this is purely for display purposes. phasing is handled in the coroutine
@export var max_hp: float = 10000.0
@export var damage_till_phase: float = 0.0:
	set(value):
		var last_damage: = damage_till_phase
		damage_till_phase = value
		if last_damage > 0.0 and damage_till_phase <= 0.0:
			phase.emit()
@export var damage_reduction: = 1.0

@export var active: bool = false:
	set( value ):
		if active != value:
			active = value
			monitorable = active
			if not active:
				position = Vector2(10000.0, 10000.0) #teleport far away
				get_tree().get_first_node_in_group("TargetServer").unregister(self)
			else:
				get_tree().get_first_node_in_group("TargetServer").register(self)

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
						sprite.animation = "left"
					Directions.RIGHT:
						sprite.animation = "right"

func _init() -> void:
	position = Vector2(10000.0, 10000.0) # always spawn it way off screen

signal hit( damage: float )

func _on_hit( damage: float ):
	damage_till_phase -= damage * damage_reduction

const LATERAL_ANIMATION_THRESHOLD = 20.0 ## at what px/s velocity to 
const VELOCITY_X_FILTER_LENGTH: int = 10
var _velocity_x_buffer: Array[float]
var _last_position_x: float = 0.0
func _physics_process(delta: float) -> void:
	var velocity_x: = (global_position.x - _last_position_x) / delta
	_last_position_x = global_position.x
	_velocity_x_buffer.push_back(velocity_x)
	while(_velocity_x_buffer.size()) > VELOCITY_X_FILTER_LENGTH:
		_velocity_x_buffer.pop_front()
	var filtered_velocity: float = _velocity_x_buffer.reduce(func(accum, number): return accum + number, 0.0) / _velocity_x_buffer.size()
	if filtered_velocity <= LATERAL_ANIMATION_THRESHOLD: # left
		direction_facing = Directions.LEFT
	elif filtered_velocity >= -LATERAL_ANIMATION_THRESHOLD: # right
		direction_facing = Directions.RIGHT
	else: # center
		direction_facing = Directions.CENTER
