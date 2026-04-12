@tool
extends TabContainer

# Adding a new setting:
	# Add the settings to all appropriate dictionaries in "settings_dict"
	# In _ready(), add the settings control node to btn_array so it's included in the uniform signal connections loop
	# If setting requires a Container node to show tooltips(as is the case for most) add the container node to container_array and add the appropriate index in the corresponding_lbls array for the font color changes on mouse hover
	# Implement the logic for applying the setting in signal function like _on_button_button_up()

# TODO:
	#
	#

	# DOCK CATEGORY TAB:


	# DOCK SETTINGS TAB:


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
@onready var base_dir_container: HBoxContainer = %BaseDirHBox

@onready var log_header_line: LineEdit = %LogHeaderLineEdit
@onready var log_header_lbl: Label = %LogHeaderLabel
@onready var log_header_apply_btn: Button = %LogHeaderApplyButton
@onready var log_header_container: HBoxContainer = %LogHeaderHBox

@onready var entry_format_line: LineEdit = %EntryFormatLineEdit
@onready var entry_format_lbl: Label = %EntryFormatLabel
@onready var entry_format_apply_btn: Button = %EntryFormatApplyButton
@onready var entry_format_warning: Panel = %EntryFormatWarning
@onready var entry_format_container: HBoxContainer = %EntryFormatHBox

@onready var autostart_btn: CheckBox = %AutostartCheckBox
@onready var utc_btn: CheckBox = %UTCCheckBox

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

@onready var print_instance_id_btn: CheckBox = %PrintInstanceIDCheckBox
@onready var id_overlay_font_size_hbox: HBoxContainer = %IDOverlayFontSizeHBox
@onready var id_overlay_example_lbl: RichTextLabel = %IDOverlayExampleLabel

@onready var id_overlay_align_container: HBoxContainer = %IDOverlayAlignHBox
@onready var id_overlay_align_opt_btn: OptionButton = %IDOverlayAlignOptButton
@onready var id_overlay_align_lbl: Label = %IDOverlayAlignLabel

var id_overlay_font_size_spinbox_line: LineEdit
@onready var id_overlay_font_size_spinbox: SpinBox = %IDOverlayFontSizeSpinBox
@onready var id_overlay_font_size_lbl: Label = %IDOverlayFontSizeLabel
@onready var id_overlay_toggle_btn: CheckBox = %IDOverlayToggleShowCheckBox
@onready var id_overlay_startup_btn: CheckBox = %ShowOnStartupInstanceIDCheckBox
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
@onready var limit_fold_cont: FoldableContainer = %LimitersFoldableContainer
@onready var id_overlay_fold_cont: FoldableContainer = %IDOverlayFoldableContainer

var theme_colors: Dictionary = {}
@onready var settings = EditorInterface.get_editor_settings()
@onready var editor_base_col: Color = settings.get("interface/theme/base_color")
@onready var editor_accent_col: Color = settings.get("interface/theme/accent_color")
@onready var editor_contrast = settings.get("interface/theme/contrast")

var sb_tab_bar_bg 										:= preload("uid://beo2bu5ofsw0u")
var sb_tab_unselected 								:= preload("uid://427jdnrjcbba")
var sb_tab_selected 									:= preload("uid://cy0ifp487jfcg")
var sb_tab_hover 											:= preload("uid://yxpx0pyjme8s")

var panel_round_bg 										:= preload("uid://dqfhm2ywaj4dr")
var panel_round_base 									:= preload("uid://cywnobmluy31i")
var panel_round_base_border_highlight := preload("uid://qbiwr8hnwf5n")
var panel_round_highlight 						:= preload("uid://b0ho2njwihy2p")
var panel_round_accent 								:= preload("uid://3r3hhcvqp2au")
var panel_round_accent_muted 					:= preload("uid://l18dbl63e366")
var panel_top_round_base 							:= preload("uid://cqnilt2rk14bi")
var panel_top_round_base_highlight 		:= preload("uid://0nxkxhcntsj3")
var panel_top_round_accent 						:= preload("uid://dve2ih1gvvua7")
var panel_top_round_accent_muted 			:= preload("uid://7s65f804p1jc")

