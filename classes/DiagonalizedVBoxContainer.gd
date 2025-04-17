@tool
class_name DiagonalizedVBoxContainer extends VBoxContainer

@export var diagonal_margin: float = 16.0:
	set(value):
		diagonal_margin = value
		queue_sort()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			var i = 0
			for child in get_children():
				if child is Control:
					child.position.x += diagonal_margin * i 
					i += 1
					
