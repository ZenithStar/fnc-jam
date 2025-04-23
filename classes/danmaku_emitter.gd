class_name DanmakuEmitter extends Node2D

enum AimMode{
	AIMED, ## records the player position for the first bullet and 
	TRACKING, ## aims at the player position for each bullet
	FIXED,
}
@export var aim_mode: AimMode = AimMode.AIMED
@export var bullet: PackedScene
@export var danmaku: Danmaku
@export var counts: Dictionary[Global.Difficulty, int] = {
	Global.Difficulty.EASY: 0,
	Global.Difficulty.NORMAL: 1,
	Global.Difficulty.HARD: 2,
	Global.Difficulty.LUNATIC: 3,
}

func fire():
	var waves: = counts[get_tree().get_first_node_in_group("GameServer").difficulty]
	for wave in waves:
		var fan: int = danmaku.count[wave] if wave < danmaku.count.size() else danmaku.count[0] if danmaku.count.size() > 0 else 1
		for i in fan:
			var new_bullet: Node = bullet.instantiate()
			var tween : Tween = bullet.create_tween()
		if danmaku.delay > 0.0:
			await get_tree().create_timer(danmaku.delay).timeout
