@tool
extends TabContainer

# Adding a new setting:
	# Add the settings to all appropriate dictionaries in "settings_dict"
	# In _ready(), add the settings control node to btn_array so it's included in the uniform signal connections loop
	# If setting requires a Container node to show tooltips(as is the case for most) add the container node to container_array and add the appropriate index in the corresponding_lbls array for the font color changes on mouse hover
	# Implement the logic for applying the setting in signal function like _on_button_button_up()

# TODO:
	# Implement a print_rich() calls whenever a setting is changed to notify the user of the change in the output console.
	# [Done]Add new setting for the custom header format called "log_header_fomat" to the config file creation, saving and loading logic <see Log.gd _get_header() for reference>
	#
	# DOCK CATEGORY TAB:
		# [DONE] Remove 'category index' entirely in favor of using strings as unique identifiers for categories with regards to the new .ini format
		# [DONE] Handle adding/removing categories with new .ini format
		# [DONE] is_locked property handling
		# [DONE] Account for ConfigFile clobbering
		# [DONE] Check that renaming a category adds an int to the name
		# [DONE] Change Entry Format default settings value to: "[{hh}:{mi}:{ss}] <{instance_id}>: {entry}"
		# [DONE] Remove instance_id tags from Header settings since files aren't per-instance anymore
		# [DONE] Apply log header format button not disabling when using enter key to submit text
		# [DONE] When adding a new category, "file_name", "file_path" and "entry_count" keys are missing from the section(not critical but should be added for consistency)
		# [DONE]Changing a category name needs to erase the old category data in the .ini file to prevent bloat
		# Changing settings during runtime will overwrite category data in the .ini file with blank values

	# DOCK SETTINGS TAB:
		# [DONE] ID overlay:
			# Color setting for the overlay text
			# Toggle setting to show/hide overlay
			# Startup state setting to determine whether the overlay is shown on editor startup or only when toggled with the hotkey
			# Font size doesn't load it's settings value properly?

# RELEASE CHECKLIST:
	# Ensure proper tab states - CATEGORIES tab - Getting Started	in Help tab
	# Check font highlighting on mouse over for settings tab
	# Check print history works as expected
	# Check Category:
		# Category section is added to .ini file after naming a new category
		# Old category section is removed from .ini file after renaming a category
		# Category section is removed from .ini file after deleting a category
	# Check LogCategory:
		# Renaming a category adds an int to the name
		# Reordering categories works
		# Locking & Deletion
		# Marking as default
	# Check that settings tooltips remain uniform between the buttons and their containers:
		# There are two nodes per setting ( the container + the control( button/line edit/spin box ) )
		# Both nodes should have the same tooltip text
	# Ensure ConfigFile updates properly with:
		# Applying name
		# Adding category
		# Removing category
		# Reordering categories
		# Changing settings values
		# No type mismatching with the values of the settings and the 'expected_types' dict

signal update_index
signal change_category_name_finished
signal open_hotkey_resource()
var resource_name: Resource = load("res://resource_path")
@onready var categories_tab: MarginContainer = %Categories
@onready var _add_category_btn: Button = %AddCategoryButton
@onready var category_container: GridContainer = %CategoryGridContainer
@onready var open_dir_btn: Button = %OpenDirCatButton
@onready var cat_del_warn_rlbl: RichTextLabel = %CatDelWarningRLabel

@onready var column_slider: HSlider = %ColumnsHSlider
@onready var reset_settings_btn: Button = %ResetSettingsButton

@onready var base_dir_line: LineEdit = %BaseDirLineEdit
@onready var base_dir_lbl: Label = %BaseDirLabel
@onready var base_dir_apply_btn: Button = %BaseDirApplyButton
@onready var base_dir_opendir_btn: Button = %BaseDirOpenDirButton
@onready var base_dir_reset_btn: Button = %BaseDirResetButton
@onready var base_dir_container: HBoxContainer = %BaseDirHBox

@onready var log_header_line: LineEdit = %LogHeaderLineEdit
@onready var log_header_lbl: Label = %LogHeaderLabel
@onready var log_header_apply_btn: Button = %LogHeaderApplyButton
@onready var log_header_reset_btn: Button = %LogHeaderResetButton
@onready var log_header_container: HBoxContainer = %LogHeaderHBox

@onready var entry_format_line: LineEdit = %EntryFormatLineEdit
@onready var entry_format_lbl: Label = %EntryFormatLabel
@onready var entry_format_apply_btn: Button = %EntryFormatApplyButton
@onready var entry_format_reset_btn: Button = %EntryFormatResetButton
@onready var entry_format_warning: Panel = %EntryFormatWarning
@onready var entry_format_container: HBoxContainer = %EntryFormatHBox

@onready var autostart_btn: CheckButton = %AutostartCheckButton
@onready var utc_btn: CheckButton = %UTCCheckButton

@onready var limit_method_btn: OptionButton = %LimitMethodOptButton
@onready var limit_method_lbl: Label = %LimitMethodLabel
@onready var limit_method_container: HBoxContainer = %LimitMethodHBox

@onready var entry_count_action_btn: OptionButton = %EntryActionOptButton
@onready var entry_count_action_lbl: Label = %EntryActionLabel
@onready var entry_count_action_container: HBoxContainer = %EntryCountActionHBox

@onready var session_timer_action_btn: OptionButton = %SessionTimerActionOptButton
@onready var session_timer_action_lbl: Label = %SessionTimerActionLabel
@onready var session_timer_action_container: HBoxContainer = %SessionTimerActionHBox

var file_count_spinbox_line: LineEdit
@onready var file_count_spinbox: SpinBox = %FileCountSpinBox
@onready var file_count_lbl: Label = %FileCountLabel
@onready var file_count_container: HBoxContainer = %FileCountHBox

var entry_count_spinbox_line: LineEdit
@onready var entry_count_spinbox: SpinBox = %EntryCountSpinBox
@onready var entry_count_lbl: Label = %EntryCountLabel
@onready var entry_count_container: HBoxContainer = %EntryCountHBox

var session_duration_spinbox_line: LineEdit
@onready var session_duration_spinbox: SpinBox = %SessionDurationHBox/SessionDurationSpinBox
@onready var session_duration_lbl: Label = %SessionDurationLabel
@onready var session_duration_container: HBoxContainer = %SessionDurationHBox

@onready var error_rep_btn: OptionButton = %ErrorRepOptButton
@onready var error_rep_lbl: Label = %ErrorRepLabel
@onready var error_rep_container: HBoxContainer = %ErrorRepHBox

@onready var plugin_version_cat_lbl: Label = %PluginVersionCatLabel
@onready var plugin_version_sett_lbl: Label = %PluginVersionSettLabel

@onready var open_hotkey_btn: Button = %OpenHotkeyButton

@onready var print_instance_id_btn: CheckButton = %PrintInstanceIDCheckButton
@onready var id_overlay_font_size_hbox: HBoxContainer = %IDOverlayFontSizeHBox
@onready var id_overlay_example_lbl: RichTextLabel = %IDOverlayExampleLabel

@onready var id_overlay_align_container: HBoxContainer = %IDOverlayAlignHBox
@onready var id_overlay_align_opt_btn: OptionButton = %IDOverlayAlignOptButton
@onready var id_overlay_align_lbl: Label = %IDOverlayAlignLabel

var id_overlay_font_size_spinbox_line: LineEdit
@onready var id_overlay_font_size_spinbox: SpinBox = %IDOverlayFontSizeSpinBox
@onready var id_overlay_font_size_lbl: Label = %IDOverlayFontSizeLabel
@onready var id_overlay_toggle_btn: CheckButton = %IDOverlayToggleShowCheckButton
@onready var id_overlay_startup_btn: CheckButton = %ShowOnStartupInstanceIDCheckButton
@onready var id_overlay_font_col_btn: ColorPickerButton = %IDOverlayFontColorColorPickerButton
@onready var id_overlay_font_col_lbl: Label = %IDOverlayFontColorLabel
@onready var id_overlay_font_col_container: HBoxContainer = %IDOverlayFontColorHBox

var id_overlay_outline_size_spinbox_line: LineEdit
@onready var id_overlay_outline_size_hbox: HBoxContainer = %IDOverlayOutlineSizeHBox
@onready var id_overlay_outline_size_spinbox: SpinBox = %IDOverlayOutlineSizeSpinBox
@onready var id_overlay_outline_size_lbl: Label = %IDOverlayOutlineSizeLabel
@onready var id_overlay_outline_col_btn: ColorPickerButton = %IDOverlayOutlineColorColorPickerButton
@onready var id_overlay_outline_col_lbl: Label = %IDOverlayOutlineColorLabel
@onready var id_overlay_outline_col_container: HBoxContainer = %IDOverlayOutlineColorHBox


@onready var help_tab_container: TabContainer = %HelpTabContainer
@onready var user_dir_btn: Button = %UserDirButton
@onready var cat_top_bar: Panel = %TopBarPanel
@onready var general_fold_cont: FoldableContainer = %GeneralFoldableContainer
@onready var limit_fold_cont: FoldableContainer = %LimitationsFoldableContainer
@onready var id_overlay_fold_cont: FoldableContainer = %IDOverlayFoldableContainer

@onready var settings = EditorInterface.get_editor_settings()
@onready var editor_base_col: Color = settings.get("interface/theme/base_color")
@onready var editor_accent_col: Color = settings.get("interface/theme/accent_color")
@onready var editor_contrast: float = settings.get("interface/theme/accent_color")


