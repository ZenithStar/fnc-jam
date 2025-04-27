extends StageBase

@onready var difficulty: Global.Difficulty = get_tree().get_first_node_in_group("GameServer").difficulty

func post_transition():
	$PreloadSong.queue_free()
	$PreloadSong2.queue_free()
	await BGMServer.fade_to_new(Global.SONGS[Global.Song.STAGE_ONE])
	#play_section(&"stage", 82.0, 86.0)
	play(&"stage")
	$Node3D/AnimationPlayer.play(&"stage")
	#$Waves/TheRestOfTheGame.run()

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
		tween.tween_callback(midboss_ring.bind(mid, Bullet.SpriteColor.RED))
		if difficulty != Global.Difficulty.EASY:
			tween.tween_callback(midboss_ring.bind(mid, Bullet.SpriteColor.PURPLE)).set_delay(1.0)
			if difficulty != Global.Difficulty.NORMAL:
				tween.tween_callback(midboss_ring.bind(mid, Bullet.SpriteColor.YELLOW)).set_delay(0.5)
				if difficulty != Global.Difficulty.HARD:
					tween.tween_callback(midboss_ring.bind(mid, Bullet.SpriteColor.ORANGE)).set_delay(0.75)
	
	tween.finished.connect(phase)
	await proceed
	mid.phase.disconnect(phase)
	tween.finished.disconnect(phase)
	if tween.is_running():
		tween.stop()
		tween.kill()
	if is_instance_valid(second_tween):
		second_tween.kill()
	
	get_tree().get_first_node_in_group("PickupServer").spawn(mid.global_position, MIDBOSS_DROPS)
	#mid.active = false
	await get_tree().create_timer(0.5).timeout
	get_tree().get_first_node_in_group("PickupServer").vacuum()
	get_tree().get_first_node_in_group("BulletServer").clear()
	await get_tree().create_timer(0.5).timeout 
	get_tree().get_first_node_in_group("BulletServer").clear()
	tween = mid.create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(mid, "global_position", Vector2(420, -348), 1.5)
	tween.tween_callback($Waves/MidbossPath/PathFollow2D.queue_free)
	Dialogic.start( "stage_one_mid" )
	await Dialogic.timeline_ended

const MIDBOSS_RING_BULLET: = preload("uid://deaotqcr643ci")
const MIDBOSS_RING_DENSITY: = 36
func midboss_ring(mob: Node2D, color: Bullet.SpriteColor):
	var center: = randf_range(-PI,PI)
	for i in MIDBOSS_RING_DENSITY:
		var direction: = center + i * (TAU/MIDBOSS_RING_DENSITY)
		var new_bullet := MIDBOSS_RING_BULLET.instantiate()
		new_bullet.sprite_color = color
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




func boss():
	get_tree().get_first_node_in_group("PickupServer").vacuum()
	get_tree().get_first_node_in_group("BulletServer").clear()
	
	_bosses["jemma"].position = Vector2(500.0, 0.0)
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(_bosses["jemma"], "position", Vector2(0.0, -300.0), 1.5)
	await tween.finished
	Dialogic.start( "stage_one_boss" )
	await Dialogic.timeline_ended
	
	await nonspell_one()
	await get_tree().create_timer(2.0).timeout
	await spell_one()
	await get_tree().create_timer(2.0).timeout
	await nonspell_two()
	await get_tree().create_timer(2.0).timeout
	await spell_two()
	await get_tree().create_timer(2.0).timeout
	
	
	get_tree().get_first_node_in_group("PickupServer").vacuum()
	get_tree().get_first_node_in_group("BulletServer").clear()
	Dialogic.start( "stage_one_end" )
	await Dialogic.timeline_ended
	_bosses["jemma"].create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).tween_property(_bosses["jemma"], "position", Vector2(600.0, -360.0), 1.0)

const JEMMA_POD_BULLET: = preload("uid://5k0djkw8wc8f")
const JEMMA_ROUND_BULLET: = preload("res://prefabs/bullets/bullet_16x_16.tscn")

