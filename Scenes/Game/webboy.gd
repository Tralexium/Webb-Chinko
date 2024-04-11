extends Node3D

# Speed at which the model rotates based on cursor movement
@export var rotation_amnt: float = 0.02
@export var rotation_speed: float = 0.05
@export var click_push_multiplier: float = 2.0
@export var hover_outline_girth: float = 4.0
# Target rotation values
var target_rotation_y: float = 0.0
var target_rotation_z: float = 0.0
var mouse_is_inside: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var d_pad: MeshInstance3D = $DPad


func _process(delta):
	var _viewport_size = get_viewport().size
	var _center_position = _viewport_size * 0.5
	var _cursor_position = get_viewport().get_mouse_position()
	
	# Calculate the difference between the cursor position and the center
	var _cursor_offset = _center_position - _cursor_position
	
	# Determine the target rotation based on the cursor position
	# Adjust these formulas as needed to match the desired effect
	var _click_mult = click_push_multiplier if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else 1.0
	target_rotation_y = -_cursor_offset.x * rotation_amnt * _click_mult * float(mouse_is_inside)
	target_rotation_z = _cursor_offset.y * rotation_amnt * _click_mult * float(mouse_is_inside)
	
	# Smoothly interpolate (lerp) current rotation towards the target rotation
	rotation_degrees.y = lerp(rotation_degrees.y, target_rotation_y, rotation_speed)
	rotation_degrees.z = lerp(rotation_degrees.z, target_rotation_z, rotation_speed)

func _notification(event):
	match event:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_is_inside = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_is_inside = true


func _on_dpad_mouse_entered() -> void:
	d_pad.material_overlay.set_shader_parameter("outline_width", hover_outline_girth)

func _on_dpad_mouse_exited() -> void:
	d_pad.material_overlay.set_shader_parameter("outline_width", 0.0)

func _on_dpad_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	var _mouse_direction = position - d_pad.global_position
	var _angle = atan2(_mouse_direction.y, _mouse_direction.z)
	if _angle < 0.0:
		_angle += TAU
	_angle = fmod(rad_to_deg(_angle) + 45.0, 360.0)
	print(_angle)
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			animation_player.stop()
			if _angle >= 0.0 and _angle < 90.0:
				animation_player.play("dpad_left")
			elif _angle >= 90.0 and _angle < 180.0:
				animation_player.play("dpad_up")
			elif _angle >= 180.0 and _angle < 270.0:
				animation_player.play("dpad_right")
			elif _angle >= 270.0 and _angle < 360.0:
				animation_player.play("dpad_down")
