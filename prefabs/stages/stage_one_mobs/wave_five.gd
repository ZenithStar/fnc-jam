extends Node2D

@export var groups: int = 4
@export var number_per_group: int = 10
@export var flight_duration: = 8.0

@export var big_mob: PackedScene
@export var mobs: Array[PackedScene]
@export var bullet: PackedScene
@export var spread_bullet: PackedScene

func run():
	var bounds: = Global.GAMEPLAY_AREA
	var start_side: = bounds.position.x - 32.0
	var max_height = bounds.position.y + 32.0
	var min_height = max_height + 128.0
	
	for i in groups:
		for j in number_per_group:
			var start := start_side * (-1.0 if randf()> 0.5 else 1.0)
			var end : = start * -1.0
			var height: = randf_range(min_height, max_height)
			var height_displacement:= randf_range(150.0, 300.0)
			var new_mob: Node2D = mobs.pick_random().instantiate()
			new_mob.position = Vector2(start, height)
			new_mob.active = true
			add_child(new_mob)
			
			var tween: = new_mob.create_tween()
			tween.set_parallel()
			tween.tween_callback(fire.bind(new_mob)).set_delay(randf_range(flight_duration/5.0, flight_duration/1.5))
			tween.tween_property(new_mob, "position:x", end, flight_duration)
			tween.set_ease(Tween.EASE_IN)
			tween.set_trans(Tween.TRANS_SINE)
			tween.tween_property(new_mob, "position:y", height+height_displacement, flight_duration/2.0)
			tween.set_ease(Tween.EASE_OUT)
			tween.chain().tween_property(new_mob, "position:y", height, flight_duration/2.0)
			tween.chain().tween_callback(new_mob.queue_free)
			await get_tree().create_timer(0.3).timeout
		
		var start := start_side * (-1.0 if (i%2)==1 else 1.0)
		var end : = start * -1.0
		var height: = randf_range(min_height, max_height)
		var height_displacement:= randf_range(50.0, 100.0)
		var new_mob: Node2D = big_mob.instantiate()
		new_mob.position = Vector2(start, height)
		new_mob.active = true
		add_child(new_mob)
		
		var tween: = new_mob.create_tween()
		tween.set_parallel()
		tween.tween_callback(fire_spread.bind(new_mob)).set_delay(randf_range(flight_duration/5.0, flight_duration/1.5))
		tween.tween_property(new_mob, "position:x", end, flight_duration)
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(new_mob, "position:y", height+height_displacement, flight_duration/2.0)
		tween.set_ease(Tween.EASE_OUT)
		tween.chain().tween_property(new_mob, "position:y", height, flight_duration/2.0)
		tween.set_parallel(false)
		tween.tween_callback(new_mob.queue_free)
		await get_tree().create_timer(0.5).timeout
	


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

func fire_spread( mob: Node2D ):
	match get_tree().get_first_node_in_group("GameServer").difficulty:
		Global.Difficulty.EASY:
			pass
		Global.Difficulty.NORMAL:
			var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position()) - PI/8.0
			for j in 5:
				var new_bullet := bullet.instantiate()
				new_bullet.rotation = direction + (j * PI/16.0)
				new_bullet.position = mob.global_position
				new_bullet.origin = mob.global_position
				get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
			await get_tree().create_timer(0.2).timeout
		Global.Difficulty.HARD:
			for i in 3:
				var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position()) - PI/8.0
				for j in 5:
					var new_bullet := bullet.instantiate()
					new_bullet.rotation = direction + (j * PI/16.0)
					new_bullet.position = mob.global_position
					new_bullet.origin = mob.global_position
					get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(0.2).timeout
		Global.Difficulty.LUNATIC:
			for i in 5:
				var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position()) - PI/8.0
				for j in 5:
					var new_bullet := bullet.instantiate()
					new_bullet.rotation = direction + (j * PI/16.0)
					new_bullet.position = mob.global_position
					new_bullet.origin = mob.global_position
					get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(0.2).timeout
