extends Node2D

@export var bg_scroll_speed := Vector2(0.0, -20.0)
@onready var parallax_background: ParallaxBackground = $ParallaxBackground


func _process(delta: float) -> void:
	parallax_background.scroll_offset += bg_scroll_speed * delta
