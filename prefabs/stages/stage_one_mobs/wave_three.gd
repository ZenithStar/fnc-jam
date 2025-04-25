extends Node2D

@export var seed: = 420
@export var number: int = 36
@export var ratio: float = 0.75
@export var flight_duration: = 12.0

@export var mob_1: PackedScene
@export var mob_2: PackedScene
@export var bullet: PackedScene


func run():
	var rand: = RandomNumberGenerator.new()
	rand.seed = seed
	rand.state = 0
	var bounds: = Global.GAMEPLAY_AREA
	var start_height: = bounds.position.y - 32.0
	var end_height: = bounds.end.y + 32.0
	var left_bound: = bounds.position.x + 32.0
	var right_bound: = bounds.end.x - 32.0
	
	for i in number:
		var new_mob: Node2D = mob_2.instantiate() if randf() > ratio else mob_1.instantiate()
		new_mob.position = Vector2(randf_range(left_bound,right_bound), start_height)
		new_mob.active = true
		add_child(new_mob)
		
		var tween: = new_mob.create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(new_mob, "position", Vector2(randf_range(left_bound,right_bound), end_height), flight_duration)
		tween.parallel().tween_callback(fire.bind(new_mob)).set_delay(randf_range(flight_duration/5.0, flight_duration/3.0))
		tween.tween_callback(new_mob.queue_free)
		
		await get_tree().create_timer(0.25).timeout
	


func fire(mob: Node2D):
	match get_tree().get_first_node_in_group("GameServer").difficulty:
		Global.Difficulty.EASY:
			pass
		Global.Difficulty.NORMAL:
			var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("Player").global_position)
			var new_bullet := bullet.instantiate()
			new_bullet.rotation = direction
			new_bullet.position = mob.global_position
			new_bullet.origin = mob.global_position
			get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
		Global.Difficulty.HARD:
			for i in 2:
				if not is_instance_valid(mob):
					return # this is required in case the mob dies mid coroutine
				var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("Player").global_position)
				var new_bullet := bullet.instantiate()
				new_bullet.rotation = direction
				new_bullet.position = mob.global_position
				new_bullet.origin = mob.global_position
				get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(0.15).timeout
		Global.Difficulty.LUNATIC:
			for i in 3:
				if not is_instance_valid(mob):
					return
				var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("Player").global_position)
				var new_bullet := bullet.instantiate()
				new_bullet.rotation = direction
				new_bullet.position = mob.global_position
				new_bullet.origin = mob.global_position
				get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(0.15).timeout