var sb_btn_normal 										:= preload("uid://di36bptu4b3n")
var sb_btn_highlight 									:= preload("uid://dcjwu6ej2w2s4")
var sb_btn_top_highlight 							:= preload("uid://lyngp43l4n0n")
var sb_btn_apply 											:= preload("uid://bwsfno28una6g")

var sb_clrpicker_normal								:= preload("uid://bth006ulwoyl3")
var sb_clrpicker_highlight 						:= preload("uid://bv58jw0dd3sve")

var sb_line_edit_normal 							:= preload("uid://pue22dsifmfd")
var sb_line_edit_highlight 						:= preload("uid://dl1ay0wubtp2m")
var sb_line_edit_invalid 							:= preload("uid://sqhht0mdddoi")

var sb_spinbox_up_highlight 					:= preload("uid://bvek0vh8shw5l")
var sb_spinbox_up_pressed 						:= preload("uid://q0h5bi585ik6")
var sb_spinbox_down_highlight 				:= preload("uid://ba2pkgbcu0dlo")
var sb_spinbox_down_pressed 					:= preload("uid://daw4nhpnjj6i1")

var gl_hotkeys: GLShortcut 						=  preload("uid://dyi2aml73k4g8")

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
var category_scene = preload("uid://c3n416c5fajm5")
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
	"category_names": 						{"section": "categories", "name": "category_names", 						"value": ["game"], 	"type": TYPE_ARRAY,  	"default": ["game"]},
	"default_category": 					{"section": "categories", "name": "default_category", 					"value": "", 				"type": TYPE_STRING,  "default": ""},
	"base_directory": 						{"section": "settings", 	"name": "base_directory", 						"value": "user://GoLogger/", "type": TYPE_STRING, "control": null, "default": "user://GoLogger/"},
	"log_header_format": 					{"section": "settings", 	"name": "log_header_format", 					"value": "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:", "type": TYPE_STRING, "control": null,  "default": "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:"},
	"entry_format": 							{"section": "settings", 	"name": "entry_format", 							"value": "[{hh}:{mi}:{ss}] {instance_id}: {entry}", "type": TYPE_STRING, "control": null, "default": "[{hh}:{mi}:{ss}] {instance_id}: {entry}"},
	"autostart_session": 					{"section": "settings", 	"name": "autostart_session", 					"value": true, 			"type": TYPE_BOOL, 		"control": null, "default": true},
	"use_utc": 										{"section": "settings", 	"name": "use_utc", 										"value": false, 		"type": TYPE_BOOL, 		"control": null, "default": false},
	"id_overlay_print": 					{"section": "settings", 	"name": "id_overlay_print", 					"value": false, 		"type": TYPE_BOOL, 		"control": null, "default": false},
	"id_overlay_toggle": 					{"section": "settings", 	"name": "id_overlay_toggle", 					"value": false, 		"type": TYPE_BOOL, 		"control": null, "default": false},
	"id_overlay_startup_state": 	{"section": "settings", 	"name": "id_overlay_startup_state", 	"value": false, 		"type": TYPE_BOOL, 		"control": null, "default": false},
	"id_overlay_align":						{"section": "settings", 	"name": "id_overlay_align", 					"value": 0, 				"type": TYPE_INT,			"control": null, "default": 0},
	"id_overlay_font_size":				{"section": "settings", 	"name": "id_overlay_font_size", 			"value": 12, 				"type": TYPE_INT, 		"control": null, "default": 12},
	"id_overlay_font_color":			{"section": "settings", 	"name": "id_overlay_font_color", 			"value": "ffffff", 	"type": TYPE_STRING, 	"control": null, "default": "ffffff"},
	"id_overlay_outline_size":		{"section": "settings", 	"name": "id_overlay_outline_size", 		"value": 8,					"type": TYPE_INT,			"control": null, "default": 8},
	"id_overlay_outline_color":		{"section": "settings", 	"name": "id_overlay_outline_color", 	"value": "000000", 	"type": TYPE_STRING,	"control": null, "default": "000000"},
	"limit_method": 							{"section": "settings", 	"name": "limit_method", 							"value": 0, 				"type": TYPE_INT, 		"control": null, "default": 0},
	"entry_count_action": 				{"section": "settings", 	"name": "entry_count_action", 				"value": 0, 				"type": TYPE_INT, 		"control": null, "default": 0},
	"session_timer_action": 			{"section": "settings", 	"name": "session_timer_action", 			"value": 0, 				"type": TYPE_INT, 		"control": null, "default": 0},
	"file_cap": 									{"section": "settings", 	"name": "file_cap", 									"value": 10, 				"type": TYPE_INT, 		"control": null, "default": 10},
	"entry_cap": 									{"section": "settings", 	"name": "entry_cap", 									"value": 1200, 			"type": TYPE_INT, 		"control": null, "default": 1200},
	"session_duration": 					{"section": "settings", 	"name": "session_duration", 					"value": 900, 			"type": TYPE_INT, 		"control": null, "default": 900},
	"error_reporting": 						{"section": "settings", 	"name": "error_reporting", 						"value": 0, 				"type": TYPE_INT, 		"control": null, "default": 0},
	"columns": 										{"section": "settings", 	"name": "columns", 										"value": 5, 				"type": TYPE_INT, 		"control": null, "default": 5}
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
		base_dir_apply_btn.hide()
		log_header_apply_btn.hide()
		entry_format_apply_btn.hide()

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

			if btn_array[i] is CheckBox:
				if btn_array[i].toggled.is_connected(_on_checkbox_toggled):
					btn_array[i].toggled.disconnect(_on_checkbox_toggled)
				btn_array[i].toggled.connect(_on_checkbox_toggled.bind(btn_array[i]))

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
			# Update font color on container mouse over containers signals
			container_array[i].mouse_entered.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], true))
			container_array[i].mouse_exited.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], false))

			# Update font color on button mouse over signals
			btns_array[i].mouse_entered.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], true))
			btns_array[i].mouse_exited.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], false))

		for lbl in corresponding_lbls:
			lbl.add_theme_color_override("font_color", c_font_normal)


		for btn in [base_dir_apply_btn, log_header_apply_btn, entry_format_apply_btn]:
			if btn.button_up.is_connected(_on_button_button_up):
				btn.button_up.disconnect(_on_button_button_up)
			btn.button_up.connect(_on_button_button_up.bind(btn))

		open_hotkey_btn.button_up.connect(func() -> void: open_hotkey_resource.emit())


		# match config.get_value("settings", "limit_method", settings_dict.get("defaults", {}).get("limit_method", 0)):
		match config.get_value("settings", "limit_method", settings_dict.get("limit_method", {}).get("default", 0)):
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
		initialize_dock()
		_apply_theme_colors(self)

		await get_tree().process_frame
		suppress_history_prints = false

		settings_dict["base_directory"]["control"] = 						base_dir_line
		settings_dict["log_header_format"]["control"] = 				log_header_line
		settings_dict["entry_format"]["control"] = 							entry_format_line
		settings_dict["autostart_session"]["control"] = 				autostart_btn
		settings_dict["use_utc"]["control"] = 									utc_btn
		settings_dict["id_overlay_print"]["control"] = 					print_instance_id_btn
		settings_dict["id_overlay_toggle"]["control"] = 				id_overlay_toggle_btn
		settings_dict["id_overlay_startup_state"]["control"] = 	id_overlay_startup_btn
		settings_dict["id_overlay_align"]["control"] = 					id_overlay_align_opt_btn
		settings_dict["id_overlay_font_size"]["control"] = 			id_overlay_font_size_spinbox
		settings_dict["id_overlay_font_color"]["control"] =			id_overlay_font_col_btn
		settings_dict["id_overlay_outline_size"]["control"] = 	id_overlay_outline_size_spinbox
		settings_dict["id_overlay_outline_color"]["control"] =	id_overlay_outline_col_btn
		settings_dict["limit_method"]["control"] = 							limit_method_btn
		settings_dict["entry_count_action"]["control"] = 				entry_count_action_btn
		settings_dict["session_timer_action"]["control"] = 			session_timer_action_btn
		settings_dict["file_cap"]["control"] = 									file_count_spinbox
		settings_dict["entry_cap"]["control"] = 								entry_count_spinbox
		settings_dict["session_duration"]["control"] = 					session_duration_spinbox
		settings_dict["error_reporting"]["control"] = 					error_rep_btn
		settings_dict["columns"]["control"] = 									column_slider






