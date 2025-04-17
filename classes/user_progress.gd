extends Resource

class HiscoreEntry extends Resource:
	@export var score: int
	@export var name: String

@export var hiscores: Array[HiscoreEntry]
