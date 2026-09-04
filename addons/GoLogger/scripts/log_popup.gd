extends PopupPanel

@onready var top_bar: Panel = %TopBar
@onready var copy_btn: Button = %CopyButton
@onready var settings_btn: Button = %SettingsButton
@onready var close_btn: Button = %CloseButton

var contents: String = ""

func assign_icons() -> void:
	copy_btn.set_button_icon(get_theme_icon("CopyAction", "EditorIcons"))
	settings_btn.set_button_icon(get_theme_icon("GDScript", "EditorIcons"))
	close_btn.set_button_icon(get_theme_icon("Close", "EditorIcons"))