func create_settings_file() -> void: # Mirror
	var cf := ConfigFile.new()

	for key in settings_dict.keys():
		for field in ["section", "value", "type", "control", "default"]:
			if field == "control" and settings_dict[key]["section"] == "categories":
				continue

			if not settings_dict[key].has(field):
				push_error("GoLogger: Error creating a settings file. 'settings_dict' entry '%s' missing '", field, "' field", % key)
				continue

		var section = settings_dict[key].get("section", "settings")
		cf.set_value(section, key, settings_dict[key]["default"])

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

	for key in settings_dict.keys():
		if settings_dict[key]["section"] == "categories":
			continue

		cf.set_value("settings", key, settings_dict.get(key, {}).get("defaults", null))

	cf.set_value("categories.game", "category_name", "game")
	cf.set_value("categories.game", "category_index", 0)
	cf.set_value("categories.game", "file_count", 0)
	cf.set_value("categories.game", "is_locked", false)
	cf.save(PATH)

	base_dir_line.text = 											settings_dict.get("base_directory"								).get("value", "user://GoLogger/")
	log_header_line.text = 										settings_dict.get("log_header_format"							).get("value", "")
	entry_format_line.text = 									settings_dict.get("entry_count_format"						).get("value", "")
	autostart_btn.button_pressed = 						settings_dict.get("autostart_session"							).get("value", true)
	utc_btn.button_pressed = 									settings_dict.get("use_utc"												).get("value", false)
	print_instance_id_btn.button_pressed = 		settings_dict.get("id_overlay_print"							).get("value", false)
	id_overlay_toggle_btn.button_pressed = 		settings_dict.get("id_overlay_toggle"							).get("value", false)
	id_overlay_startup_btn.button_pressed = 	settings_dict.get("id_overlay_startup_state"			).get("value", false)
	id_overlay_align_opt_btn.selected = 			settings_dict.get("id_overlay_align"							).get("value", 0)
	id_overlay_font_size_spinbox.value = 			settings_dict.get("id_overlay_font_size"					).get("value", 12)
	id_overlay_font_col_btn.color = 		Color(settings_dict.get("id_overlay_color"							).get("value", "ffffff"))
	id_overlay_font_size_spinbox.value = 			settings_dict.get("id_overlay_outline_size"				).get("value", 8)
	id_overlay_outline_col_btn.color = 	Color(settings_dict.get("id_overlay_outline_color"			).get("value"))
	limit_method_btn.selected = 							settings_dict.get("limit_method"									).get("value", 0)
	entry_count_action_btn.selected = 				settings_dict.get("entry_count_action"						).get("value", 0)
	session_timer_action_btn.selected = 			settings_dict.get("session_timer_action"					).get("value", 0)
	file_count_spinbox.value = 								settings_dict.get("file_cap"											).get("value", 10)
	entry_count_spinbox.value = 							settings_dict.get("entry_cap"											).get("value", 1200)
	session_duration_spinbox.value = 					settings_dict.get("session_duration"							).get("value", 900)
	error_rep_btn.selected = 									settings_dict.get("error_reporting"								).get("value", 0)
	column_slider.value = 										_get_column_value(settings_dict.get("columns", {}	).get("value", 5))

	base_dir_apply_btn.disabled = true
	base_dir_apply_btn.hide()
	log_header_apply_btn.disabled = true
	log_header_apply_btn.hide()
	entry_format_apply_btn.disabled = true
	entry_format_apply_btn.hide()

	if !suppress_history_prints:
		print_rich(str(c_print_history, "Reset Categories and settings to defaults."))



