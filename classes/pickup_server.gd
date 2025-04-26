extends Area2D

var vacuuming: bool:
	set(value):
		if vacuuming != value:
			vacuuming = value
			if vacuuming:
				for child in get_children():
					if child is Pickup:
						child.state = Pickup.State.VACUUMING
				 

func spawn( spawn_position: Vector2, pickups: Dictionary[PackedScene, int] ):
	var pickup_scenes: Array[Node2D] = []
	for pickup in pickups:
		for count in pickups[pickup]:
			pickup_scenes.append( pickup.instantiate() )
	if pickup_scenes:
		var spread: float = sqrt((pickup_scenes.size() - 1.0) * 100.0)
		for pickup in pickup_scenes:
			pickup.position = spawn_position + Vector2.from_angle(randf_range(-PI,PI))*randfn(0,spread)
			if vacuuming:
				pickup.state = Pickup.State.VACUUMING
			add_child.call_deferred(pickup)

func vacuum():
	for child in get_children():
		if child is Pickup:
			child.state = Pickup.State.VACUUMING

func _on_area_entered(area: Area2D) -> void:
	vacuuming = true


func _on_area_exited(area: Area2D) -> void:
	vacuuming = false
