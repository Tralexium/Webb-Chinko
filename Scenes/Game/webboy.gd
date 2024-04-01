extends Node3D

# Speed at which the model rotates based on cursor movement
@export var rotation_amnt: float = 0.02
@export var rotation_speed: float = 0.05
@export var click_push_multiplier: float = 2.0
# Target rotation values
var target_rotation_y: float = 0.0
var target_rotation_z: float = 0.0
var mouse_is_inside: bool = false

func _process(delta):
	var viewport_size = get_viewport().size
	var center_position = viewport_size * 0.5
	var cursor_position = get_viewport().get_mouse_position()
	
	# Calculate the difference between the cursor position and the center
	var cursor_offset = center_position - cursor_position
	
	# Determine the target rotation based on the cursor position
	# Adjust these formulas as needed to match the desired effect
	var _click_mult = click_push_multiplier if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else 1.0
	target_rotation_y = -cursor_offset.x * rotation_amnt * _click_mult * float(mouse_is_inside)
	target_rotation_z = cursor_offset.y * rotation_amnt * _click_mult * float(mouse_is_inside)
	
	# Smoothly interpolate (lerp) current rotation towards the target rotation
	rotation_degrees.y = lerp(rotation_degrees.y, target_rotation_y, rotation_speed)
	rotation_degrees.z = lerp(rotation_degrees.z, target_rotation_z, rotation_speed)

func _notification(event):
	match event:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_is_inside = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_is_inside = true
