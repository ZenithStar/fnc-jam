extends StageBase

@onready var difficulty: Global.Difficulty = get_tree().get_first_node_in_group("GameServer").difficulty

func post_transition():
	$PreloadSong.queue_free()
	$PreloadSong2.queue_free()
	await BGMServer.fade_to_new(Global.SONGS[Global.Song.STAGE_ONE])
	play("stage")
	$Node3D/AnimationPlayer.play("stage")

const MIDBOSS_SCENE: = preload("uid://cfce3uel3k543")
const MIDBOSS_DROPS: Dictionary[PackedScene, int] = {
	preload("uid://bacvoy2ngo7o0"): 2,
	preload("uid://d2na3s8hp6lby"): 1,
	preload("uid://bhstkjthfyhwc"): 1,
	preload("uid://djw0ru5od7hbm"): 10,
	preload("uid://ct21j5j554co8"): 10,
}

signal proceed

func midboss():
	var mid : = MIDBOSS_SCENE.instantiate()
	mid.active = false
	mid.position = Vector2.ZERO
	mid.max_hp = 700.0
	mid.damage_till_phase = 700.0
	var tween: = mid.create_tween()
	var phase : = func():
		proceed.emit()
	
	mid.phase.connect(phase)
	$Waves/MidbossPath/PathFollow2D.add_child(mid)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Waves/MidbossPath/PathFollow2D, "progress", 540.0, 0.8 )
	tween.tween_callback(get_tree().get_first_node_in_group("BulletServer").clear)
	tween.tween_callback(mid.set.bind(&"active", true))
	tween.tween_interval(0.2)
	var second_tween: Tween
	var start_second_tween: = func():
		second_tween = mid.create_tween()
		second_tween.tween_callback(midboss_secondary.bind(mid)).set_delay(0.25 - (difficulty*0.05))
		second_tween.set_loops()
	tween.tween_callback(start_second_tween)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_parallel()
	var progress: = 540.0
	for i in 15:
		progress += randf_range(200.0, 300.0)
		tween.chain().tween_property($Waves/MidbossPath/PathFollow2D, "progress", progress, 2.0 )
		tween.tween_callback(midboss_ring.bind(mid, Bullet.SpriteColor.RED, PI/32.0))
		if difficulty != Global.Difficulty.EASY:
			tween.tween_callback(midboss_ring.bind(mid, Bullet.SpriteColor.PURPLE, -PI/32.0)).set_delay(1.0)
			if difficulty != Global.Difficulty.NORMAL:
				tween.tween_callback(midboss_ring.bind(mid, Bullet.SpriteColor.YELLOW, PI/16.0)).set_delay(0.5)
				if difficulty != Global.Difficulty.HARD:
					tween.tween_callback(midboss_ring.bind(mid, Bullet.SpriteColor.ORANGE, -PI/16.0)).set_delay(0.75)
	
	tween.finished.connect(phase)
	await proceed
	mid.phase.disconnect(phase)
	tween.finished.disconnect(phase)
	if tween.is_running():
		tween.kill()
	if is_instance_valid(second_tween):
		second_tween.kill()
	
	get_tree().get_first_node_in_group("PickupServer").spawn(mid.global_position, MIDBOSS_DROPS)
	#mid.active = false
	await get_tree().create_timer(0.5).timeout
	get_tree().get_first_node_in_group("PickupServer").vacuum()
	get_tree().get_first_node_in_group("BulletServer").clear()
	await get_tree().create_timer(0.5).timeout 
	tween = mid.create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(mid, "global_position", Vector2(420, -348), 1.5)
	tween.tween_callback($Waves/MidbossPath/PathFollow2D.queue_free)
	Dialogic.start( "stage_one_mid" )
	await Dialogic.timeline_ended

const MIDBOSS_RING_BULLET: = preload("uid://deaotqcr643ci")
const MIDBOSS_RING_DENSITY: = 36
func midboss_ring(mob: Node2D, color: Bullet.SpriteColor, orbit_vel: float):
	var center: = randf_range(-PI,PI)
	for i in MIDBOSS_RING_DENSITY:
		var direction: = center + i * (TAU/MIDBOSS_RING_DENSITY)
		var new_bullet := MIDBOSS_RING_BULLET.instantiate()
		new_bullet.sprite_color = color
		new_bullet.orbit_vel = orbit_vel
		new_bullet.rotation = direction
		new_bullet.position = mob.global_position
		new_bullet.origin = mob.global_position
		get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)

const MIDBOSS_SECONDARY_BULLET: = preload("uid://bb2a3hsmytlvg")
func midboss_secondary(mob: Node2D):
	var new_bullet := MIDBOSS_SECONDARY_BULLET.instantiate()
	new_bullet.sprite_color = [Bullet.SpriteColor.INVERSE_RED, Bullet.SpriteColor.INVERSE_ORANGE, Bullet.SpriteColor.INVERSE_PURPLE, Bullet.SpriteColor.INVERSE_YELLOW].pick_random()
	new_bullet.sprite_type = Bullet.SpriteType.ROUND2
	new_bullet.rotation = randf_range(-PI,PI)
	new_bullet.position = mob.global_position
	new_bullet.origin = mob.global_position
	get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