func nonspell_one():
	_bosses["jemma"].active = true
	_bosses["jemma"].max_hp = 1500.0
	_bosses["jemma"].damage_till_phase = 1500.0
	var timer: = get_tree().create_timer(45.0)
	
	var bullet_one_tween : = _bosses["jemma"].create_tween()
	var fire_pods: = func ():
		var base_rotation: float  = randf_range(-PI,PI) #_bosses["jemma"].global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position())
		for i in 36:
			var direction: = base_rotation + i * (TAU/36)
			var new_bullet := JEMMA_POD_BULLET.instantiate()
			new_bullet.rotation = direction
			new_bullet.position = _bosses["jemma"].global_position
			new_bullet.origin = _bosses["jemma"].global_position
			get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
	bullet_one_tween.tween_callback(fire_pods).set_delay(2.0-(0.5 * difficulty))
	bullet_one_tween.set_loops()
	
	var other_way: = {"foo": false} # doesn't work as a primitive bool so i stuck it in a dict
	var bullet_two_tween : = _bosses["jemma"].create_tween()
	var bullet_two_colors: = [Bullet.SpriteColor.RED,
							Bullet.SpriteColor.ORANGE,
							Bullet.SpriteColor.YELLOW,
							Bullet.SpriteColor.LIGHT_GREEN,
							Bullet.SpriteColor.CYAN,
							Bullet.SpriteColor.MAGENTA,]
	var fire_rounds: = func ():
		var base_rotation: float = randf_range(-PI,PI)
		for i in 12:
			for j in 5:
				var direction: = base_rotation + i * (TAU/12) + j * (TAU/(12*5))
				var new_bullet := JEMMA_ROUND_BULLET.instantiate()
				new_bullet.rotation = direction
				new_bullet.position = _bosses["jemma"].global_position
				new_bullet.origin = _bosses["jemma"].global_position
				new_bullet.sprite_color = bullet_two_colors[i%6]
				new_bullet.sprite_type = Bullet.SpriteType.STAR
				new_bullet.lin_vel = 200.0
				new_bullet.lin_accel = ((j+1) if other_way["foo"] else (10-j)) * 5.0
				new_bullet.orbit_vel = PI/8.0
				get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
		other_way["foo"] = not other_way["foo"]
		
	bullet_two_tween.tween_callback(fire_rounds).set_delay(4.0-(1.0 * difficulty))
	bullet_two_tween.set_loops()
	
	var movement_tween : = _bosses["jemma"].create_tween()
	var go_places: = func ():
		var go := _bosses["jemma"].create_tween()
		go.set_ease(Tween.EASE_IN_OUT)
		go.set_trans(Tween.TRANS_QUAD)
		go.tween_interval(4.0)
		go.tween_property(_bosses["jemma"], "position", Vector2(randf_range(-200, 200), randf_range(-180,-380)), 4.0)
	movement_tween.tween_callback(go_places).set_delay(8.0)
	movement_tween.set_loops()
	
	
	await Promise.any(Promise.from_many([timer.timeout, _bosses["jemma"].phase])).resolved
	bullet_one_tween.stop()
	bullet_one_tween.kill()
	bullet_two_tween.stop()
	bullet_two_tween.kill()
	movement_tween.stop()
	movement_tween.kill()
	
	_bosses["jemma"].active = false


