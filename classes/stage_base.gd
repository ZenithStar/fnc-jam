class_name StageBase extends AnimationPlayer
# a collection of functions to be used with 

@export var prespawn_bosses: Dictionary[String, PackedScene]

var _bosses: Dictionary[String, Area2D]

func _ready() -> void:
	for boss in prespawn_bosses:
		var boss_node: BossBase = prespawn_bosses[boss].instantiate()
		_bosses[boss] = boss_node
		add_child(boss_node)
	play("stage")

func play_dialogic_timeline( timeline : String ):
	pause()
	Dialogic.start_timeline( timeline )
	await Dialogic.timeline_ended
	play()

func play_coroutine(coroutine: String):
	pause()
	await call(coroutine)
	play()
