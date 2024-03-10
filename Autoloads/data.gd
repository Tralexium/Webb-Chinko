extends Node

signal data_loaded
signal data_saved
signal stars_changed(new_stars, new_total)
signal balls_changed(new_balls)

const SAVE_FILE_PATH := "user://webb_chinko.save"
var data := {
	# Counters
	"stars": 0,
	"total_stars": 0,
	"balls": 0,
	
	# Proggression
	"score_to_orbs_ratio": 10.0,
	"balls_per_merge_min": 1,
	"balls_per_merge_max": 3,
	"ball_selection": ball_selection,
	
	# Gitlab API
	"merge_count": 0,
	"api_key": "",
}

# Name: spawn chance (0 - 1)
# A ball will be randomly chosen along with a dice roll
# If the dice roll isn't lower than the chance, replace it
# with a basic ball.
var ball_selection := {
	"basic": 1.0,
}


func _ready() -> void:
	load_game()


func load_game() -> void:
	var _save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if _save_file == null:
		save_game()
	else:
		data = JSON.parse_string(_save_file.get_line())
		data_loaded.emit()


func save_game() -> void:
	var _save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	var _json_string = JSON.stringify(data)
	_save_file.store_line(_json_string)
	data_saved.emit()


# SETTERS
func add_stars(_val:float, _save:bool = true) -> void:
	_val = round(_val)
	data.stars += _val
	data.total_stars += _val
	stars_changed.emit(data.stars, data.total_stars)
	if _save:
		save_game()


func add_balls(_val:int, _save:bool = true) -> void:
	data.balls += _val
	balls_changed.emit(data.balls)
	if _save:
		save_game()


func add_ball_kind(_name:String, _chance:float) -> void:
	data.ball_selection[_name] = _chance
	save_game()


func set_merge_count(_val:int) -> void:
	# Add balls if we have new git merges
	var _merge_dif = max(0, _val - data.merge_count)
	var _balls_to_add = randi_range(data.balls_per_merge_min, data.balls_per_merge_max) * _merge_dif
	if _balls_to_add > 0:
		add_balls(_balls_to_add, false)
	# Now update and save the current count
	data.merge_count += _val
	save_game()