func validate_settings() -> void: # Mirror
	config.load(PATH)
	_ensure_default_category()

	for key in settings_dict.keys():
			var setting: Dictionary = settings_dict.get(key, {})
			var a_fields = ["section", "name", "value", "type", "control", "default"]
			var b_fields = ["section", "name", "value", "type", "default"]
			var err: Array[bool] = [false, false,false, false, false, false]

			# Check missing fields
			for i in range(a_fields.size()):

				if setting.has("section"):
					var fs = a_fields.duplicate()

					if setting["section"] == "categories":
						fs = b_fields.duplicate()

					# Collect + report missing fields
					if !setting.has_all(fs):
						var _e: Array[String] = []
						for j in range(fs.size()):
							if !setting.has(fs[j]):
								_e.append(fs[j])

						if not _e.is_empty():
							push_warning(str("GoLogger error: invalid settings_dict key. Missing field(s) ", _e, " for setting <", key, ">"))

			# Validate
			# Presence
			if !config.has_section(setting["section"]) or !config.has_section_key(setting["section"], setting["name"]):
				config.set_value(setting["section"], setting["name"], setting["default"])
				continue

			# Type
			if typeof(config.get_value(setting["section"], setting["name"])) != setting["type"]:
				config.set_value(setting["section"], setting["name"], setting["default"])

			config.save(PATH)



