extends Area2D

@export var normal_velocity: = 75.0 ## px/s
@export var focused_velocity: = 30.0 ## px/s

@export var gameplay_bounds: Rect2 = Global.GAMEPLAY_AREA

@export var hitbox_radius: float = 3.0:
	set( value ):
		$CollisionShape2D.shape.radius = value
	get:
		return $CollisionShape2D.shape.radius

func _physics_process(delta) -> void:
	var velocity: = Input.get_vector("move_left", "move_right", "move_up", "move_down").limit_length() * \
		( focused_velocity if Input.is_action_pressed("focus") else normal_velocity)
	
	position = (position + (velocity * delta)).clamp(gameplay_bounds.position, gameplay_bounds.end)
	
