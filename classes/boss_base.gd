class_name BossBase extends Area2D
## Typically spawned by a Stage animation player
signal release ## notifies the animation player to continue
signal phase

@export var phases_remaining: int ## this is purely for display purposes. phasing is handled in the coroutine
@export var max_hp: float = 10000.0:
	set(value):
		max_hp = value
		$ProgressBar.max_value = max_hp
@export var damage_till_phase: float = 0.0:
	set(value):
		var last_damage: = damage_till_phase
		damage_till_phase = value
		if last_damage > 0.0 and damage_till_phase <= 0.0:
			phase.emit()
		if damage_till_phase > 0.0:
			$ProgressBar.value = damage_till_phase
			$ProgressBar.visible = true
		else:
			$ProgressBar.visible = false
@export var damage_reduction: = 1.0

@export var active: bool = false:
	set( value ):
		if active != value:
			active = value
			set_deferred("monitorable", active)
			if not active:
				#position = Vector2(10000.0, 10000.0) #teleport far away
				get_tree().get_first_node_in_group("TargetServer").unregister(self)
			else:
				get_tree().get_first_node_in_group("TargetServer").register(self)

@export var root_damage_reduction: float = 0.5 # this'll make big hits significantly weaker

func _init() -> void:
	position = Vector2(10000.0, 10000.0) # spawn it way off screen by default

func _ready() -> void:
	pass # register to boss health UI elements

signal hit( damage: float )

func _on_hit( damage: float ):
	damage_till_phase -= pow(damage, root_damage_reduction) * damage_reduction