# var sb_line_edit_normal = preload("uid://pue22dsifmfd")
# var sb_line_edit_highlight = preload("uid://dl1ay0wubtp2m")


# var stylebox_tab_bar_bg = preload("uid://bp0510ij2p7l4")
# var stylebox_tab_bar_hovered = preload("uid://27e5r3ya7lul")
# var stylebox_tab_bar_selected = preload("uid://bygsbmlyeaqdj")
# var stylebox_tab_bar_unselected = preload("uid://dycqh7cqtjy4s")
# var stylebox_cat_topbar_panel = preload("uid://df7sl23ox7q6")

# var stylebox_fold_cont_title_panel = preload("uid://cx8jchknob0px")
# var stylebox_fold_cont_hover_panel = preload("uid://cc42b0ogwbi6p")
# var stylebox_fold_cont_collapsed_panel = preload("uid://o2iplj744aa1")
# var stylebox_fold_cont_collapsed_hover = preload("uid://cjvhvvsskpw3m")

# var stylebox_opt_btn_normal 	= preload("uid://btk0m0my1jv7b")
# var stylebox_opt_btn_hover 		= preload("uid://3b4n4duo7pak")


var panel_round_bg = preload("uid://dqfhm2ywaj4dr")
var panel_round_base = preload("uid://cywnobmluy31i")
var panel_round_base_highlight = preload("uid://b0ho2njwihy2p")
var panel_round_accent = preload("uid://3r3hhcvqp2au")
var panel_round_accent_muted = preload("uid://l18dbl63e366")
var panel_top_round_base = preload("uid://cqnilt2rk14bi")
var panel_top_round_base_highlight = preload("uid://0nxkxhcntsj3")
var panel_top_round_accent = preload("uid://dve2ih1gvvua7")
var panel_top_round_accent_muted = preload("uid://7s65f804p1jc")

var sb_btn_normal = preload("uid://di36bptu4b3n")
var sb_btn_highlight = preload("uid://dcjwu6ej2w2s4")
var sb_btn_top_highlight = preload("uid://lyngp43l4n0n")

var sb_clrpicker_normal = preload("uid://bth006ulwoyl3")
var sb_clrpicker_highlight = preload("uid://bv58jw0dd3sve")

var sb_line_edit_normal = preload("uid://pue22dsifmfd")
var sb_line_edit_highlight = preload("uid://dl1ay0wubtp2m")

var sb_tab_bar_bg = preload("uid://beo2bu5ofsw0u")
var sb_tab_unselected = preload("uid://427jdnrjcbba")
var sb_tab_selected = preload("uid://cy0ifp487jfcg")
var sb_tab_hover = preload("uid://yxpx0pyjme8s")



var editor_theme_base_col_elements: Array[Control] = [
	cat_top_bar,
]


## SEPERATOR has index 3, should not be used.
enum LimitMethod {
	ENTRY_COUNT,
	SESSION_TIMER,
	BOTH,
	SEPERATOR,
	NONE
}

enum EntryCountAction {
	OVERWRITE_ENTRIES,
	RESTART,
	STOP
}

enum SessionTimerAction {
	RESTART,
	STOP
}

enum ErrorReportLevel {
	WARNINGS_ERRORS,
	ERRORS,
	NONE
}

const PATH = "user://gologger_data.ini"
var gl_hotkeys: GLShortcut = preload("uid://dyi2aml73k4g8")

var valid_line_edit_stylebox := preload("uid://b8w5i8chks7st")
var invalid_line_edit_stylebox := preload("uid://cjxw1ngoxnqnv")
var category_scene = preload("res://addons/GoLogger/Dock/LogCategory.tscn")
var config = ConfigFile.new()
var suppress_history_prints: bool = false
var plugin_version: String =  "1.4":
	set(value):
		plugin_version = value
		if plugin_version_cat_lbl != null:
			plugin_version_cat_lbl.text = str("GoLogger v.", value)
		if plugin_version_sett_lbl != null:
			plugin_version_sett_lbl.text = str("GoLogger v.", value)

var _default_setting_in_progress: bool = false
var focused_category: Array = []
var btn_array: Array[Control] = []
var container_array: Array[Control] = []
var c_font_normal := Color("9d9ea0")
var c_font_hover := Color("ffffff")
var c_print_history := "[color=878787][GoLogger] "

var settings_dict := {
	"category_names": 						["game"],
	"default_category": 					"",
	"base_directory": 						{"value": "user://GoLogger/", "type": TYPE_STRING, "default": "user://GoLogger/"},
	"log_header_format": 					{"value": "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:", "type": TYPE_STRING, "default": "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:"},
	"entry_format": 							{"value":						 "[{hh}:{mi}:{ss}] {instance_id}: {entry}", "type": TYPE_STRING, "default": "[{hh}:{mi}:{ss}] {instance_id}: {entry}"},
	"autostart_session": 					{"value": true, 		"type": TYPE_BOOL, 		"default": true},
	"use_utc": 										{"value": false, 		"type": TYPE_BOOL, 		"default": false},
	"id_overlay_print": 					{"value": false, 		"type": TYPE_BOOL, 		"default": false},
	"id_overlay_toggle": 					{"value": false, 		"type": TYPE_BOOL, 		"default": false},
	"id_overlay_startup_state": 	{"value": false, 		"type": TYPE_BOOL, 		"default": false},
	"id_overlay_align":						{"value": 0, 				"type": TYPE_INT,			"default": 0},
	"id_overlay_font_size":				{"value": 12, 			"type": TYPE_INT, 		"default": 12},
	"id_overlay_font_color":			{"value": "ffffff", "type": TYPE_STRING, 	"default": "ffffff"},
	"id_overlay_outline_size":		{"value": 8,				"type": TYPE_INT,			"default": 8},
	"id_overlay_outline_color":		{"value": "000000", "type": TYPE_STRING,	"default": "000000"},
	"limit_method": 							{"value": 0, 				"type": TYPE_INT, 		"default": 0},
	"entry_count_action": 				{"value": 0, 				"type": TYPE_INT, 		"default": 0},
	"session_timer_action": 			{"value": 0, 				"type": TYPE_INT, 		"default": 0},
	"file_cap": 									{"value": 10, 			"type": TYPE_INT, 		"default": 10},
	"entry_cap": 									{"value": 1200, 		"type": TYPE_INT, 		"default": 1200},
	"session_duration": 					{"value": 900, 			"type": TYPE_INT, 		"default": 900},
	"error_reporting": 						{"value": 0, 				"type": TYPE_INT, 		"default": 0},
	"columns": 										{"value": 5, 				"type": TYPE_INT, 		"default": 5},

	"defaults": {
		"category_names": 								["game"],
		"default_category": 							"",
		"base_directory": 								"user://GoLogger/",
		"log_header_format": 							"{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:",
		"entry_format": 									"[{hh}:{mi}:{ss}] {instance_id}: {entry}",
		"autostart_session": 							true,
		"use_utc": 												false,
		"id_overlay_print": 							false,
		"id_overlay_toggle": 							false,
		"id_overlay_startup_state": 			false,
		"id_overlay_align":								0,
		"id_overlay_font_size":						12,
		"id_overlay_color": 							"ffffff",
		"id_overlay_outline_size":				8,
		"id_overlay_outline_color":				"000000",
		"limit_method": 									0,
		"entry_count_action": 						0,
		"session_timer_action": 					0,
		"file_cap": 											10,
		"entry_cap": 											300,
		"session_duration": 							300,
		"error_reporting": 								0,
		"columns": 												5
	},
	"expected_settings": {
		"category_names": 					"categories/category_names",
		"default_category": 				"categories/default_category",
		"base_directory": 					"settings/base_directory",
		"columns": 									"settings/columns",
		"log_header_format": 				"settings/log_header_format",
		"entry_format": 						"settings/entry_format",
		"autostart_session": 				"settings/autostart_session",
		"use_utc": 									"settings/use_utc",
		"id_overlay_print": 				"settings/id_overlay_print",
		"id_overlay_toggle": 				"settings/id_overlay_toggle",
		"id_overlay_startup_state": "settings/id_overlay_startup_state",
		"id_overlay_align":					"settings/id_overlay_align",
		"id_overlay_font_size":			"settings/id_overlay_font_size",
		"id_overlay_color": 				"settings/id_overlay_color",
		"id_overlay_outline_size":	"settings/id_overlay_outline_size",
		"id_overlay_outline_color": "settings/id_overlay_outline_color",
		"limit_method": 						"settings/limit_method",
		"entry_count_action": 			"settings/entry_count_action",
		"session_timer_action": 		"settings/session_timer_action",
		"file_cap": 								"settings/file_cap",
		"entry_cap": 								"settings/entry_cap",
		"session_duration": 				"settings/session_duration",
		"error_reporting": 					"settings/error_reporting"
	},
	"expected_types": {
		"categories/category_names": 					TYPE_ARRAY,
		"categories/default_category": 				TYPE_STRING,
		"settings/base_directory": 						TYPE_STRING,
		"settings/columns": 									TYPE_INT,
		"settings/log_header_format": 				TYPE_STRING,
		"settings/entry_format" : 						TYPE_STRING,
		"settings/autostart_session": 				TYPE_BOOL,
		"settings/use_utc": 									TYPE_BOOL,
		"settings/id_overlay_print": 					TYPE_BOOL,
		"settings/id_overlay_toggle":					TYPE_BOOL,
		"settings/id_overlay_startup_state": 	TYPE_BOOL,
		"settings/id_overlay_align":					TYPE_INT,
		"settings/id_overlay_font_size":			TYPE_INT,
		"settings/id_overlay_color":					TYPE_STRING,
		"settings/id_overlay_outline_size":		TYPE_INT,
		"settings/id_overlay_outline_color":	TYPE_STRING,
		"settings/limit_method": 							TYPE_INT,
		"settings/entry_count_action": 				TYPE_INT,
		"settings/session_timer_action": 			TYPE_INT,
		"settings/file_cap": 									TYPE_INT,
		"settings/entry_cap": 								TYPE_INT,
		"settings/session_duration": 					TYPE_INT,
		"settings/error_reporting": 					TYPE_INT
	}
}




