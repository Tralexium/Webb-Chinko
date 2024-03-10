extends Area2D

@export var bounce_force := Vector2(600.0, 0.0)
@export var stars_per_bounce := 10.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	if not body is Ball:
		return
	var ball := body as Ball
	var _dir := global_position.angle_to_point(ball.global_position)
	ball.apply_impulse(bounce_force.rotated(_dir))
	Data.add_stars(stars_per_bounce * ball.star_multiplier)
	animation_player.play("bounce")	