func initialize_dock() -> void:
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
	base_dir_line.text = 										_c.get_value("settings", "base_directory", 						settings_dict.get("defaults", 									{}).get("base_directory", "user://GoLogger/"))
	log_header_line.text = 									_c.get_value("settings", "log_header_format", 				settings_dict.get("defaults", 									{}).get("log_header_format", "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:"))
	entry_format_line.text = 								_c.get_value("settings", "entry_format", 							settings_dict.get("defaults", 									{}).get("entry_format", "[{hh}:{mi}:{ss}] {instance_id}: {entry}"))
	autostart_btn.button_pressed = 					_c.get_value("settings", "autostart_session", 				settings_dict.get("autostart_session", 					{}).get("default"))
	utc_btn.button_pressed = 								_c.get_value("settings", "use_utc", 									settings_dict.get("use_utc", {}).get("default", false))
	print_instance_id_btn.button_pressed = 	_c.get_value("settings", "id_overlay_print", 					settings_dict.get("id_overlay_print", 					{}).get("default"))
	id_overlay_toggle_btn.button_pressed = 	_c.get_value("settings", "id_overlay_toggle", 				settings_dict.get("id_overlay_toggle", 					{}).get("default"))
	id_overlay_startup_btn.button_pressed = _c.get_value("settings", "id_overlay_startup_state", 	settings_dict.get("id_overlay_startup_state", 	{}).get("default"))
	id_overlay_font_size_spinbox.value = 		_c.get_value("settings", "id_overlay_font_size", 			settings_dict.get("id_overlay_font_size", 			{}).get("default"))
	id_overlay_font_col_btn.color = 	Color(_c.get_value("settings", "id_overlay_color", 					settings_dict.get("id_overlay_color", 					{}).get("default")))
	id_overlay_outline_size_spinbox.value = _c.get_value("settings", "id_overlay_outline_size", 	settings_dict.get("id_overlay_outline_size", 		{}).get("default"))
	id_overlay_outline_col_btn.color =Color(_c.get_value("settings", "id_overlay_outline_color",	settings_dict.get("id_overlay_outline_color",		{}).get("default")))
	limit_method_btn.selected = 						_c.get_value("settings", "limit_method", 							settings_dict.get("limit_method", 							{}).get("default"))
	entry_count_action_btn.selected = 			_c.get_value("settings", "entry_count_action", 				settings_dict.get("entry_count_action", 				{}).get("default"))
	session_timer_action_btn.selected = 		_c.get_value("settings", "session_timer_action", 			settings_dict.get("session_timer_action", 			{}).get("default"))
	file_count_spinbox.value = 							_c.get_value("settings", "file_cap", 									settings_dict.get("file_cap", 									{}).get("default"))
	entry_count_spinbox.value = 						_c.get_value("settings", "entry_cap", 								settings_dict.get("entry_cap", 									{}).get("default"))
	session_duration_spinbox.value = 				_c.get_value("settings", "session_duration", 					settings_dict.get("session_duration", 					{}).get("default"))
	error_rep_btn.selected = 								_c.get_value("settings", "error_reporting", 					settings_dict.get("error_reporting", 						{}).get("default"))
	column_slider.value = 									_get_column_value(_c.get_value("settings", "columns", settings_dict.get("columns", 										{}).get("default")))
	save_data()
	config.load(PATH)