func _ready() -> void:
	if Engine.is_editor_hint():
		entry_format_warning.visible = !_is_entry_format_valid(entry_format_line.text)

		if !FileAccess.file_exists(PATH):
			create_settings_file()

		config.load(PATH)
		_ensure_default_category()

		cat_del_warn_rlbl.modulate = Color.TRANSPARENT
		id_overlay_startup_btn.show() if config.get_value("settings", "id_overlay_toggle", false) else id_overlay_startup_btn.hide()

		for i in category_container.get_children():
			if i is LogCategory:
				i.queue_free()
			else: print_rich("[color=fb776a]GoLogger error: Unexpected node in category container ", i.get_name(), "{", i.get_class(), "} - Please report bug: [url]https://github.com/Burloe/GoLogger/issues[/url][/color]")


		# Signal connections
		settings.settings_changed.connect(_on_editor_settings_changed)
		_add_category_btn.button_up.connect(_add_category)
		open_dir_btn.button_up.connect(_open_directory)
		column_slider.value_changed.connect(_on_column_slider_value_changed)
		reset_settings_btn.button_up.connect(reset_to_default)
		user_dir_btn.button_up.connect(_open_user_dir)

		# SpinBoxes
		var spinboxes: Array = [
			[
				file_count_spinbox,
				entry_count_spinbox,
				session_duration_spinbox,
				id_overlay_font_size_spinbox,
				id_overlay_outline_size_spinbox
			],
			[
				file_count_spinbox_line,
				entry_count_spinbox_line,
				session_duration_spinbox_line,
				id_overlay_font_size_spinbox_line,
				id_overlay_outline_size_spinbox_line
			]
		]

		for i in range(spinboxes[0].size()):
			if spinboxes[1][i] == null: spinboxes[1][i] = spinboxes[0][i].get_line_edit()
			if spinboxes[1][i].text_submitted.is_connected(_on_spinbox_lineedit_submitted):
				spinboxes[1][i].text_submitted.disconnect(_on_spinbox_lineedit_submitted)
			spinboxes[1][i].text_submitted.connect(_on_spinbox_lineedit_submitted.bind(spinboxes[1][i]))

		id_overlay_font_size_spinbox_line = id_overlay_font_size_spinbox.get_line_edit()
		id_overlay_outline_size_spinbox_line = id_overlay_outline_size_spinbox.get_line_edit()
		file_count_spinbox_line = file_count_spinbox.get_line_edit()
		entry_count_spinbox_line = entry_count_spinbox.get_line_edit()
		session_duration_spinbox_line = session_duration_spinbox.get_line_edit()


		var line_edits: Array[LineEdit] = [
			base_dir_line,
			log_header_line,
			entry_format_line,
			id_overlay_font_size_spinbox_line,
			id_overlay_outline_size_spinbox_line,
			file_count_spinbox_line,
			entry_count_spinbox_line,
			session_duration_spinbox_line
		]
		for line in line_edits:
			if line == null: return

			line.add_theme_stylebox_override("normal", sb_line_edit_normal)
			line.editing_toggled.connect(_on_line_edit_highlight_changed.bind(line))
			line.mouse_entered.connect(_on_line_edit_highlight_changed.bind(true, line))
			line.mouse_exited.connect(_on_line_edit_highlight_changed.bind(false, line))

		btn_array = [
			base_dir_line,
			base_dir_apply_btn,
			base_dir_opendir_btn,
			base_dir_reset_btn,
			log_header_line,
			log_header_apply_btn,
			entry_format_line,
			entry_format_apply_btn,
			autostart_btn,
			utc_btn,
			print_instance_id_btn,
			id_overlay_toggle_btn,
			id_overlay_align_opt_btn,
			id_overlay_font_size_spinbox,
			id_overlay_font_size_spinbox_line,
			id_overlay_font_col_btn,
			id_overlay_outline_size_spinbox,
			id_overlay_outline_size_spinbox_line,
			id_overlay_outline_col_btn,
			id_overlay_startup_btn,
			limit_method_btn,
			entry_count_action_btn,
			session_timer_action_btn,
			file_count_spinbox,
			file_count_spinbox_line,
			entry_count_spinbox,
			entry_count_spinbox_line,
			session_duration_spinbox,
			session_duration_spinbox_line,
			error_rep_btn,
		]


		for i in range(btn_array.size()):
			if btn_array[i] is Button:
				if btn_array[i].button_up.is_connected(_on_button_button_up):
					btn_array[i].button_up.disconnect(_on_button_button_up)
				btn_array[i].button_up.connect(_on_button_button_up.bind(btn_array[i]))

			if btn_array[i] is CheckButton:
				if btn_array[i].toggled.is_connected(_on_checkbutton_toggled):
					btn_array[i].toggled.disconnect(_on_checkbutton_toggled)
				btn_array[i].toggled.connect(_on_checkbutton_toggled.bind(btn_array[i]))

			elif btn_array[i] is OptionButton:
				if btn_array[i].item_selected.is_connected(_on_optbtn_item_selected):
					btn_array[i].item_selected.disconnect(_on_optbtn_item_selected)
				btn_array[i].item_selected.connect(_on_optbtn_item_selected.bind(btn_array[i]))

			elif btn_array[i] is LineEdit:
				if btn_array[i].text_changed.is_connected(_on_line_edit_text_changed):
					btn_array[i].text_changed.disconnect(_on_line_edit_text_changed)
				btn_array[i].text_changed.connect(_on_line_edit_text_changed.bind(btn_array[i]))

				if btn_array[i].text_submitted.is_connected(_on_line_edit_text_submitted):
					btn_array[i].text_submitted.disconnect(_on_line_edit_text_submitted)
				btn_array[i].text_submitted.connect(_on_line_edit_text_submitted.bind(btn_array[i]))

			elif btn_array[i] is SpinBox:
				if btn_array[i].value_changed.is_connected(_on_spinbox_value_changed):
					btn_array[i].value_changed.disconnect(_on_spinbox_value_changed)
				btn_array[i].value_changed.connect(_on_spinbox_value_changed.bind(btn_array[i]))

			elif btn_array[i] is ColorPickerButton:
				if btn_array[i].color_changed.is_connected(_on_colorpicker_color_changed):
					btn_array[i].color_changed.disconnect(_on_colorpicker_color_changed)
				btn_array[i].color_changed.connect(_on_colorpicker_color_changed.bind(btn_array[i]))


		container_array = [
			base_dir_container,
			log_header_container,
			entry_format_container,
			limit_method_container,
			entry_count_action_container,
			session_timer_action_container,
			file_count_container,
			entry_count_container,
			session_duration_container,
			error_rep_container,
			id_overlay_align_container,
			id_overlay_font_size_hbox,
			id_overlay_font_col_container,
			id_overlay_outline_size_hbox,
			id_overlay_outline_col_container
		]

		var btns_array = [
			base_dir_line,
			log_header_line,
			entry_format_line,
			limit_method_btn,
			entry_count_action_btn,
			session_timer_action_btn,
			file_count_spinbox,
			entry_count_spinbox,
			session_duration_spinbox,
			error_rep_btn,
			id_overlay_align_opt_btn,
			id_overlay_font_size_spinbox,
			id_overlay_font_col_btn,
			id_overlay_outline_size_spinbox,
			id_overlay_outline_col_btn
		]

		var corresponding_lbls = [
			base_dir_lbl,
			log_header_lbl,
			entry_format_lbl,
			limit_method_lbl,
			entry_count_action_lbl,
			session_timer_action_lbl,
			file_count_lbl,
			entry_count_lbl,
			session_duration_lbl,
			error_rep_lbl,
			id_overlay_align_lbl,
			id_overlay_font_size_lbl,
			id_overlay_font_col_lbl,
			id_overlay_outline_size_lbl,
			id_overlay_outline_col_lbl
		]

		for i in range(container_array.size()):
			# Update font color on mouse over containers signals
			container_array[i].mouse_entered.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], true))
			container_array[i].mouse_exited.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], false))

			# Update font color on mouse over Buttons signals
			btns_array[i].mouse_entered.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], true))
			btns_array[i].mouse_exited.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], false))

		for lbl in corresponding_lbls:
			lbl.add_theme_color_override("font_color", c_font_normal)



		if base_dir_apply_btn.button_up.is_connected(_on_button_button_up):
			base_dir_apply_btn.button_up.disconnect(_on_button_button_up)
		base_dir_apply_btn.button_up.connect(_on_button_button_up.bind(base_dir_apply_btn))
		if base_dir_reset_btn.button_up.is_connected(_on_button_button_up):
			base_dir_reset_btn.button_up.disconnect(_on_button_button_up)
		base_dir_reset_btn.button_up.connect(_on_button_button_up.bind(base_dir_reset_btn))
		if log_header_apply_btn.button_up.is_connected(_on_button_button_up):
			log_header_apply_btn.button_up.disconnect(_on_button_button_up)
		log_header_apply_btn.button_up.connect(_on_button_button_up.bind(log_header_apply_btn))
		if log_header_reset_btn.button_up.is_connected(_on_button_button_up):
			log_header_reset_btn.button_up.disconnect(_on_button_button_up)
		log_header_reset_btn.button_up.connect(_on_button_button_up.bind(log_header_reset_btn))
		if entry_format_apply_btn.button_up.is_connected(_on_button_button_up):
			entry_format_apply_btn.button_up.disconnect(_on_button_button_up)
		entry_format_apply_btn.button_up.connect(_on_button_button_up.bind(entry_format_apply_btn))
		if entry_format_reset_btn.button_up.is_connected(_on_button_button_up):
			entry_format_reset_btn.button_up.disconnect(_on_button_button_up)
		entry_format_reset_btn.button_up.connect(_on_button_button_up.bind(entry_format_reset_btn))

		open_hotkey_btn.button_up.connect(func() -> void: open_hotkey_resource.emit())


		match config.get_value("settings", "limit_method", settings_dict.get("defaults", {}).get("limit_method", 0)):
			LimitMethod.ENTRY_COUNT:
				entry_count_action_container.show()
				entry_count_container.show()
				session_timer_action_container.hide()
				session_duration_container.hide()
			LimitMethod.SESSION_TIMER:
				entry_count_action_container.hide()
				entry_count_container.hide()
				session_timer_action_container.show()
				session_duration_container.show()
			LimitMethod.BOTH:
				entry_count_action_container.show()
				entry_count_container.show()
				session_timer_action_container.show()
				session_duration_container.show()
			LimitMethod.NONE:
				entry_count_action_container.hide()
				entry_count_container.hide()
				session_timer_action_container.hide()
				session_duration_container.hide()


		suppress_history_prints = true
		load_data()
		_sync_stylebox_colors(self)

		await get_tree().process_frame
		suppress_history_prints = false

		settings_dict["controls"] = {
			"base_directory": base_dir_line,
			"log_header_format": log_header_line,
			"entry_format": entry_format_line,
			"autostart_session": autostart_btn,
			"use_utc": utc_btn,
			"id_overlay_print": print_instance_id_btn,
			"id_overlay_toggle": id_overlay_toggle_btn,
			"id_overlay_startup_state": id_overlay_startup_btn,
			"id_overlay_align": id_overlay_align_opt_btn,
			"id_overlay_font_size": id_overlay_font_size_spinbox,
			"id_overlay_color": id_overlay_font_col_btn,
			"id_overlay_outline_size": id_overlay_outline_size_spinbox,
			"id_overlay_outline_col": id_overlay_outline_col_btn,
			"limit_method": limit_method_btn,
			"entry_count_action": entry_count_action_btn,
			"session_timer_action": session_timer_action_btn,
			"file_cap": file_count_spinbox,
			"entry_cap": entry_count_spinbox,
			"session_duration": session_duration_spinbox,
			"error_reporting": error_rep_btn,
			"columns": column_slider
		}







