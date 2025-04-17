extends Area2D

@export var max_health: float = 100.0
@onready var current_health: float = max_health
@export var drops: Dictionary[PackedScene, int]

signal hit( damage: float )
signal death


func on_hit( damage: float ):
	current_health -= damage
	if current_health <= 0.0:
		death.emit()


func on_death( ):
	get_tree().get_first_node_in_group("PickupServer").spawn(global_position, drops)
	queue_free()
