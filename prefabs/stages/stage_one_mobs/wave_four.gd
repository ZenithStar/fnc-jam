extends Node2D


@export var mob_1: PackedScene
@export var bullet_1: PackedScene
@export var bullet_2: PackedScene

const MOB_CENTER_DROPS: Dictionary[PackedScene, int] = {
	preload("uid://bacvoy2ngo7o0"): 2,
	preload("uid://djw0ru5od7hbm"): 10,
	preload("uid://ct21j5j554co8"): 10,
}
const MOB_LEFT_DROPS: Dictionary[PackedScene, int] = {
	preload("uid://d2na3s8hp6lby"): 1,
	preload("uid://djw0ru5od7hbm"): 10,
	preload("uid://ct21j5j554co8"): 10,
}
const MOB_RIGHT_DROPS: Dictionary[PackedScene, int] = {
	preload("uid://bhstkjthfyhwc"): 1,
	preload("uid://djw0ru5od7hbm"): 10,
	preload("uid://ct21j5j554co8"): 10,
}

func run():
	var bounds: = Global.GAMEPLAY_AREA
	var start_height: = bounds.position.y - 32.0
	
	var mob_center: Node2D = mob_1.instantiate()
	mob_center.position = Vector2(0.0, start_height)
	mob_center.drops = MOB_CENTER_DROPS
	mob_center.active = true
	add_child(mob_center)
	
	var tween: = mob_center.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(mob_center, "position:y", -160.0, 4.0)
	tween.tween_callback(fire_ring.bind(mob_center))
	tween.tween_callback(fire_blast.bind(mob_center))
	tween.tween_interval(12.0)
	tween.tween_property(mob_center, "position:y", start_height, 8.0)
	tween.tween_callback(mob_center.queue_free)
		
	await get_tree().create_timer(12.0).timeout
	
	var mob_left: Node2D = mob_1.instantiate()
	mob_left.position = Vector2(-240.0, start_height)
	mob_left.drops = MOB_LEFT_DROPS
	mob_left.active = true
	add_child(mob_left)
	
	var tween_left: = mob_left.create_tween()
	tween_left.set_ease(Tween.EASE_OUT)
	tween_left.set_trans(Tween.TRANS_QUAD)
	tween_left.tween_property(mob_left, "position:y", -240.0, 4.0)
	tween_left.tween_callback(fire_ring.bind(mob_left))
	tween_left.tween_callback(fire_blast.bind(mob_left))
	tween_left.tween_interval(12.0)
	tween_left.tween_property(mob_left, "position:y", start_height, 8.0)
	tween_left.tween_callback(mob_left.queue_free)
	
	var mob_right: Node2D = mob_1.instantiate()
	mob_right.position = Vector2(240.0, start_height)
	mob_right.drops = MOB_RIGHT_DROPS
	mob_right.active = true
	add_child(mob_right)
	
	var tween_right: = mob_right.create_tween()
	tween_right.set_ease(Tween.EASE_OUT)
	tween_right.set_trans(Tween.TRANS_QUAD)
	tween_right.tween_property(mob_right, "position:y", -240.0, 4.0)
	tween_right.tween_callback(fire_ring.bind(mob_right))
	tween_right.tween_callback(fire_blast.bind(mob_right))
	tween_right.tween_interval(12.0)
	tween_right.tween_property(mob_right, "position:y", start_height, 8.0)
	tween_right.tween_callback(mob_right.queue_free)


