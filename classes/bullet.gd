class_name Bullet extends Area2D

const DELETE_ANIMATION: = preload("uid://dt8yui6a44f6k")

enum SpriteColor{
	WHITE,
	GRAY,
	RED,
	ORANGE,
	YELLOW,
	LIGHT_GREEN,
	GREEN,
	CYAN,
	BLUE,
	PURPLE,
	MAGENTA,
	BLACK,
	INVERSE_WHITE,
	INVERSE_GRAY,
	INVERSE_RED,
	INVERSE_ORANGE,
	INVERSE_YELLOW,
	INVERSE_LIGHT_GREEN,
	INVERSE_GREEN,
	INVERSE_CYAN,
	INVERSE_BLUE,
	INVERSE_PURPLE,
	INVERSE_MAGENTA,
	INVERSE_BLACK,
}

const DELETE_COLORS: Dictionary[SpriteColor, Color] ={
	SpriteColor.WHITE: Color.WHITE,
	SpriteColor.GRAY: Color.GRAY,
	SpriteColor.RED: Color.RED,
	SpriteColor.ORANGE: Color.ORANGE,
	SpriteColor.YELLOW: Color.YELLOW,
	SpriteColor.LIGHT_GREEN: Color.LIGHT_GREEN,
	SpriteColor.GREEN: Color.WEB_GREEN,
	SpriteColor.CYAN: Color.CYAN,
	SpriteColor.BLUE: Color.BLUE,
	SpriteColor.PURPLE: Color.WEB_PURPLE,
	SpriteColor.MAGENTA: Color.MAGENTA,
	SpriteColor.BLACK: Color.NAVY_BLUE,
	SpriteColor.INVERSE_WHITE: Color.WHITE,
	SpriteColor.INVERSE_GRAY: Color.GRAY,
	SpriteColor.INVERSE_RED: Color.RED,
	SpriteColor.INVERSE_ORANGE: Color.ORANGE,
	SpriteColor.INVERSE_YELLOW: Color.YELLOW,
	SpriteColor.INVERSE_LIGHT_GREEN: Color.LIGHT_GREEN,
	SpriteColor.INVERSE_GREEN: Color.WEB_GREEN,
	SpriteColor.INVERSE_CYAN: Color.CYAN,
	SpriteColor.INVERSE_BLUE: Color.BLUE,
	SpriteColor.INVERSE_PURPLE: Color.WEB_PURPLE,
	SpriteColor.INVERSE_MAGENTA: Color.MAGENTA,
	SpriteColor.INVERSE_BLACK: Color.NAVY_BLUE,
}

enum SpriteType{
	BAR,
	ROUND,
	ROUND2,
	RICE,
	OFUDA,
	KUNAI,
	SPEEDY_RICE,
	BULLET,
	FADED_BULLET,
	RICE2,
	STAR,
	TEARDROP,
	DISK,
	ROUND_STAR,
	ROUND_STAR2,
	ROUND_STAR3,
	ROUND_STAR4,
}
enum Hitbox{
	V16H16,
	V16H8,
}
const HITBOXES: Dictionary[Hitbox, Shape2D] = {
	Hitbox.V16H16: preload("uid://c6xpgmedx6tfw"),
	Hitbox.V16H8: preload("uid://cp3bel0wro1co"),
}

@export var sprite_color: SpriteColor = SpriteColor.WHITE
@export var sprite_type: SpriteType = 0
@export var hitbox: Hitbox

var bounds: Rect2

func _enter_tree():
	$Sprite2D.region_rect = Rect2(Vector2(16,16)*Vector2(sprite_color, sprite_type), Vector2(16,16))
	$CollisionShape2D.shape = HITBOXES[hitbox]
	position = origin + Vector2.from_angle(rotation) * lin_offset
	bounds = Global.GAMEPLAY_AREA
	bounds.end += Vector2(16.0, 16.0)
	bounds.position -= Vector2(16.0, 16.0)

@export var origin: Vector2 = Vector2.ZERO
@export var lin_vel: float = 100.0
@export var lin_offset: float = 0.0
@export var lin_accel: float = 0.0
@export var orbit_vel: float = 0.0
@export var orbit_accel: float = 0.0
func _physics_process(delta: float) -> void:
	orbit_vel += orbit_accel * delta
	rotation += orbit_vel * delta
	lin_vel += lin_accel * delta
	lin_offset += lin_vel * delta
	position = origin + Vector2.from_angle(rotation) * lin_offset
	if not bounds.has_point(position):
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area == get_tree().get_first_node_in_group("Player"):
		area.hit.emit()

signal hit(damage: float)


func _on_hit(_damage: float) -> void:
	var anim: = DELETE_ANIMATION.instantiate()
	anim.self_modulate = DELETE_COLORS[sprite_color]
	anim.position = position
	anim.emitting = true
	add_sibling.call_deferred(anim)
	queue_free()
