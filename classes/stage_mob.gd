class_name StageMob extends Path2D
## Some assumptions: the first point of the curve is always at y=0, and y for ever consecutive point is greater than y for the previous
## I won't waste time with some AABB calculation

@export var mob: PackedScene

func spawn() -> void:
	var new_mob: = mob.instantiate()
	$PathFollow2D.add_child(new_mob)
	new_mob.death.connect(queue_free)