## Saves all the dock data ( categories and settings state ) to file according to the state/data of the dock.
func save_data(deferred: bool = false) -> void:
	if deferred:
		await get_tree().physics_frame

	config.load(PATH)
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
			_c.set_value("categories." + log_category.category_name, "file_name", 			config.get_value("categories." + log_category.category_name, "file_name", ""))
			_c.set_value("categories." + log_category.category_name, "file_path", 			config.get_value("categories." + log_category.category_name, "file_path", ""))
			_c.set_value("categories." + log_category.category_name, "category_name", 	log_category.category_name)
			_c.set_value("categories." + log_category.category_name, "category_index", 	log_category.index)
			_c.set_value("categories." + log_category.category_name, "file_count", 			config.get_value("categories." + log_category.category_name, "file_count", 0))
			_c.set_value("categories." + log_category.category_name, "is_locked", 			log_category.is_locked)
			_c.set_value("categories." + log_category.category_name, "entry_count", 		config.get_value("categories." + log_category.category_name, "entry_count", 0))

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
		elif ctrl is CheckBox:
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


func apply_categories() -> void:
	config.load(PATH)
	var c := ConfigFile.new()

	for setting in settings_dict.keys():
		if setting == "category_names" or setting == "default_category":
			c.set_value("categories", setting, config.get_value("categories", setting))

		else:
			c.set_value("settings", setting, config.get_value("settings", setting, settings_dict[setting]["default"]))
			c.set_value("settings", setting, config.get_value("settings", setting, settings_dict.get(setting, {}).get("default", settings_dict.get("default", {}).get(setting, null))))

	for cat in category_container.get_children():
		if cat is LogCategory:
			c.set_value("categories." + cat.category_name, "file_name" , "")
			c.set_value("categories." + cat.category_name, "file_path", "")
			c.set_value("categories." + cat.category_name, "category_name", cat.category_name)
			c.set_value("categories." + cat.category_name, "category_index", cat.index)
			c.set_value("categories." + cat.category_name, "file_count", config.get_value("categories." + cat.category_name, "file_count", 0))
			c.set_value("categories." + cat.category_name, "is_locked", cat.is_locked)
			c.set_value("categories." + cat.category_name, "entry_count", config.get_value("categories." + cat.category_name, "entry_count", 0))

	c.save(PATH)


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
	config.load(PATH)
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

	base_dir_line.text = new_dir

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
			base_dir_apply_btn.hide()

		base_dir_opendir_btn:
			if config.get_value("settings", "base_directory") == "":
				push_warning("GoLogger: Base directory path isn't set. Please set a valid directory path before opening the directory.")
			_open_directory()

		log_header_apply_btn:
			config.set_value("settings", "log_header_format", log_header_line.text)
			if !suppress_history_prints:
				print_rich(c_print_history, "Log header changed.")
			log_header_apply_btn.disabled = true
			log_header_line.release_focus()
			base_dir_apply_btn.hide()

		entry_format_apply_btn:
			config.set_value("settings", "entry_format", entry_format_line.text)
			var err := config.save(PATH)
			if !suppress_history_prints:
				print_rich(c_print_history, "Entry format changed.")
			entry_format_apply_btn.disabled = true
			entry_format_line.release_focus()
			log_header_apply_btn.hide()


	save_data()


func _on_line_edit_text_changed(new_text: String, node: LineEdit) -> void:
	config.load(PATH)
	match node:
		base_dir_line:
			if new_text == "":
				base_dir_apply_btn.disabled = true
				base_dir_apply_btn.hide()
			if new_text != config.get_value("settings", "base_directory"):
				base_dir_apply_btn.disabled = false
				base_dir_apply_btn.show()
			else:
				base_dir_apply_btn.disabled = true
				base_dir_apply_btn.hide()

		log_header_line:
			if new_text != config.get_value("settings", "log_header_format", ""):
				log_header_apply_btn.disabled = false
				log_header_apply_btn.show()
			else:
				log_header_apply_btn.disabled = true
				log_header_apply_btn.hide()

		entry_format_line:
			if _is_entry_format_valid(new_text):
				entry_format_line.add_theme_stylebox_override("normal", sb_line_edit_normal)
				entry_format_warning.visible = false
			else:
				entry_format_line.add_theme_stylebox_override("normal", sb_line_edit_invalid)
				entry_format_warning.visible = true

			if new_text != config.get_value("settings", "entry_format", "") and _is_entry_format_valid(new_text):
				entry_format_apply_btn.disabled = false
				entry_format_apply_btn.show()
			else:
				entry_format_apply_btn.disabled = true
				entry_format_apply_btn.hide()


