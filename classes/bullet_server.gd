extends Node2D

func clear():
	for child in get_children():
		if child.has_signal(&"hit"):
			child.hit.emit()
