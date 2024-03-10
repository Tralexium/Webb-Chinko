class_name Ball
extends RigidBody2D

@export var star_multiplier := 1.0
@export_group("Custom Ball Event")
@export var ball_event : BallEvent = null
@export var time_until_event := 5.0
@export var hits_until_event := 10
@export var event_chance_on_hit := 0.0

var collision_cool_down := 0.2
var collision_min_spd := 100.0

@onready var event_timer: Timer = $EventTimer
@onready var collision_cooldown: Timer = $CollisionCooldown


func _ready() -> void:
	apply_impulse(Vector2(5.0 * randf(), 0.0))
	event_timer.start(time_until_event)


func _trigger_event() -> void:
	if ball_event != null:
		ball_event.on_trigger(self)


func _on_collide_stuff() -> void:
	pass
	# Do vfx here and shit


func _on_body_entered(body: Node) -> void:
	hits_until_event -= 1
	if hits_until_event == 0:
		_trigger_event()
	if event_chance_on_hit > 0.0 and Util.random_chance(event_chance_on_hit):
		_trigger_event()


func _on_event_timer_timeout() -> void:
	_trigger_event()


func _on_pit_collidor_area_entered(area: Area2D) -> void:
	if !collision_cooldown.is_stopped() or linear_velocity.length_squared() < collision_min_spd:
		return
	_on_collide_stuff()
	collision_cooldown.start(collision_cool_down)