func _on_line_edit_text_submitted(new_text: String, node: LineEdit) -> void:
	match node:
		base_dir_line:
			base_dir_line.release_focus()
			base_dir_apply_btn.hide()
			_apply_new_base_directory()

		log_header_line:
			log_header_line.release_focus()
			log_header_apply_btn.hide()

		entry_format_line:
			entry_format_line.release_focus()
			entry_format_apply_btn.hide()


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


func _on_checkbox_toggled(toggled_on: bool, node: CheckBox) -> void:
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
	config.load(PATH)
	category_container.columns = _get_column_value(value)
	column_slider.tooltip_text = str("Columns: ", _get_column_value(value))
	config.set_value("settings", "columns", _get_column_value(value))
	config.save(PATH)


func _on_line_edit_highlight_changed(highlight_on: bool, line_edit: LineEdit) -> void:
	if highlight_on:
		line_edit.add_theme_stylebox_override("normal", sb_line_edit_highlight)
	else:
		line_edit.add_theme_stylebox_override("normal", sb_line_edit_normal)


func _on_editor_settings_changed() -> void:
	settings = EditorInterface.get_editor_settings()
	editor_base_col = settings.get("interface/theme/base_color")
	_apply_theme_colors(self)


## Returns the inverted value for the column slider
func _get_column_value(slider_value: int) -> int:
	return clampi(slider_value, column_slider.min_value, column_slider.max_value)


func _ensure_default_category() -> void:
	config.load(PATH)
	if  config.get_value("categories", "category_names").is_empty() and config.get_value("categories", "default_category")\
	or !config.get_value("categories", "category_names").has(config.get_value("categories", "default_category")):
		config.set_value("categories", "default_category", "")
		config.save(PATH)



func _get_theme_colors() -> Dictionary:
	var contrast: float = settings.get("interface/theme/contrast")
	var base_col: Color = settings.get("interface/theme/base_color")
	var accent_col: Color = settings.get("interface/theme/accent_color")

	var base_light 			= base_col.lerp(Color.WHITE, contrast)
	var base_dark 			= base_col.lerp(Color.BLACK, contrast)
	var base_light_h 		= base_col.lerp(Color.WHITE, contrast * 0.5)
	var base_dark_h 		= base_col.lerp(Color.BLACK, contrast * 0.5)

	var accent_light 		= accent_col.lerp(Color.WHITE, contrast)
	var accent_dark 		= accent_col.lerp(Color.BLACK, contrast)
	var accent_light_h 	= accent_col.lerp(Color.WHITE, contrast * 0.5)
	var accent_dark_h 	= accent_col.lerp(Color.BLACK, contrast * 0.5)

	var colors := {
		"contrast": contrast,
		"base": {
			"col": base_col,
			"light": base_light,
			"dark": base_dark,
			"light_highlight": base_light_h,
			"dark_highlight": base_dark_h,
		},
		"accent": {
			"col": accent_col,
			"light": accent_light,
			"dark": accent_dark,
			"light_highlight": accent_light_h,
			"dark_highlight": accent_dark_h,
		},
		"font": {
			"normal": Color(0.878, 0.878, 0.878),
			"hover": Color(0.95, 0.95, 0.95),
			"interact_normal": base_col,
			"interact_hover": base_light,
			"interact_pressed": base_col,
			"interact_hover_pressed": base_light
		}
	}
	return colors




