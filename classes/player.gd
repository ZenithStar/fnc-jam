class_name Player extends Area2D

const DEATHBOMB_WINDOW: float = .16667
const ANIMATION_FPS: float = 10.0
const NUM_ANIMATION_FRAMES: int = 3
const DEATH_EXPLOSION_SCENE: PackedScene = preload("uid://dasqetbsbueb7")


signal death
signal hit

@export var normal_velocity: = 400.0 ## px/s
@export var focused_velocity: = 150.0 ## px/s

@export var gameplay_bounds: Rect2 = Global.GAMEPLAY_AREA

@export var hitbox_radius: float = 3.0:
	set( value ):
		$Hitbox.shape.radius = value
	get:
		return $Hitbox.shape.radius

enum Directions{
	CENTER,
	LEFT,
	RIGHT,
}
@export var direction_facing: Directions = Directions.CENTER:
	set(value):
		if direction_facing != value:
			direction_facing = value
			var sprite: Sprite2D = find_child("Body")
			if is_instance_valid(sprite):
				match direction_facing:
					Directions.CENTER:
						sprite.frame_coords.y = 0
					Directions.LEFT:
						sprite.frame_coords.y = 1
					Directions.RIGHT:
						sprite.frame_coords.y = 2

var _deathbomb_timer: float = INF

var _animation_loop_tween: Tween
var _focus_spin_tween: Tween

var controlable: bool = false # off while spawning in and off during death animation

var focused: bool:
	set(value):
		focused = value
		$FocusIndicator.visible = focused

func _step_animation():
	$Body.frame_coords.x = ($Body.frame_coords.x + 1) % NUM_ANIMATION_FRAMES
	if focused and $Wings.frame_coords.y == 0:
		$Wings.frame_coords = Vector2i(0,1)
	elif not focused and $Wings.frame_coords.y == 2:
		$Wings.frame_coords = Vector2i(2,1)
	elif $Wings.frame_coords.y == 1:
		$Wings.frame = $Wings.frame + 1 if focused else $Wings.frame - 1
	if $Wings.frame_coords.y != 1:
		$Wings.frame_coords.x = $Body.frame_coords.x

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("focus"):
		focused = Input.is_action_pressed("focus")

func _ready() -> void:
	_animation_loop_tween = create_tween()
	_animation_loop_tween.tween_interval( 1.0 / ANIMATION_FPS )
	_animation_loop_tween.tween_callback(_step_animation)
	_animation_loop_tween.set_loops()
	
	_focus_spin_tween = create_tween()
	_focus_spin_tween.tween_property($FocusIndicator, "rotation", TAU, 1.0)
	_focus_spin_tween.tween_callback($FocusIndicator.set.bind("rotation", 0.0))
	_focus_spin_tween.set_loops()
	
	focused = Input.is_action_pressed("focus")
	
	hit.connect(_on_hit)
	death.connect(_on_death)

func _physics_process(delta) -> void:
	var velocity: = Input.get_vector("move_left", "move_right", "move_up", "move_down").limit_length() * \
		( focused_velocity if Input.is_action_pressed("focus") else normal_velocity)
	
	if controlable:
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
			_deathbomb_timer = INF
			death.emit()
			

func _on_hit():
	if not is_finite(_deathbomb_timer):
		_deathbomb_timer = DEATHBOMB_WINDOW

func _on_death():
	var explosion : = DEATH_EXPLOSION_SCENE.instantiate()
	explosion.position = position
	get_tree().get_first_node_in_group("PlayerBulletServer").add_child(explosion)
	#$PrimaryShot.queue_free()
	#$SecondaryShot.queue_free()
	set.call_deferred("monitorable", false)
	controlable = false
	var tween: = create_tween()
	modulate.a = 0.2
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2(10,10), 0.5)
	tween.tween_callback(queue_free)