func nonspell_two():
	get_tree().get_first_node_in_group("BulletServer").clear()
	_bosses["jemma"].active = true
	_bosses["jemma"].max_hp = 1500.0
	_bosses["jemma"].damage_till_phase = 1500.0
	var timer: = get_tree().create_timer(45.0)
	
	var bullet_one_tween : = _bosses["jemma"].create_tween()
	var fire_pods: = func ():
		var base_rotation: float  = randf_range(-PI,PI) #_bosses["jemma"].global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position())
		for i in 36:
			var direction: = base_rotation + i * (TAU/36)
			var new_bullet := JEMMA_POD_BULLET.instantiate()
			new_bullet.rotation = direction
			new_bullet.position = _bosses["jemma"].global_position
			new_bullet.origin = _bosses["jemma"].global_position
			get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
	bullet_one_tween.tween_callback(fire_pods).set_delay(2.0-(0.5 * difficulty))
	bullet_one_tween.set_loops()
	
	var bullet_two_tween : = _bosses["jemma"].create_tween()
	var bullet_two_colors: = [Bullet.SpriteColor.RED,
							Bullet.SpriteColor.ORANGE,
							Bullet.SpriteColor.YELLOW,
							Bullet.SpriteColor.LIGHT_GREEN,
							Bullet.SpriteColor.CYAN,
							Bullet.SpriteColor.MAGENTA,]
	var fire_rounds: = func ():
		var base_rotation: float = randf_range(-PI,PI)
		for i in 12:
			for j in 5:
				var direction: = base_rotation + i * (TAU/12) + j * (TAU/(12*5))
				var new_bullet := JEMMA_ROUND_BULLET.instantiate()
				new_bullet.rotation = direction
				new_bullet.position = _bosses["jemma"].global_position
				new_bullet.origin = _bosses["jemma"].global_position
				new_bullet.sprite_color = bullet_two_colors[i%6]
				new_bullet.sprite_type = Bullet.SpriteType.STAR
				new_bullet.lin_vel = 200.0
				new_bullet.lin_accel = (j+1) * 5.0
				new_bullet.orbit_vel = PI/8.0
				get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
		
	bullet_two_tween.tween_callback(fire_rounds).set_delay(4.0-(1.0 * difficulty))
	bullet_two_tween.set_loops()
	
	var movement_tween : = _bosses["jemma"].create_tween()
	var go_places: = func ():
		var go := _bosses["jemma"].create_tween()
		go.set_ease(Tween.EASE_IN_OUT)
		go.set_trans(Tween.TRANS_QUAD)
		go.tween_interval(4.0)
		go.tween_property(_bosses["jemma"], "position", Vector2(randf_range(-200, 200), randf_range(-180,-380)), 4.0)
	movement_tween.tween_callback(go_places).set_delay(8.0)
	movement_tween.set_loops()
	
	
	await Promise.any(Promise.from_many([timer.timeout, _bosses["jemma"].phase])).resolved
	bullet_one_tween.stop()
	bullet_one_tween.kill()
	bullet_two_tween.stop()
	bullet_two_tween.kill()
	movement_tween.stop()
	movement_tween.kill()
	
	_bosses["jemma"].active = false


const BOSS_ONE_DROPS: Dictionary[PackedScene, int] = {
	preload("uid://bacvoy2ngo7o0"): 5,
	preload("uid://c4pj6ndi2g46v"): 5,
	preload("uid://djw0ru5od7hbm"): 5,
	preload("uid://ct21j5j554co8"): 5,
}

func spell_one():
	await _bosses["jemma"].create_tween().tween_property(_bosses["jemma"], "position", Vector2(0.0, -300.0), 1.0).finished
	get_tree().get_first_node_in_group("BulletServer").clear()
	
	_bosses["jemma"].active = true
	_bosses["jemma"].max_hp = 2000.0
	_bosses["jemma"].damage_till_phase = 2000.0
	var timer: = get_tree().create_timer(60.0)
	
	var bullet_one_tween : = _bosses["jemma"].create_tween()
	var fire_pods: = func ():
		var base_rotation: float  = _bosses["jemma"].global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position())
		for i in 12:
			var direction: = base_rotation + i * (TAU/12)
			var new_bullet := JEMMA_POD_BULLET.instantiate()
			new_bullet.rotation = direction
			new_bullet.lin_vel = 500.0
			new_bullet.position = _bosses["jemma"].global_position
			new_bullet.origin = _bosses["jemma"].global_position
			get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
	bullet_one_tween.tween_callback(fire_pods).set_delay(2.0-(0.5 * difficulty))
	bullet_one_tween.set_loops()
	
	var other_way: = {"foo": false} # doesn't work as a primitive bool so i stuck it in a dict
	var bullet_two_tween : = _bosses["jemma"].create_tween()
	var bullet_two_colors: = [Bullet.SpriteColor.RED,
							Bullet.SpriteColor.ORANGE,
							Bullet.SpriteColor.YELLOW,
							Bullet.SpriteColor.LIGHT_GREEN,
							Bullet.SpriteColor.CYAN,
							Bullet.SpriteColor.MAGENTA,]
	var fire_rounds: = func ():
		var base_rotation: float = randf_range(-PI,PI)
		for i in 6:
			for j in 10:
				var direction: = base_rotation + i * (TAU/6) + j * (TAU/(6*10))
				var new_bullet := JEMMA_ROUND_BULLET.instantiate()
				new_bullet.rotation = direction
				new_bullet.position = _bosses["jemma"].global_position
				new_bullet.origin = _bosses["jemma"].global_position
				new_bullet.sprite_color = bullet_two_colors[i%6]
				new_bullet.sprite_type = Bullet.SpriteType.STAR
				new_bullet.lin_vel = -200.0
				new_bullet.lin_accel = ((j+1) if other_way["foo"] else (10-j)) * 10.0
				new_bullet.orbit_vel = PI/8.0
				get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
		other_way["foo"] = not other_way["foo"]
		
	bullet_two_tween.tween_callback(fire_rounds).set_delay(1.0-(0.2 * difficulty))
	bullet_two_tween.set_loops()
	
	
	await Promise.any(Promise.from_many([timer.timeout, _bosses["jemma"].phase])).resolved
	bullet_one_tween.stop()
	bullet_one_tween.kill()
	bullet_two_tween.stop()
	bullet_two_tween.kill()
	
	_bosses["jemma"].active = false
	get_tree().get_first_node_in_group("PickupServer").spawn(_bosses["jemma"].global_position, BOSS_ONE_DROPS)