func _apply_theme_colors(current_node: Control):
	theme_colors = _get_theme_colors()

	sb_tab_unselected.bg_color 			= Color.TRANSPARENT
	sb_tab_hover.bg_color 					= Color.TRANSPARENT
	sb_btn_normal.bg_color 					= Color.TRANSPARENT
	sb_btn_highlight.bg_color 			= Color.TRANSPARENT
	sb_btn_top_highlight.bg_color 	= Color.TRANSPARENT
	sb_clrpicker_normal.bg_color 		= Color.TRANSPARENT
	sb_clrpicker_highlight.bg_color = Color.TRANSPARENT

	if editor_base_col != theme_colors["base"]["col"] or editor_contrast != theme_colors["contrast"]:
		panel_round_base.bg_color 											= theme_colors["base"]["col"]
		panel_round_highlight.bg_color 									= theme_colors["base"]["col"]
		panel_round_base_border_highlight.bg_color 			= theme_colors["base"]["col"]
		panel_top_round_base.bg_color 									= theme_colors["base"]["col"]
		panel_top_round_base_highlight.bg_color 				= theme_colors["base"]["col"]
		sb_tab_bar_bg.bg_color 													= theme_colors["base"]["col"]
		panel_round_bg.bg_color 												= theme_colors["base"]["dark"]
		sb_line_edit_normal.bg_color 										= theme_colors["base"]["dark_highlight"]
		sb_line_edit_highlight.bg_color 								= theme_colors["base"]["dark_highlight"]


	if editor_accent_col != theme_colors["accent"]["col"] or editor_contrast != theme_colors["contrast"]:
		panel_round_highlight.border_color 							= theme_colors["accent"]["col"]
		panel_round_base_border_highlight.border_color 	= theme_colors["accent"]["col"]
		panel_round_accent.bg_color 										= theme_colors["accent"]["col"]
		panel_top_round_base_highlight.border_color 		= theme_colors["accent"]["col"]
		panel_top_round_accent.bg_color 								= theme_colors["accent"]["col"]
		sb_tab_hover.border_color 											= theme_colors["accent"]["col"]
		sb_btn_highlight.border_color 									= theme_colors["accent"]["col"]
		sb_btn_apply.bg_color 													= theme_colors["accent"]["col"]
		sb_btn_top_highlight.border_color 							= theme_colors["accent"]["col"]
		sb_clrpicker_highlight.border_color 						= theme_colors["accent"]["col"]
		sb_line_edit_highlight.border_color 						= theme_colors["accent"]["col"]
		sb_tab_selected.bg_color 												= theme_colors["accent"]["dark"]
		panel_round_accent_muted.bg_color 							= theme_colors["accent"]["dark_highlight"]
		panel_top_round_accent_muted.bg_color 					= theme_colors["accent"]["dark_highlight"]


	for cont in [general_fold_cont, limit_fold_cont, id_overlay_fold_cont]:
		cont.add_theme_color_override("font_color", 						theme_colors["font"]["normal"] 		if theme_colors["font"]["interact_normal"].v 				< 0.7 else theme_colors["base"]["col"])
		cont.add_theme_color_override("hover_font_color", 			theme_colors["font"]["hover"] 		if theme_colors["font"]["interact_hover"].v 				< 0.7 else theme_colors["base"]["col"])
		cont.add_theme_color_override("collapsed_font_color", 	Color.WHITE 											if theme_colors["base"]["light_highlight"].v 				< 0.7 else theme_colors["base"]["col"])
		cont.add_theme_color_override("title_collapsed_hover", 	Color.WHITE 											if theme_colors["font"]["interact_hover_pressed"].v < 0.7 else theme_colors["base"]["col"])

	for btn in [error_rep_btn, limit_method_btn, entry_count_action_btn,	session_timer_action_btn,	id_overlay_align_opt_btn]:
		btn.add_theme_color_override("font_color", 								theme_colors["font"]["normal"] 	if theme_colors["font"]["interact_normal"].v 				< 0.7 else theme_colors["accent"]["col"])
		btn.add_theme_color_override("font_pressed_color", 				theme_colors["font"]["hover"] 	if theme_colors["font"]["interact_hover"].v 				< 0.7 else theme_colors["accent"]["col"])
		btn.add_theme_color_override("font_hover_color", 					Color.WHITE 										if theme_colors["font"]["interact_pressed"].v 			< 0.7 else theme_colors["accent"]["col"])
		btn.add_theme_color_override("font_hover_pressed_color", 	Color.WHITE											if theme_colors["font"]["interact_hover_pressed"].v < 0.7 else theme_colors["accent"]["col"])
