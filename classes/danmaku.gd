class_name Danmaku extends Resource
## All Vector2s represent (radial in px, orbital in rad)


@export var count: Array[int] ## falls back to [0] and then 1

@export var orbital_offset: float
@export var delay: float

# odd counts are aimed and even are anti-aimed
@export var spread: float
@export var radial_velocity_initial: float
@export var radial_velocity_min: float
@export var radial_velocity_max: float
@export var radial_acceleration: float