func create_settings_file() -> void: # Mirror
	var cf := ConfigFile.new()
	cf.set_value("categories", "category_names", 								["game"])
	cf.set_value("categories", "default_category", 							settings_dict.get("defaults", {}).get("default_category", ""))

	cf.set_value("settings", "base_directory", 									settings_dict.get("defaults", {}).get("base_directory", "user://GoLogger/"))
	cf.set_value("settings", "columns", 												settings_dict.get("defaults", {}).get("columns", 5))
	cf.set_value("settings", "log_header_format", 							settings_dict.get("defaults", {}).get("log_header_format", "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:"))
	cf.set_value("settings", "entry_format", 										settings_dict.get("defaults", {}).get("entry_format", "[{hh}:{mi}:{ss}] {instance_id}: {entry}"))
	cf.set_value("settings", "autostart_session", 							settings_dict.get("defaults", {}).get("autostart_session", true))
	cf.set_value("settings", "use_utc", 												settings_dict.get("defaults", {}).get("use_utc", false))
	cf.set_value("settings", "id_overlay_print", 								settings_dict.get("defaults", {}).get("id_overlay_print", false))
	cf.set_value("settings", "id_overlay_toggle", 							settings_dict.get("defaults", {}).get("id_overlay_toggle", false))
	cf.set_value("settings", "id_overlay_startup_state", 				settings_dict.get("defaults", {}).get("id_overlay_startup_state", false))
	cf.set_value("settings", "id_overlay_align", 								settings_dict.get("defaults").get("id_overlay_align", 0))
	cf.set_value("settings", "id_overlay_font_size", 						settings_dict.get("defaults", {}).get("id_overlay_font_size", 12))
	cf.set_value("settings", "id_overlay_color", 					Color(settings_dict.get("defaults", {}).get("id_overlay_color", "ffffff")).to_html(true))
	cf.set_value("settings", "id_overlay_outline_size", 				settings_dict.get("defaults", {}).get("id_overlay_outline_size", 8))
	cf.set_value("settings", "id_overlay_outline_color",	Color(settings_dict.get("defaults", {}).get("id_overlay_color", "ffffff")).to_html(true))
	cf.set_value("settings", "limit_method", 										settings_dict.get("defaults", {}).get("limit_method", 0))
	cf.set_value("settings", "entry_count_action", 							settings_dict.get("defaults", {}).get("entry_count_action", 0))
	cf.set_value("settings", "session_timer_action", 						settings_dict.get("defaults", {}).get("session_timer_action", 0))
	cf.set_value("settings", "file_cap", 												settings_dict.get("defaults", {}).get("file_cap", 10))
	cf.set_value("settings", "entry_cap", 											settings_dict.get("defaults", {}).get("entry_cap", 300))
	cf.set_value("settings", "session_duration", 								settings_dict.get("defaults", {}).get("session_duration", 300))
	cf.set_value("settings", "error_reporting", 								settings_dict.get("defaults", {}).get("error_reporting", 0))

	var _s = cf.save(PATH)
	if _s != OK:
		var _e = cf.get_open_error()
		printerr(str("GoLogger error: Failed to create settings.ini file! ", get_error(_e, "ConfigFile")))
		return

	config.load(PATH)
	_ensure_default_category()


func reset_to_default() -> void:
	var cf := ConfigFile.new()
	cf.load(PATH)

	for key in settings_dict.get("defaults", {}).keys():
		if key == "category_names" or key == "default_category":
			continue
		cf.set_value("settings", key, settings_dict.get("defaults", {}).get(key))

	cf.set_value("categories.game", "category_name", "game")
	cf.set_value("categories.game", "category_index", 0)
	cf.set_value("categories.game", "file_count", 0)
	cf.set_value("categories.game", "is_locked", false)
	cf.save(PATH)

	base_dir_line.text = 											settings_dict.get("defaults").get("base_directory", "user://GoLogger/")
	log_header_line.text = 										settings_dict.get("defaults").get("log_header_format", "")
	entry_format_line.text = 									settings_dict.get("defaults").get("entry_format", "")
	autostart_btn.button_pressed = 						settings_dict.get("defaults").get("autostart_session", true)
	utc_btn.button_pressed = 									settings_dict.get("defaults").get("use_utc", false)
	print_instance_id_btn.button_pressed = 		settings_dict.get("defaults").get("id_overlay_print", false)
	id_overlay_toggle_btn.button_pressed = 		settings_dict.get("defaults").get("id_overlay_toggle", false)
	id_overlay_startup_btn.button_pressed = 	settings_dict.get("defaults").get("id_overlay_startup_state", false)
	id_overlay_align_opt_btn.selected = 			settings_dict.get("defaults").get("id_overlay_align", 0)
	id_overlay_font_size_spinbox.value = 			settings_dict.get("defaults").get("id_overlay_font_size", 12)
	id_overlay_font_col_btn.color = 		Color(settings_dict.get("defaults").get("id_overlay_color", "ffffff"))
	id_overlay_font_size_spinbox.value = 			settings_dict.get("defaults").get("id_overlay_outline_size", 8)
	id_overlay_outline_col_btn.color = 	Color(settings_dict.get("defaults").get("id_overlay_outline_color"))
	limit_method_btn.selected = 							settings_dict.get("defaults").get("limit_method", 0)
	entry_count_action_btn.selected = 				settings_dict.get("defaults").get("entry_count_action", 0)
	session_timer_action_btn.selected = 			settings_dict.get("defaults").get("session_timer_action", 0)
	file_count_spinbox.value = 								settings_dict.get("defaults").get("file_cap", 10)
	entry_count_spinbox.value = 							settings_dict.get("defaults").get("entry_cap", 300)
	session_duration_spinbox.value = 					settings_dict.get("defaults").get("session_duration", 300)
	error_rep_btn.selected = 									settings_dict.get("defaults").get("error_reporting", 0)
	column_slider.value = 										_get_column_value(settings_dict.get("defaults", {}).get("columns", 5))

	base_dir_apply_btn.disabled = true
	log_header_apply_btn.disabled = true
	entry_format_apply_btn.disabled = true
	if !suppress_history_prints:
		print_rich(str(c_print_history, "Reset Categories and settings to defaults."))



