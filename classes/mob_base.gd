extends Area2D

@export var max_health: float = 100.0
@onready var current_health: float = max_health
@export var drops: Dictionary[PackedScene, int]
@export var immune: bool = false
@export var active: bool = false:
	set(value):
		active = value
		if active:
			if is_inside_tree():
				get_tree().get_first_node_in_group("TargetServer").register(self)
			process_mode = Node.PROCESS_MODE_INHERIT
		else:
			if is_inside_tree():
				get_tree().get_first_node_in_group("TargetServer").unregister(self)
			process_mode = Node.PROCESS_MODE_DISABLED

signal hit( damage: float )
signal death

func _ready() -> void:
	if active:
		get_tree().get_first_node_in_group("TargetServer").register(self)
	else:
		process_mode = Node.PROCESS_MODE_DISABLED

func _on_hit( damage: float ):
	current_health -= damage
	if current_health <= 0.0:
		death.emit()

func _on_death( ):
	get_tree().get_first_node_in_group("PickupServer").spawn(global_position, drops)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_signal("hit"):
		area.hit.emit()
