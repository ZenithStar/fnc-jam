extends Area2D


const DEATHBOMB_WINDOW: float = .16667

signal death

@export var normal_velocity: = 400.0 ## px/s
@export var focused_velocity: = 150.0 ## px/s

@export var gameplay_bounds: Rect2 = Global.GAMEPLAY_AREA

@export var hitbox_radius: float = 3.0:
	set( value ):
		$CollisionShape2D.shape.radius = value
	get:
		return $CollisionShape2D.shape.radius

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

var _deathbomb_timer: float = INF

func _physics_process(delta) -> void:
	var velocity: = Input.get_vector("move_left", "move_right", "move_up", "move_down").limit_length() * \
		( focused_velocity if Input.is_action_pressed("focus") else normal_velocity)
	
	position = (position + (velocity * delta)).clamp(gameplay_bounds.position, gameplay_bounds.end)
	
	if velocity.x < 0.0: # left
		direction_facing = Directions.LEFT
	elif velocity.x > -0.0: # right
		direction_facing = Directions.RIGHT
	else: # center
		direction_facing = Directions.CENTER
		
	if is_finite(_deathbomb_timer):
		_deathbomb_timer -= delta
		if _deathbomb_timer <= 0.0:
			death.emit()
			

func hit(): # I don't think this needs to be a signal, but maybe it does
	if not is_finite(_deathbomb_timer):
		_deathbomb_timer = DEATHBOMB_WINDOW