func validate_settings() -> void: # Mirror
	_ensure_default_category()
	# Validate presence -> Write default
	for setting in settings_dict.get("expected_settings", {}).keys():
		var splits = settings_dict["expected_settings"][setting].split("/")
		if !config.has_section(splits[0]) or !config.has_section_key(splits[0], splits[1]):
			config.set_value(splits[0], splits[1], settings_dict.get("defaults", {}).get(setting))

	# Validate types -> Apply default
	for type_key in settings_dict.get("expected_types", {}).keys():
		var splits = type_key.split("/")
		var expected_type = settings_dict["expected_types"][type_key]
		var value = config.get_value(splits[0], splits[1])

		if typeof(value) != expected_type:
			config.set_value(splits[0], splits[1], settings_dict.get("defaults", {}).get(splits[1]))

	config.save(PATH)


func load_data() -> void:
	var _c = ConfigFile.new()
	if _c.load(PATH) != OK:
		printerr("GoLogger error: Failed to load settings.ini file!")
		return

	validate_settings()

	for name in _c.get_value("categories", "category_names", []):
		_add_category(
			name,
			_c.get_value("categories." + name, "category_index", 0),
			_c.get_value("categories." + name, "is_locked", false)
		)
	var def_cat = _c.get_value("categories", "default_category", "")
	if def_cat != "":
		for cat in category_container.get_children():
			if cat is LogCategory and cat.category_name == def_cat and cat.default_checkbox != null:
				cat.default_checkbox.button_pressed = true
				break

	# Settings
	base_dir_line.text = 										_c.get_value("settings", "base_directory", 						settings_dict.get("defaults", {}).get("base_directory", "user://GoLogger/"))
	log_header_line.text = 									_c.get_value("settings", "log_header_format", 				settings_dict.get("defaults", {}).get("log_header_format", "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:"))
	entry_format_line.text = 								_c.get_value("settings", "entry_format", 							settings_dict.get("defaults", {}).get("entry_format", "[{hh}:{mi}:{ss}] {instance_id}: {entry}"))
	autostart_btn.button_pressed = 					_c.get_value("settings", "autostart_session", 				settings_dict.get("defaults", {}).get("autostart_session", true))
	utc_btn.button_pressed = 								_c.get_value("settings", "use_utc", 									settings_dict.get("defaults", {}).get("use_utc", false))
	print_instance_id_btn.button_pressed = 	_c.get_value("settings", "id_overlay_print", 					settings_dict.get("defaults", {}).get("id_overlay_print", false))
	id_overlay_toggle_btn.button_pressed = 	_c.get_value("settings", "id_overlay_toggle", 				settings_dict.get("defaults", {}).get("id_overlay_toggle", false))
	id_overlay_startup_btn.button_pressed = _c.get_value("settings", "id_overlay_startup_state", 	settings_dict.get("defaults", {}).get("id_overlay_startup_state", false))
	id_overlay_font_size_spinbox.value = 		_c.get_value("settings", "id_overlay_font_size", 			settings_dict.get("defaults", {}).get("id_overlay_font_size", 12))
	id_overlay_font_col_btn.color = 	Color(_c.get_value("settings", "id_overlay_color", 					settings_dict.get("defaults", {}).get("id_overlay_color", "ffffff")))
	id_overlay_outline_size_spinbox.value = _c.get_value("settings", "id_overlay_outline_size", 	settings_dict.get("defaults").get("id_overlay_outline_size", 8))
	limit_method_btn.selected = 						_c.get_value("settings", "limit_method", 							settings_dict.get("defaults", {}).get("limit_method", 0))
	entry_count_action_btn.selected = 			_c.get_value("settings", "entry_count_action", 				settings_dict.get("defaults", {}).get("entry_count_action", 0))
	session_timer_action_btn.selected = 		_c.get_value("settings", "session_timer_action", 			settings_dict.get("defaults", {}).get("session_timer_action", 0))
	file_count_spinbox.value = 							_c.get_value("settings", "file_cap", 									settings_dict.get("defaults", {}).get("file_cap", 10))
	entry_count_spinbox.value = 						_c.get_value("settings", "entry_cap", 								settings_dict.get("defaults", {}).get("entry_cap", 300))
	session_duration_spinbox.value = 				_c.get_value("settings", "session_duration", 					settings_dict.get("defaults", {}).get("session_duration", 300))
	error_rep_btn.selected = 								_c.get_value("settings", "error_reporting", 					settings_dict.get("defaults", {}).get("error_reporting", 0))
	column_slider.value = 									_get_column_value(_c.get_value("settings", "columns", settings_dict.get("defaults", {}).get("columns", 5)))

	config.load(PATH)




## Saves all the dock data ( categories and settings state ) to file according to the state/data of the dock(not the file).
func save_data(deferred: bool = false) -> void:
	if deferred:
		await get_tree().physics_frame

	var _c := ConfigFile.new()
	_c.load(PATH)
	_ensure_default_category()

	# Categories
	var _cat_names = []
	for log_category in category_container.get_children():
		if log_category is LogCategory:
			if log_category.category_name == "":
				continue

			_cat_names.append(log_category.category_name)
			_c.set_value("categories." + log_category.category_name, "file_name", _c.get_value("categories." + log_category.category_name, "file_name", ""))
			_c.set_value("categories." + log_category.category_name, "file_path", _c.get_value("categories." + log_category.category_name, "file_path", ""))
			_c.set_value("categories." + log_category.category_name, "category_name", log_category.category_name)
			_c.set_value("categories." + log_category.category_name, "category_index", log_category.index)
			_c.set_value("categories." + log_category.category_name, "file_count", _c.get_value("categories." + log_category.category_name, "file_count", 0))
			_c.set_value("categories." + log_category.category_name, "is_locked", log_category.is_locked)
			_c.set_value("categories." + log_category.category_name, "entry_count", _c.get_value("categories." + log_category.category_name, "entry_count", 0))

	_c.set_value("categories", "category_names", _cat_names)

	# Settings
	var error: int = 0
	for key in settings_dict.get("defaults", {}).keys():
		if !settings_dict.get("controls", {}).has(key):
			continue

		var ctrl = settings_dict.get("controls", {}).get(key, null)

		if ctrl == null:
			error += 1
			# printerr("Null count: ", error, " attempted to get control for key: [", key, "] - Got <", ctrl, ">")
			continue

		elif ctrl is LineEdit:
			_c.set_value("settings", key, ctrl.text)
		elif ctrl is SpinBox:
			_c.set_value("settings", key, int(ctrl.value))
		elif ctrl is CheckButton:
			_c.set_value("settings", key, ctrl.button_pressed)
		elif ctrl is OptionButton:
			_c.set_value("settings", key, ctrl.selected)
		elif ctrl is HSlider:
			_c.set_value("settings", key, int(column_slider.value))
		elif ctrl is ColorPickerButton:
			_c.set_value("settings", key, ctrl.color.to_html(true))

	config.load(PATH)
	_c.set_value("categories", "default_category", config.get_value("categories", "default_category", ""))

	var _e = _c.save(PATH)
	if _e != OK:
		printerr(str("GoLogger error: Failed to save settings.ini file! ", get_error(_e, "ConfigFile")))
		return
	config.load(PATH)


## `save_after` should be used when the user adds categories manually via the dock. Not when loading categories from config.
func _add_category(_name: String = "", _index: int = 0, _is_locked: bool = false, save_after: bool = false) -> void:
	config.load(PATH)
	var _n = category_scene.instantiate()
	_n.dock = self
	_n.category_name = _name
	_n.is_locked = _is_locked
	_n.index = category_container.get_children().size()
	category_container.add_child(_n)

	_n.log_category_changed.connect(_category_changed)
	_n.request_log_deletion.connect(_delete_category)
	_n.move_category_requested.connect(_change_category_order)
	_n.line_edit.focus_entered.connect(_on_category_line_focus.bind([_n, _n.line_edit.text], true))
	_n.line_edit.focus_exited.connect(_on_category_line_focus.bind([], false))
	_n.default_checkbox.button_pressed = true if config.get_value("categories", "default_category", "") == _name else false
	if _name == "":	_n.line_edit.grab_focus() # For immediate renaming
	_handle_category_mov_button_state()
	if save_after:
		save_data()


## Called when a category has changed (name, lock state, etc) by the dock UI.
func _category_changed(log_category: LogCategory, is_name_change: bool, old_name) -> void:
	config.load(PATH)
	config.set_value("categories." + log_category.category_name, "file_name", "")
	config.set_value("categories." + log_category.category_name, "file_path", "")
	config.set_value("categories." + log_category.category_name, "category_name", log_category.category_name)
	config.set_value("categories." + log_category.category_name, "category_index", log_category.index)
	config.set_value("categories." + log_category.category_name, "file_count", config.get_value("categories." + log_category.category_name, "file_count", 0))
	config.set_value("categories." + log_category.category_name, "is_locked", log_category.is_locked)
	config.set_value("categories." + log_category.category_name, "entry_count", config.get_value("categories." + log_category.category_name, "entry_count", 0))
	if is_name_change:
		# Remove old category section
		if config.has_section("categories." + old_name):
			config.erase_section("categories." + old_name)

		var _categg = []
		for i in category_container.get_children():
			if i is LogCategory:
				_categg.append(i.category_name)
		config.set_value("categories", "category_names", _categg)

	config.save(PATH)


