class_name Pickup extends Area2D

enum Type{
	SMALL_POWER,
	LARGE_POWER,
	FULL_POWER,
	SMALL_POINT,
	LARGE_POINT,
	LIFE_SHARD,
	BOMB_SHARD,
}

const SELF_REMOVAL_HEIGHT: = 480.0
const THROW_DISTANCE: = 64.0
const THROW_DURATION: = 0.6
const FALL_VELOCITY: = 150.0
const VACUUM_VELOCITY: = 600.0
const VACUUM_THRESHOLD: = 8.0

@export var type: Type
@export var offscreen_position: float = -404 ## -404 for 16x16 and -392 for 32x32
@export var offscreen_threshold: float = -428 ## -428 for 16x16 and -440 for 32x32
@export var sprite: Texture2D
@export var offscreen_sprite: Texture2D


enum State{
	THROWING,
	FALLING,
	VACUUMING,
}
@export var state: State = State.THROWING:
	set(value):
		state = value
		match state:
			State.FALLING:
				if is_instance_valid(_throw_tween) and _throw_tween.is_running():
					_throw_tween.kill()
			State.VACUUMING:
				if is_instance_valid(_throw_tween) and _throw_tween.is_running():
					_throw_tween.kill()
				set_deferred("monitoring", false)

var _throw_tween: Tween
var _spin_tween: Tween # the spin tween needs to be independent because it will continue to spin if you immediately jump to vacuuming
func _ready() -> void:
	$OffscreenSprite.position = Vector2(global_position.x, offscreen_position)
	if sprite:
		$Sprite.texture = sprite
	if offscreen_sprite:
		$OffscreenSprite.texture = offscreen_sprite
	
	_throw_tween = create_tween()
	_throw_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_throw_tween.set_ease(Tween.EASE_OUT)
	_throw_tween.set_trans(Tween.TRANS_CUBIC)
	_throw_tween.tween_property(self, "position:y", position.y - THROW_DISTANCE, THROW_DURATION)
	_throw_tween.tween_callback(set.bind("state", State.FALLING))
	
	_spin_tween = create_tween()
	_spin_tween.set_ease(Tween.EASE_OUT)
	_spin_tween.set_trans(Tween.TRANS_CUBIC)
	_spin_tween.tween_property($Sprite, "rotation", TAU, THROW_DURATION)

func _physics_process(delta: float) -> void:
	match state:
		State.FALLING:
			position.y += FALL_VELOCITY * delta
			if position.y > SELF_REMOVAL_HEIGHT:
				queue_free()
		State.VACUUMING:
			var player_position: Vector2 = get_tree().get_first_node_in_group("Player").global_position
			global_position = global_position.move_toward( player_position ,  VACUUM_VELOCITY * delta)
			if global_position.distance_to(player_position) <= VACUUM_THRESHOLD:
				get_tree().get_first_node_in_group("GameServer").pickup.emit(type)
				queue_free()
	if global_position.y < offscreen_threshold:
		$Sprite.visible = false
		$OffscreenSprite.visible = true
	else:
		$Sprite.visible = true
		$OffscreenSprite.visible = false

func _on_area_entered(_area: Area2D) -> void:
	# validate?
	# just assume it's the player
	state = State.VACUUMING
