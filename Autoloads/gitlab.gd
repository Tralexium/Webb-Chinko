extends Node

signal api_key_success(bool)

const API_KEY_POPUP = preload("res://Scenes/UI/api_key_popup.tscn")
var http_request = HTTPRequest.new()
var api_popup = API_KEY_POPUP.instantiate()

# Create an HTTP request node and connect its completion signal.
func _ready() -> void:
	get_tree().root.add_child.call_deferred(http_request)
	get_tree().root.add_child.call_deferred(api_popup)
	http_request.request_completed.connect(self._on_request_completed)
	await http_request.ready
	fetch_api()


func fetch_api() -> void:
	var _access_token : String = Data.data.api_key
	var _api_url := "https://gitlab.com/api/v4/todos"
	var _headers := ["PRIVATE-TOKEN: "+_access_token]
	http_request.request(_api_url, _headers)


func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var _merge_count = _parse_gitlab_response(body)
		print("Number of todos: ", _merge_count)
		Data.set_merge_count(_merge_count)
		emit_signal("api_key_success", true)
		api_popup.hide()
	else:
		print("Error: ", body.get_string_from_utf8())
		emit_signal("api_key_success", false)
		#api_popup.show()


func _parse_gitlab_response(response_body) -> int:
	var _merge_count := 0
	var _todo_json = JSON.parse_string(response_body.get_string_from_utf8())
	if _todo_json == null:
		return 0
	for merge_request in _todo_json:
		if merge_request.target.state == "merged":
			_merge_count += 1
	return _merge_count
