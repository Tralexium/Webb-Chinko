extends Panel

@onready var line_edit: LineEdit = %LineEdit
@onready var button: Button = %Button


func _ready() -> void:
	hide()
	Gitlab.api_key_success.connect(self._on_api_key_success)


func _on_api_key_success(_is_successful) -> void:
	if line_edit.text == "" or !_is_successful:
		if visible:
			line_edit.placeholder_text = "Invalid Access Token!"
		line_edit.text = ""
	else:
		Data.save_game()


func _on_button_pressed() -> void:
	Data.data.api_key = line_edit.text
	Gitlab.fetch_api()
