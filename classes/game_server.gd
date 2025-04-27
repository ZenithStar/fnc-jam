extends Node2D

@export var difficulty: Global.Difficulty = Global.Difficulty.NORMAL
@export var player_scene: PackedScene = Global.CHARACTER_SCENES[Global.Character.FLANDRE_A]
@export var stage_scene: PackedScene = preload("uid://ji0yg461mfxp")

var score_tween: Tween

@export var score: int = 0
@export var lives: int = 2
@export var life_shards: int = 0:
	set(value):
		life_shards = value
		while life_shards >= 3:
			life_shards -= 3
			lives += 1
			life_up.emit()
@export var base_bombs: int = 3
@export var bombs: int = 3:
	set(value):
		if bombs != value:
			bombs = value
			bombs_changed.emit()
@export var bomb_shards: int = 0:
	set(value):
		bomb_shards = value
		while bomb_shards >= 3:
			bomb_shards -= 3
			bombs += 1
@export var power: float = 1.0:
	set(value):
		var prev: = power
		power = clampf(value, 1.0, 4.0)
		if floorf(power) != floorf(prev):
			power_up.emit()
			if power == 4.0:
				full_power.emit()

@export var point: int = 0
@export var graze: int = 0

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
signal bombs_changed
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
			gains += randi_range(0,100)*10 # lol just make shit up
			point += 1
			score += gains
			score_gained.emit(gains)
		Pickup.Type.LARGE_POINT:
			var gains: = 1000 # TODO: point acceleration system
			point += 10
			score += gains
			score_gained.emit(gains)
		Pickup.Type.LIFE_SHARD:
			life_shards += 1
		Pickup.Type.BOMB_SHARD:
			bomb_shards += 1

var _load_spawn_hack: = true

var _player_spawn_tween: Tween
func spawn_player():
	player = player_scene.instantiate()
	player.position = $PlayerSpawnBegin.position
	if _load_spawn_hack: # don't grant immune time on the very first spawn
		player._immune_time = INF
		_load_spawn_hack = false
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
		bombs = base_bombs
		spawn_player()
	else:
		# TODO: game over screen - just keep respawning for now
		lives -= 1
		bombs = base_bombs
		spawn_player()

func get_player_position() -> Vector2:
	return player.position if is_instance_valid(player) else $PlayerSpawnEnd.position