const BOSS_TWO_DROPS: Dictionary[PackedScene, int] = {
	preload("uid://d2na3s8hp6lby"): 1,
	preload("uid://bhstkjthfyhwc"): 1,
	preload("uid://djw0ru5od7hbm"): 5,
	preload("uid://ct21j5j554co8"): 5,
}
const RAINDROP_BULLET:=preload("uid://83weowwthtxm")
func spell_two():
	await get_tree().create_timer(2.0).timeout
	await _bosses["jemma"].create_tween().tween_property(_bosses["jemma"], "position:y", -300.0, 1.0).finished
	get_tree().get_first_node_in_group("BulletServer").clear()
	_bosses["jemma"].damage_reduction = 0.02
	_bosses["jemma"].active = true
	_bosses["jemma"].find_child("Umbrella").monitoring = true
	_bosses["jemma"].max_hp = 2000.0
	_bosses["jemma"].damage_till_phase = 2000.0
	var timer: = get_tree().create_timer(90.0)
	
	var bullet_one_tween : = _bosses["jemma"].create_tween()
	
	var fire_pods: = func ():
		var new_bullet := RAINDROP_BULLET.instantiate()
		new_bullet.position = Vector2(randf_range(Global.GAMEPLAY_AREA.position.x, Global.GAMEPLAY_AREA.end.x), Global.GAMEPLAY_AREA.position.y+2.0)
		new_bullet.origin = new_bullet.position
		get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
	bullet_one_tween.tween_callback(fire_pods).set_delay(0.016666)
	bullet_one_tween.set_loops()
	
	await get_tree().create_timer(2.0).timeout
	_bosses["jemma"].damage_reduction = 1.0
	
	var bullet_two_tween : = _bosses["jemma"].create_tween()
	var fire_rounds: = func ():
		var base_rotation: float = _bosses["jemma"].global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position())
		for i in 16:
			var direction: = base_rotation + randfn(0.0, [PI/8.0, PI/64.0 ].pick_random())
			var new_bullet := JEMMA_POD_BULLET.instantiate()
			new_bullet.rotation = direction
			new_bullet.position = _bosses["jemma"].global_position
			new_bullet.origin = _bosses["jemma"].global_position
			new_bullet.lin_vel = randf_range(300.0, 700.0 )
			get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
	bullet_two_tween.tween_callback(fire_rounds).set_delay(3.0-(0.5 * difficulty))
	bullet_two_tween.set_loops()
	
	var movement_tween : = _bosses["jemma"].create_tween()
	var go_places: = func ():
		var go := _bosses["jemma"].create_tween()
		go.set_ease(Tween.EASE_IN_OUT)
		go.set_trans(Tween.TRANS_QUAD)
		go.tween_interval(4.0)
		go.tween_property(_bosses["jemma"], "position", Vector2(randf_range(-200, 200), randf_range(-100,-200)), 4.0)
	movement_tween.tween_callback(go_places).set_delay(6.0)
	movement_tween.set_loops()
	
	
	await Promise.any(Promise.from_many([timer.timeout, _bosses["jemma"].phase])).resolved
	bullet_one_tween.stop()
	bullet_one_tween.kill()
	bullet_two_tween.stop()
	bullet_two_tween.kill()
	movement_tween.stop()
	movement_tween.kill()
	
	get_tree().get_first_node_in_group("BulletServer").clear()
	_bosses["jemma"].find_child("Umbrella").monitoring = false
	_bosses["jemma"].active = false
	get_tree().get_first_node_in_group("PickupServer").spawn(_bosses["jemma"].global_position, BOSS_TWO_DROPS)
