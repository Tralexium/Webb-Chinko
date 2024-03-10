extends Node


func spawn_ball(_name:String = "") -> Ball:
	var _ball_scenes := Globals.ball_scenes
	var _balls_available := Data.ball_selection
	var _chosen_ball := "basic"
	if _balls_available.has(_name):
		_chosen_ball = _name
	else:
		var _rand_ball = _balls_available.keys().pick_random()
		if random_chance(_balls_available[_rand_ball]):
			_chosen_ball = _rand_ball
	return _ball_scenes[_chosen_ball].instantiate()


func random_chance(_val:float) -> bool:
	return randf() < _val