func set_default_category(cat: LogCategory, set_status: bool) -> void:
	if _default_setting_in_progress:
		return

	_default_setting_in_progress = true
	config.load(PATH)
	config.set_value("categories", "default_category", cat.category_name if set_status else "")

	for categ in category_container.get_children():
		if categ is LogCategory and categ.default_checkbox != null:
			if categ != cat:
				categ.default_checkbox.button_pressed = false

	if set_status and cat.default_checkbox != null:
		cat.default_checkbox.button_pressed = true

	config.save(PATH)
	_default_setting_in_progress = false


func _delete_category(log_category: LogCategory) -> void:
	if log_category.get_parent() == category_container:

		config.load(PATH)
		_ensure_default_category()

		var def_c: String = config.get_value("categories", "default_category", "")
		if log_category.default_checkbox.button_pressed and log_category.category_name == def_c:
			config.set_value("categories", "default_category", "")

		category_container.remove_child(log_category)
		log_category.queue_free()
		if config.has_section("categories." + log_category.category_name):
			config.erase_section("categories." + log_category.category_name)
		config.save(PATH)
		_assign_category_indices()

		if get_tree().is_inside_tree():
			var tw = get_tree().create_tween()
			tw.tween_property(cat_del_warn_rlbl, "modulate", Color.WHITE, 0.5)
			await get_tree().create_timer(8.0).timeout
			var twe = get_tree().create_tween()
			twe.tween_property(cat_del_warn_rlbl, "modulate", Color.TRANSPARENT, 0.5)
		else:
			cat_del_warn_rlbl.modulate = Color.TRANSPARENT


func _change_category_order(category: LogCategory, direction: int) -> void:
	var new_index = category.index + direction
	if new_index < 0 or new_index >= category_container.get_child_count():
		return

	category_container.move_child(category, category.index + direction)
	_assign_category_indices()


func _assign_category_indices() -> void:
	for i in range(category_container.get_child_count()):
		var category = category_container.get_child(i)
		if category is LogCategory:
			category.index = i

	save_data()
	_handle_category_mov_button_state()


func _handle_category_mov_button_state() -> void:
	for i in range(category_container.get_child_count()):
		var category = category_container.get_child(i)
		category.move_left_btn.disabled = (category.index == 0)
		category.move_right_btn.disabled = (category.index == category_container.get_child_count() - 1)


func _check_conflict_name(cat_obj: LogCategory, new_name: String) -> bool:
	for log_category in category_container.get_children():
		if log_category == cat_obj: # Disregard category being checked
			continue
		elif log_category.category_name == new_name:
			if name == "": return false
			return true
	return false




static func get_error(error: int, object_type: String = "") -> String:
	match error:
		1:  return str("Error[1] ",  object_type, " Failed")
		2:  return str("Error[2] ",  object_type, " Unavailable")
		3:  return str("Error[3] ",  object_type, " Unconfigured")
		4:  return str("Error[4] ",  object_type, " Unauthorized")
		5:  return str("Error[5] ",  object_type, " Parameter range")
		6:  return str("Error[6] ",  object_type, " Out of memory")
		7:  return str("Error[7] ",  object_type, " File: Not found")
		8:  return str("Error[8] ",  object_type, " File: Bad drive")
		9:  return str("Error[9] ",  object_type, " File: Bad File path")
		10: return str("Error[10] ", object_type, " No File permission")
		11: return str("Error[11] ", object_type, " File already in use")
		12: return str("Error[12] ", object_type, " Can't open File")
		13: return str("Error[13] ", object_type, " Can't write to File")
		14: return str("Error[14] ", object_type, " Can't read to File")
		15: return str("Error[15] ", object_type, " File unrecognized")
		16: return str("Error[16] ", object_type, " File corrupt")
		17: return str("Error[17] ", object_type, " File missing dependencies")
		18: return str("Error[18] ", object_type, " End of File")
		19: return str("Error[19] ", object_type, " Can't open")
		20: return str("Error[20] ", object_type, " Can't create")
		21: return str("Error[21] ", object_type, " Query failed")
		22: return str("Error[22] ", object_type, " Already in use")
		23: return str("Error[23] ", object_type, " Locked")
		24: return str("Error[24] ", object_type, " Timeout")
		25: return str("Error[25] ", object_type, " Can't connect")
		26: return str("Error[26] ", object_type, " Can't resolve")
		27: return str("Error[27] ", object_type, " Connection error")
		28: return str("Error[28] ", object_type, " Can't acquire resource")
		29: return str("Error[29] ", object_type, " Can't fork process")
		30: return str("Error[30] ", object_type, " Invalid data")
		31: return str("Error[31] ", object_type, " Invalid parameter")
		32: return str("Error[32] ", object_type, " Already exists")
		33: return str("Error[33] ", object_type, " Doesn't exist")
		34: return str("Error[34] ", object_type, " Database: Can't read")
		35: return str("Error[35] ", object_type, " Database: Can't write")
		36: return str("Error[36] ", object_type, " Compilation failed")
		37: return str("Error[37] ", object_type, " Method not found")
		38: return str("Error[38] ", object_type, " Link failed")
		39: return str("Error[39] ", object_type, " Script failed")
		40: return str("Error[40] ", object_type, " Cyclic link")
		41: return str("Error[41] ", object_type, " Invalid declaration")
		42: return str("Error[42] ", object_type, " Duplicate symbol")
		43: return str("Error[43] ", object_type, " Parse error")
		44: return str("Error[44] ", object_type, " Busy error")
		46: return str("Error[45] ", object_type, " Skip error")
		47: return str("Error[46] ", object_type, " Help error")
		48: return str("Error[47] ", object_type, " Bug error")
	return "N/A"


func _open_user_dir() -> void:
	var abs_path = ProjectSettings.globalize_path("user://")
	OS.shell_open(abs_path)


func _open_directory() -> void:
	var abs_path = ProjectSettings.globalize_path(config.get_value("settings", "base_directory"))
	OS.shell_open(abs_path)


func _apply_new_base_directory() -> void:
	var old_dir = config.get_value("settings", "base_directory")
	var new_dir = base_dir_line.text.strip_edges()
	# Don't accept empty path
	if new_dir == "":
		if config.get_value("settings", "error_reporting") != 2:
			push_warning("GoLogger: Base directory cannot be empty. Reverting to previous path[", old_dir, "].")
		base_dir_line.text = old_dir
		base_dir_apply_btn.disabled = true
		return


	if not new_dir.ends_with("/"):
		new_dir += "/"


	var d = DirAccess.open(new_dir)
	if d == null:
		var res : int = OK

		var create_path = new_dir
		if new_dir.begins_with("user://") or new_dir.begins_with("res://"):
			create_path = ProjectSettings.globalize_path(new_dir)

		res = DirAccess.make_dir_absolute(create_path)
		if res != OK:
			if config.get_value("settings", "error_reporting") != 2:
				push_warning("GoLogger: Failed to create directory using path[", new_dir, "]. Reverting back to previous directory path[", old_dir, "].")
			base_dir_line.text = old_dir
			base_dir_apply_btn.disabled = true
			return

		d = DirAccess.open(new_dir)

	if d == null or DirAccess.get_open_error() != OK:
		if config.get_value("settings", "error_reporting") != 2:
			push_warning("GoLogger: Failed to access newly created directory using path[", new_dir, "]. Reverting back to previous directory path[", old_dir, "].")
		base_dir_line.text = old_dir
		base_dir_apply_btn.disabled = true
		return

	config.set_value("settings", "base_directory", new_dir)
	var save_err = config.save(PATH)
	if save_err != OK:
		if config.get_value("settings", "error_reporting") != 2:
			push_warning("GoLogger: Failed to save settings.ini after changing base_directory. Reverting back to previous directory path[", old_dir, "].")
		base_dir_line.text = old_dir
		base_dir_apply_btn.disabled = true
		return

	if !suppress_history_prints:
		print_rich(c_print_history, "Base directory changed.")
	base_dir_apply_btn.disabled = true


func _is_entry_format_valid(format: String) -> bool:
	return true if format.contains("{entry}") else false




func _on_dock_mouse_hover_changed(node: Label, is_hovered: bool) -> void:
	if is_hovered:
		node.add_theme_color_override("font_color", c_font_hover)
	else:
		node.add_theme_color_override("font_color", c_font_normal)


func _on_button_button_up(node: Button) -> void:
	config.load(PATH)
	_ensure_default_category()

	match node:
		base_dir_apply_btn:
			_apply_new_base_directory()

		base_dir_opendir_btn:
			if config.get_value("settings", "base_directory") == "":
				push_warning("GoLogger: Base directory path isn't set. Please set a valid directory path before opening the directory.")
			_open_directory()

		base_dir_reset_btn:
			config.set_value("settings", "base_directory", "user://GoLogger/")
			base_dir_line.text = config.get_value("settings", "base_directory")
			if !suppress_history_prints:
				print_rich(c_print_history, "Base directory reset to default.")

		log_header_apply_btn:
			config.set_value("settings", "log_header_format", log_header_line.text)
			if !suppress_history_prints:
				print_rich(c_print_history, "Log header changed.")
			log_header_apply_btn.disabled = true
			log_header_line.release_focus()

		log_header_reset_btn:
			log_header_line.text = settings_dict.get("defaults", {}).get("log_header_format", "")
			config.set_value("settings", "log_header_format", settings_dict.get("defaults", {}).get("log_header_format", ""))
			if !suppress_history_prints:
				print_rich(c_print_history, "Log header option reset to default.")
			log_header_apply_btn.disabled = true
			log_header_line.release_focus()

		entry_format_apply_btn:
			config.set_value("settings", "entry_format", entry_format_line.text)
			var err := config.save(PATH)
			if !suppress_history_prints:
				print_rich(c_print_history, "Entry format changed.")
			entry_format_apply_btn.disabled = true
			entry_format_line.release_focus()

		entry_format_reset_btn:
			entry_format_line.text = settings_dict.get("defaults", {}).get("entry_format", "")
			config.set_value("settings", "entry_format", settings_dict.get("defaults", {}).get("entry_format", ""))
			if !suppress_history_prints:
				print_rich(c_print_history, "Entry format reset to default.")
			entry_format_apply_btn.disabled = true


	save_data()


