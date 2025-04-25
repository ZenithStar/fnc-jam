class_name TargetServer extends Node

var targets: Dictionary[Area2D, bool]

func register(area: Area2D):
	targets[area] = true
	if not area.tree_entered.is_connected(unregister.bind(area)):
		area.tree_exited.connect(unregister.bind(area))

func unregister(area: Area2D):
	area.tree_exited.disconnect(unregister.bind(area))
	targets.erase(area)

func size() -> int:
	return targets.size()

func pick_random() -> Area2D:
	if targets.size() > 0:
		return targets.keys().pick_random()
	else:
		return null
