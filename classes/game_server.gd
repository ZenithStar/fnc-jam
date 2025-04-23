extends Node2D

@export var difficulty: Global.Difficulty = Global.Difficulty.NORMAL
@export var player_scene: PackedScene = Global.CHARACTER_SCENES[Global.Character.FLANDRE_A]
@export var stage_scene: PackedScene = preload("uid://ji0yg461mfxp")


@export var score: int = 0
@export var lives: int = 2
@export var life_shards: int = 0:
	set(value):
		life_shards = value
		while life_shards >= 3:
			life_shards -= 3
			lives += 1
			life_up.emit()
@export var bombs: int = 3
@export var bomb_shards: int = 0:
	set(value):
		bomb_shards = value
		while bomb_shards >= 3:
			bomb_shards -= 3
			bombs += 1
			bomb_up.emit()
@export var power: float = 1.0:
	set(value):
		var prev: = power
		power = clampf(value, 1.0, 5.0)
		if floorf(power) != floorf(prev):
			power_up.emit()
			if power == 5.0:
				full_power.emit()

var player: Player
var stage: StageBase

func _ready() -> void:
	spawn_player()
	
	stage = stage_scene.instantiate()
	add_child(stage)
	

signal pickup( type: Pickup.Type )

signal score_gained( gains: int )

# Connect these to some sound effects
signal life_up
signal bomb_up
signal power_up
signal full_power

func _on_pickup( type: Pickup.Type ):
	match type:
		Pickup.Type.SMALL_POWER:
			power += 0.01
		Pickup.Type.LARGE_POWER:
			power += 0.1
		Pickup.Type.FULL_POWER:
			power = 5.0
		Pickup.Type.SMALL_POINT:
			var gains: = 1000 # TODO: point acceleration system
			score += gains
			score_gained.emit(gains)
		Pickup.Type.LARGE_POINT:
			var gains: = 1000 # TODO: point acceleration system
			score += gains
			score_gained.emit(gains)
		Pickup.Type.LIFE_SHARD:
			life_shards += 1
		Pickup.Type.BOMB_SHARD:
			bomb_shards += 1

var _player_spawn_tween: Tween
func spawn_player():
	player = player_scene.instantiate()
	player.position = $PlayerSpawnBegin.position
	add_child(player)
	player.tree_exited.connect(_on_player_tree_exited)
	_player_spawn_tween = create_tween()
	_player_spawn_tween.set_ease(Tween.EASE_OUT)
	_player_spawn_tween.set_trans(Tween.TRANS_SINE)
	_player_spawn_tween.tween_property(player, "position", $PlayerSpawnEnd.position, 1.0)
	_player_spawn_tween.tween_callback(player.set.bind(&"controlable", true))


func _on_player_tree_exited():
	if lives > 0:
		lives -= 1
		spawn_player()
	else:
		pass # TODO: game over screen