func _on_line_edit_text_changed(new_text: String, node: LineEdit) -> void:
	config.load(PATH)
	match node:
		base_dir_line:
			if new_text == "":
				base_dir_apply_btn.disabled = true
			if new_text != config.get_value("settings", "base_directory"):
				base_dir_apply_btn.disabled = false
			else:
				base_dir_apply_btn.disabled = true

		log_header_line:
			if new_text != config.get_value("settings", "log_header_format", ""):
				log_header_apply_btn.disabled = false
			else:
				log_header_apply_btn.disabled = true

		entry_format_line:
			if _is_entry_format_valid(new_text):
				entry_format_line.add_theme_stylebox_override("normal", valid_line_edit_stylebox)
				entry_format_warning.visible = false
			else:
				entry_format_line.add_theme_stylebox_override("normal", invalid_line_edit_stylebox)
				entry_format_warning.visible = true

			if new_text != config.get_value("settings", "entry_format", "") and _is_entry_format_valid(new_text):
				entry_format_apply_btn.disabled = false
			else:
				entry_format_apply_btn.disabled = true


func _on_line_edit_text_submitted(new_text: String, node: LineEdit) -> void:
	match node:
		base_dir_line:
			base_dir_line.release_focus()

		log_header_line:
			log_header_line.release_focus()

		entry_format_line:
			entry_format_line.release_focus()


func _on_optbtn_item_selected(index: int, node: OptionButton) -> void:
	match node:
		limit_method_btn:
			config.set_value("settings", "limit_method", index)
			match index:
				LimitMethod.ENTRY_COUNT:
					entry_count_action_container.show()
					entry_count_container.show()
					session_timer_action_container.hide()
					session_duration_container.hide()
				LimitMethod.SESSION_TIMER:
					entry_count_action_container.hide()
					entry_count_container.hide()
					session_timer_action_container.show()
					session_duration_container.show()
				LimitMethod.BOTH:
					entry_count_action_container.show()
					entry_count_container.show()
					session_timer_action_container.show()
					session_duration_container.show()
				LimitMethod.NONE:
					entry_count_action_container.hide()
					entry_count_container.hide()
					session_timer_action_container.hide()
					session_duration_container.hide()
			if !suppress_history_prints:
				print_rich(c_print_history, "Limit method changed.")

		entry_count_action_btn:
			config.set_value("settings", "entry_count_action", index)
			if !suppress_history_prints:
				print_rich(c_print_history, "Entry Count Action changed")

		session_timer_action_btn:
			config.set_value("settings", "session_timer_action", index)
			if !suppress_history_prints:
				print_rich(c_print_history, "Session Timer Action changed.")

		error_rep_btn:
			config.set_value("settings", "error_reporting", index)
			if !suppress_history_prints:
				print_rich(c_print_history, "Error Reporting level changed.")

		id_overlay_align_opt_btn:
			config.set_value("settings", "id_overlay_align", index)

			if !suppress_history_prints:
				print_rich(c_print_history,"ID Overlay anchor alignment changed.")

	save_data()


func _on_checkbutton_toggled(toggled_on: bool, node: CheckButton) -> void:
	match node:

		autostart_btn:
			config.set_value("settings", "autostart_session", toggled_on)
			if !suppress_history_prints:
				print_rich(c_print_history + "Autostart session option " + "enabled." if toggled_on else c_print_history + "Autostart session option " + "disabled.")

		utc_btn:
			config.set_value("settings", "use_utc", toggled_on)
			if !suppress_history_prints:
				print_rich(c_print_history + "Use UTC option " + "enabled." if toggled_on else c_print_history + "Use UTC option " + "disabled.")

		print_instance_id_btn:
			config.set_value("settings", "id_overlay_print", toggled_on)
			if !suppress_history_prints:
				print_rich(c_print_history + "Print Instance ID option " + "enabled." if toggled_on else c_print_history + "Print Instance ID option " + "disabled.")

		id_overlay_toggle_btn:
			config.set_value("settings", "id_overlay_toggle", toggled_on)
			id_overlay_startup_btn.show() if toggled_on else id_overlay_startup_btn.hide()
			if !suppress_history_prints:
				print_rich(c_print_history + "Instance ID Overlay " + "enabled." if toggled_on else c_print_history + "Instance ID Overlay " + "disabled.")

		id_overlay_startup_btn:
			config.set_value("settings", "id_overlay_startup_state", toggled_on)
			if !suppress_history_prints:
				print_rich(c_print_history + "Instance ID Overlay on startup " + "enabled." if toggled_on else c_print_history + "Instance ID Overlay on startup " + "disabled.")
	save_data()


func _on_spinbox_value_changed(value: float, node: SpinBox) -> void:
	config.load(PATH)

	var u_line = node.get_line_edit()
	u_line.set_caret_column(u_line.text.length())
	if u_line.get_caret_column() == u_line.text.length() - 1:
		u_line.set_caret_column(u_line.text.length())
	else: u_line.set_caret_column(u_line.get_caret_column() + 1)

	match node:
		entry_count_spinbox:
			config.set_value("settings", "entry_cap", int(value))
			if !suppress_history_prints:
				print_rich(c_print_history, "Entry count limit changed.")

		session_duration_spinbox:
			config.set_value("settings", "session_duration", int(value))
			if !suppress_history_prints:
				print_rich(c_print_history, "Session duration changed.")

		file_count_spinbox:
			config.set_value("settings", "file_cap", int(value))
			if !suppress_history_prints:
				print_rich(c_print_history, "File count limit changed.")

		id_overlay_font_size_spinbox:
			config.set_value("settings", "id_overlay_font_size", value)
			var fnt_col := 	Color.from_string(config.get_value("settings", "id_overlay_color", "ffffffff"), settings_dict.get("defaults").get("id_overlay_color"))
			var ol_sz := 		config.get_value("settings", "id_overlay_outline_size", settings_dict.get("defaults").get("id_overlay_outline_size"))
			var ol_col := 	Color.from_string(config.get_value("settings", "id_overlay_outline_color", "00000000"), settings_dict.get("defaults").get("id_overlay_outline_color"))

			id_overlay_example_lbl.text = str("[font_size=", value, "][color=", fnt_col.to_html(), "][outline_size=", ol_sz, "][outline_color=", ol_col.to_html(), "]h9Em2")

			if !suppress_history_prints:
				print_rich(c_print_history, "ID Overlay Font Size changed.")

		id_overlay_outline_size_spinbox:
			config.set_value("settings", "id_overlay_outline_size", value)
			var fnt_sz := 	int(config.get_value("settings", "id_overlay_font_size", settings_dict.get("defaults").get("id_overlay_font_size")))
			var fnt_col := 	Color.from_string(config.get_value("settings", "id_overlay_color", "ffffffff"), settings_dict.get("defaults").get("id_overlay_color"))
			var ol_col := 	Color.from_string(config.get_value("settings", "id_overlay_outline_color", "00000000"), settings_dict.get("defaults").get("id_overlay_outline_color"))

			id_overlay_example_lbl.text = str("[font_size=", fnt_sz, "][color=", fnt_col.to_html(), "][outline_size=", value, "][outline_color=", ol_col.to_html(), "]h9Em2")
			if !suppress_history_prints:
				print_rich(c_print_history, "ID Overlay Outline Size changed.")

	save_data()


func _on_spinbox_lineedit_submitted(new_text: String, node: Control) -> void:
	config.load(PATH)
	match node:

		file_count_spinbox_line:
			var value = int(new_text)
			config.set_value("settings", "file_cap", value)
			file_count_spinbox_line.release_focus()
			file_count_spinbox.release_focus()
			if !suppress_history_prints:
				print_rich(c_print_history, "File count limit changed.")

		entry_count_spinbox_line:
			var value = int(new_text)
			config.set_value("settings", "entry_cap", value)
			entry_count_spinbox.release_focus()
			entry_count_spinbox_line.release_focus()
			if !suppress_history_prints:
				print_rich(c_print_history, "Entry count limit changed.")

		session_duration_spinbox_line:
			var value = float(new_text)
			config.set_value("settings", "session_duration", value)
			session_duration_spinbox.release_focus()
			session_duration_spinbox_line.release_focus()
			if !suppress_history_prints:
				print_rich(c_print_history, "Session duration changed.")

		id_overlay_font_size_spinbox:
			config.set_value("settings", "id_overlay_font_size", int(new_text))
			var fnt_col := 	Color.from_string(config.get_value("settings", "id_overlay_color", "ffffffff"), settings_dict.get("defaults").get("id_overlay_color"))
			var ol_sz := 		int(config.get_value("settings", "id_overlay_outline_size", settings_dict.get("defaults").get("id_overlay_outline_size")))
			var ol_col := 	Color.from_string(config.get_value("settings", "id_overlay_outline_color", "00000000"), settings_dict.get("defaults").get("id_overlay_outline_color"))

			id_overlay_example_lbl.text = str("[font_size=", int(new_text), "][color=", fnt_col.to_html(), "][outline_size=", ol_sz, "][outline_color=", ol_col.to_html(), "]h9Em2")

			if !suppress_history_prints:
				print_rich(c_print_history, "ID Overlay Font Size changed.")

		id_overlay_outline_size_spinbox:
			config.set_value("settings", "id_overlay_font_size", int(new_text))
			var fnt_sz := 	int(config.get_value("settings", "id_overlay_font_size", settings_dict.get("defaults").get("id_overlay_font_size")))
			var fnt_col := 	Color.from_string(config.get_value("settings", "id_overlay_color", "ffffffff"), settings_dict.get("defaults").get("id_overlay_color"))
			var ol_col := 	Color.from_string(config.get_value("settings", "id_overlay_outline_color", "00000000"), settings_dict.get("defaults").get("id_overlay_outline_color"))

			id_overlay_example_lbl.text = str("[font_size=", fnt_sz, "][color=", fnt_col.to_html(), "][outline_size=", int(new_text), "][outline_color=", ol_col.to_html(), "]h9Em2")

			if !suppress_history_prints:
				print_rich(c_print_history, "ID Overlay Outline Size changed.")

	save_data()


