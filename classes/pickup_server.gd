extends Node2D


func spawn( spawn_position: Vector2, pickups: Dictionary[PackedScene, int] ):
	var pickup_scenes: Array[Node2D] = []
	for pickup in pickups:
		for count in pickups[pickup]:
			pickup_scenes.append( pickup.instantiate() )
	if pickup_scenes:
		var spread: float = sqrt((pickup_scenes.size() - 1.0) * 100.0)
		for pickup in pickup_scenes:
			pickup.position = spawn_position + Vector2.from_angle(randf_range(-PI,PI))*randfn(0,spread)
			add_child.call_deferred(pickup)

func vacuum():
	for child in get_children():
		child.state = Pickup.State.VACUUMING
