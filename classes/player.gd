class_name Player extends Area2D

const DEATHBOMB_WINDOW: float = .133
const ANIMATION_FPS: float = 10.0
const NUM_ANIMATION_FRAMES: int = 3
const DEATH_EXPLOSION_SCENE: PackedScene = preload("uid://dasqetbsbueb7")

const SPAWN_IMMUNE_DURATION: = 3.0
const BOMB_IMMUNE_DURATION: = 3.0
const IMMUNE_FLASH_PERIOD: = 0.1
const IMMUNE_FLASH_PROPORTION: = 0.5
const IMMUNE_FLASH_COLOR: = Color(Color.WEB_PURPLE, 0.2)

signal death
signal hit
signal bomb

@export var normal_velocity: = 500.0 ## px/s
@export var focused_velocity: = 200.0 ## px/s

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

var _immune_time: = 6.0

var focused: bool:
	set(value):
		focused = value
		$Sprites/FocusIndicator.visible = focused

func _step_animation():
	$Sprites/Body.frame_coords.x = ($Sprites/Body.frame_coords.x + 1) % NUM_ANIMATION_FRAMES
	if focused and $Sprites/Wings.frame_coords.y == 0:
		$Sprites/Wings.frame_coords = Vector2i(0,1)
	elif not focused and $Sprites/Wings.frame_coords.y == 2:
		$Sprites/Wings.frame_coords = Vector2i(2,1)
	elif $Sprites/Wings.frame_coords.y == 1:
		$Sprites/Wings.frame = $Sprites/Wings.frame + 1 if focused else $Sprites/Wings.frame - 1
	if $Sprites/Wings.frame_coords.y != 1:
		$Sprites/Wings.frame_coords.x = $Sprites/Body.frame_coords.x

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("focus"):
		focused = Input.is_action_pressed("focus")

func _ready() -> void:
	_animation_loop_tween = create_tween()
	_animation_loop_tween.tween_interval( 1.0 / ANIMATION_FPS )
	_animation_loop_tween.tween_callback(_step_animation)
	_animation_loop_tween.set_loops()
	
	_focus_spin_tween = create_tween()
	_focus_spin_tween.tween_property($Sprites/FocusIndicator, "rotation", TAU, 1.0)
	_focus_spin_tween.tween_callback($Sprites/FocusIndicator.set.bind("rotation", 0.0))
	_focus_spin_tween.set_loops()
	
	focused = Input.is_action_pressed("focus")
	
	hit.connect(_on_hit)
	bomb.connect(_on_bomb)
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
	
	if is_finite(_immune_time):
		_immune_time -= delta
		$Sprites.modulate = IMMUNE_FLASH_COLOR if fmod(_immune_time, IMMUNE_FLASH_PERIOD) > IMMUNE_FLASH_PERIOD*IMMUNE_FLASH_PROPORTION else Color.WHITE
		if _immune_time <= 0.0:
			_immune_time = -INF
			$Sprites.modulate = Color.WHITE

func _on_hit():
	if not is_immune() and not is_finite(_deathbomb_timer):
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

func _on_bomb():
	_immune_time = BOMB_IMMUNE_DURATION
	if is_finite(_deathbomb_timer):
		_deathbomb_timer = INF
		# do something else on a successful deathbomb?

func is_immune() -> bool:
	return is_finite(_immune_time)