func _on_colorpicker_color_changed(col: Color, node: ColorPickerButton) -> void:
	config.load(PATH)
	var fnt_sz := 	int(config.get_value("settings", "id_overlay_font_size", settings_dict.get("defaults").get("id_overlay_font_size")))
	var fnt_col := 	Color.from_string(config.get_value("settings", "id_overlay_color", "ffffffff"), settings_dict.get("defaults").get("id_overlay_color"))
	var ol_sz := 		int(config.get_value("settings", "id_overlay_outline_size", settings_dict.get("defaults").get("id_overlay_outline_size")))
	var ol_col := 	Color.from_string(config.get_value("settings", "id_overlay_outline_color", "00000000"), settings_dict.get("defaults").get("id_overlay_outline_color"))

	match node:
		id_overlay_font_col_btn:
			config.set_value("settings", "id_overlay_color", col.to_html())

			id_overlay_example_lbl.text = str("[font_size=", fnt_sz, "][color=", col.to_html(), "][outline_size=", ol_sz, "][outline_color=", ol_col.to_html(), "]h9Em2")

			if !suppress_history_prints:
				print_rich(c_print_history, "Instance ID Overlay color changed.")

		id_overlay_outline_col_btn:
			config.set_value("settings", "id_overlay_outline_color", col.to_html())
			id_overlay_example_lbl.text = str("[font_size=", fnt_sz, "][color=", fnt_col.to_html(), "][outline_size=", ol_sz, "][outline_color=", col.to_html(), "]h9Em2")

			if !suppress_history_prints:
				print_rich(c_print_history, "Instance ID Overlay outline color changed.")

	config.save(PATH)


func _on_category_line_focus(data: Array, focused: bool) -> void:
	# Stores the data of the currently focused category line edit to compare against
	if focused and data.size() > 0:
		focused_category.append(data)
	else:
		focused_category.clear()


func _on_column_slider_value_changed(value: int) -> void:
	category_container.columns = _get_column_value(value)
	column_slider.tooltip_text = str("Columns: ", _get_column_value(value))
	config.set_value("settings", "columns", _get_column_value(value))
	save_data()


func _on_line_edit_highlight_changed(highlight_on: bool, line_edit: LineEdit) -> void:
	if highlight_on:
		line_edit.add_theme_stylebox_override("normal", sb_line_edit_highlight)
	else:
		line_edit.add_theme_stylebox_override("normal", sb_line_edit_normal)


func _on_editor_settings_changed() -> void:
	settings = EditorInterface.get_editor_settings()
	editor_base_col = settings.get("interface/theme/base_color")
	_sync_stylebox_colors(self)


## Returns the inverted value for the column slider
func _get_column_value(slider_value: int) -> int:
	return clampi(slider_value, column_slider.min_value, column_slider.max_value)


func _ensure_default_category() -> void:
	config.load(PATH)
	if  config.get_value("categories", "category_names").is_empty() and config.get_value("categories", "default_category")\
	or !config.get_value("categories", "category_names").has(config.get_value("categories", "default_category")):
		config.set_value("categories", "default_category", "")
		config.save(PATH)


func _sync_stylebox_colors(current_node: Control):
	# var editor_theme 				= EditorInterface.get_editor_theme()

	var _base_col: Color 		= settings.get("interface/theme/base_color")
	var _accent_col: Color 	= settings.get("interface/theme/accent_color")
	var _contrast: float 		= settings.get("interface/theme/contrast")

	if  _contrast   == editor_contrast\
	and _base_col   == editor_base_col\
	and _accent_col == editor_accent_col:
		return

	var accent_contrast_l 	= editor_accent_col.lerp(	Color.WHITE, _contrast)
	var accent_contrast_l_h = editor_accent_col.lerp(	Color.WHITE, _contrast / 2)
	var accent_contrast_d 	= editor_accent_col.lerp(	Color.BLACK, _contrast)
	var accent_contrast_d_h = editor_accent_col.lerp(	Color.BLACK, _contrast / 2)
	var base_contrast_l 		= editor_base_col.lerp(		Color.WHITE, _contrast)
	var base_contrast_l_h 	= editor_base_col.lerp(		Color.WHITE, _contrast / 2)
	var base_contrast_d 		= editor_base_col.lerp(		Color.BLACK, _contrast)
	var base_contrast_d_h 	= editor_base_col.lerp(		Color.BLACK, _contrast / 2)
	# var shift = _contrast + 2 if _contrast > 0 else _contrast - 2
	# shift = clamp(shift, -1.0, 1.0)
	var base_contrast_d_d = base_contrast_d.lerp(Color.BLACK if _contrast > 0 else Color.WHITE,_contrast)

	panel_round_bg.bg_color = base_contrast_d
	panel_round_base.bg_color = editor_base_col
	panel_round_base_highlight.bg_color = editor_base_col
	panel_round_base_highlight.border_color = editor_accent_col
	panel_round_accent.bg_color = editor_accent_col
	panel_round_accent_muted.bg_color = accent_contrast_d_h
	panel_top_round_base.bg_color = editor_base_col
	panel_top_round_base_highlight.bg_color = editor_base_col
	panel_top_round_base_highlight.border_color = editor_accent_col
	panel_top_round_accent.bg_color = editor_accent_col
	panel_top_round_accent_muted.bg_color = accent_contrast_d_h

	sb_tab_bar_bg.bg_color = editor_base_col
	sb_tab_unselected.bg_color = Color.TRANSPARENT
	sb_tab_selected.bg_color = accent_contrast_d
	sb_tab_hover.bg_color = Color.TRANSPARENT
	sb_tab_hover.border_color = editor_accent_col

	sb_btn_normal.bg_color = Color.TRANSPARENT
	sb_btn_highlight.bg_color = Color.TRANSPARENT
	sb_btn_highlight.border_color = editor_accent_col
	sb_btn_top_highlight.bg_color = Color.TRANSPARENT
	sb_btn_top_highlight.border_color = editor_accent_col

	sb_clrpicker_normal.bg_color = Color.TRANSPARENT
	sb_clrpicker_highlight.bg_color = Color.TRANSPARENT
	sb_clrpicker_highlight.border_color = editor_accent_col

	sb_line_edit_normal.bg_color = base_contrast_d_d
	sb_line_edit_highlight.bg_color = base_contrast_d_d
	sb_line_edit_highlight.border_color = editor_accent_col


	var norm_font_col:													= Color(0.878, 0.878, 0.878)
	var hover_font_col:													= Color(0.95, 0.95, 0.95)
	var interact_normal_c 											= editor_base_col
	var interact_hover_c 												= base_contrast_l
	var interact_pressed_c 											= editor_base_col
	var interact_pressed_hover_c 								= base_contrast_l


	var fold_conts: Array[FoldableContainer] 		= [general_fold_cont, limit_fold_cont, id_overlay_fold_cont]
	for cont in fold_conts:
		cont.add_theme_color_override("font_color", 						norm_font_col 	if interact_normal_c.v 					< 0.7 else base_contrast_d)
		cont.add_theme_color_override("hover_font_color", 			hover_font_col 	if interact_hover_c.v 					< 0.7 else editor_base_col)
		cont.add_theme_color_override("collapsed_font_color", 	Color.WHITE 		if base_contrast_l_h.v 					< 0.7 else editor_base_col)
		cont.add_theme_color_override("title_collapsed_hover", 	Color.WHITE 		if interact_pressed_hover_c.v 	< 0.7 else editor_base_col)

	var opt_btns: Array[OptionButton] = [
		error_rep_btn,
		limit_method_btn,
		entry_count_action_btn,
		session_timer_action_btn,
		id_overlay_align_opt_btn,
	]

	for btn in opt_btns:
		btn.add_theme_color_override("font_color", 								norm_font_col 	if interact_normal_c.v 					< 0.7 else editor_base_col)
		btn.add_theme_color_override("font_pressed_color", 				hover_font_col 	if interact_hover_c.v 					< 0.7 else editor_base_col)
		btn.add_theme_color_override("font_hover_color", 					Color.WHITE 		if interact_pressed_c.v 				< 0.7 else editor_base_col)
		btn.add_theme_color_override("font_hover_pressed_color", 	Color.WHITE 		if interact_pressed_hover_c.v 	< 0.7 else editor_base_col)