const RING_DENSITY: = 48
func fire_ring(mob: Node2D):
	match get_tree().get_first_node_in_group("GameServer").difficulty:
		Global.Difficulty.EASY:
			for i in 4:
				if not is_instance_valid(mob):
					return # this is required in case the mob dies mid coroutine
				for j in RING_DENSITY/2:
					var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position()) + (PI/RING_DENSITY*2.0) + j * (TAU/RING_DENSITY*2.0)
					var new_bullet := bullet_1.instantiate()
					new_bullet.rotation = direction
					new_bullet.position = mob.global_position
					new_bullet.origin = mob.global_position
					get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(3.2).timeout
		Global.Difficulty.NORMAL:
			for i in 8:
				if not is_instance_valid(mob):
					return # this is required in case the mob dies mid coroutine
				for j in RING_DENSITY:
					var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position()) + (PI/RING_DENSITY) + j * (TAU/RING_DENSITY)
					var new_bullet := bullet_1.instantiate()
					new_bullet.rotation = direction
					new_bullet.position = mob.global_position
					new_bullet.origin = mob.global_position
					get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(1.6).timeout
		Global.Difficulty.HARD:
			for i in 16:
				if not is_instance_valid(mob):
					return # this is required in case the mob dies mid coroutine
				for j in RING_DENSITY:
					var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position()) + (PI/RING_DENSITY) + j * (TAU/RING_DENSITY)
					var new_bullet := bullet_1.instantiate()
					new_bullet.rotation = direction
					new_bullet.position = mob.global_position
					new_bullet.origin = mob.global_position
					get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(.8).timeout
		Global.Difficulty.LUNATIC:
			for i in 32:
				if not is_instance_valid(mob):
					return # this is required in case the mob dies mid coroutine
				for j in RING_DENSITY:
					var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position()) + (PI/RING_DENSITY) + j * (TAU/RING_DENSITY)
					var new_bullet := bullet_1.instantiate()
					new_bullet.rotation = direction
					new_bullet.position = mob.global_position
					new_bullet.origin = mob.global_position
					get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(.4).timeout

const CLUSTER_DENSITY: = 3
const CLUSTER_SPREAD:= PI/128.0
func fire_blast(mob: Node2D):
	match get_tree().get_first_node_in_group("GameServer").difficulty:
		Global.Difficulty.EASY:
			for i in 3:
				if not is_instance_valid(mob):
					return # this is required in case the mob dies mid coroutine
				for j in CLUSTER_DENSITY:
					for k in 2:
						var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position()) + j * CLUSTER_SPREAD * (-1.0 if k else 1.0)
						var new_bullet := bullet_2.instantiate()
						new_bullet.rotation = direction
						new_bullet.position = mob.global_position
						new_bullet.origin = mob.global_position
						new_bullet.lin_vel -= 5.0*j
						get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(4.0).timeout
		Global.Difficulty.NORMAL:
			for i in 6:
				if not is_instance_valid(mob):
					return # this is required in case the mob dies mid coroutine
				for j in CLUSTER_DENSITY:
					for k in 2:
						var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position()) + j * CLUSTER_SPREAD * (-1.0 if k else 1.0)
						var new_bullet := bullet_2.instantiate()
						new_bullet.rotation = direction
						new_bullet.position = mob.global_position
						new_bullet.origin = mob.global_position
						new_bullet.lin_vel -= 5.0*j
						get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(2.0).timeout
		Global.Difficulty.HARD:
			for i in 8:
				if not is_instance_valid(mob):
					return # this is required in case the mob dies mid coroutine
				for j in CLUSTER_DENSITY:
					for k in 2:
						var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position()) + j * CLUSTER_SPREAD * (-1.0 if k else 1.0)
						var new_bullet := bullet_2.instantiate()
						new_bullet.rotation = direction
						new_bullet.position = mob.global_position
						new_bullet.origin = mob.global_position
						new_bullet.lin_vel -= 5.0*j
						get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(1.5).timeout
		Global.Difficulty.LUNATIC:
			for i in 12:
				if not is_instance_valid(mob):
					return # this is required in case the mob dies mid coroutine
				for j in CLUSTER_DENSITY:
					for k in 2:
						var direction: = mob.global_position.angle_to_point(get_tree().get_first_node_in_group("GameServer").get_player_position()) + j * CLUSTER_SPREAD * (-1.0 if k else 1.0)
						var new_bullet := bullet_2.instantiate()
						new_bullet.rotation = direction
						new_bullet.position = mob.global_position
						new_bullet.origin = mob.global_position
						new_bullet.lin_vel -= 5.0*j
						get_tree().get_first_node_in_group("BulletServer").add_child.call_deferred(new_bullet)
				await get_tree().create_timer(1.0).timeout
