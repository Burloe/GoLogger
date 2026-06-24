@tool
extends TabContainer

# Adding a new setting:
	# Add the settings to all appropriate dictionaries in "settings_dict"
	# In _ready(), add the settings control node to btn_array so it's included in the uniform signal connections loop
	# If setting requires a Container node to show tooltips(as is the case for most) add the container node to container_array and add the appropriate index in the corresponding_lbls array for the font color changes on mouse hover
	# Implement the logic for applying the setting in signal function like _on_button_button_up()

# TODO:
	# GENERAL:
		# Make a function that hides and shows everything properly that's called at the end of the _ready() function so you don't have to rely on manually showing and hiding all the proper elements constantly.
	# Bugs: 
		# 
	# DOCK CATEGORY TAB:
		# 
	# DOCK SETTINGS TAB:



@export var dev_mode: bool = false:
	set(value):
		dev_mode = value
		for btn in [renable_btn1, renable_btn2, renable_btn3]:
			if btn != null: btn.visible = value
@export var data: GLData = null
var data_path: String = "uid://dj7h7t2v8csck"
@onready var renable_btn1: Button = %RENABLEButton1
@onready var renable_btn2: Button = %RENABLEButton2
@onready var renable_btn3: Button = %RENABLEButton3

# Category tab
@onready var category_tab: HBoxContainer = %CategoriesTab
@onready var add_category_btn: Button = %AddCategoryButton
@onready var category_container: GridContainer = %CategoryGridContainer
@onready var open_dir_btn: Button = %OpenDirCatButton
@onready var reset_settings_btn: Button = %ResetSettingsButton

# Log Browser
@onready var log_browser_tab: HBoxContainer = %LogBrowserTab
@onready var log_browser_view_btn: Button = %ViewModeButton
@onready var log_browser_sort_btn: Button = %SortModeButton
@onready var log_browser_open_dir_btn: Button = %ViewerOpenDirButton

# Settings tab
@onready var settings_tab: HBoxContainer = %SettingsTab
@onready var base_dir_line: LineEdit = %BaseDirLineEdit
@onready var base_dir_lbl: Label = %BaseDirLabel
@onready var base_dir_line_btn_cont: Panel = %BaseDirLineEditButtons
@onready var base_dir_apply_btn: Button = %BaseDirApplyButton
@onready var base_dir_revert_btn: Button = %BaseDirRevertButton
@onready var base_dir_opendir_btn: Button = %BaseDirOpenDirButton
@onready var base_dir_container: HBoxContainer = %BaseDirHBox

@onready var log_header_line: LineEdit = %LogHeaderLineEdit
@onready var log_header_lbl: Label = %LogHeaderLabel
@onready var log_header_line_btn_cont: Panel = %LogHeaderLineEditButtons
@onready var log_header_apply_btn: Button = %LogHeaderApplyButton
@onready var log_header_revert_btn: Button = %LogHeaderRevertButton
@onready var log_header_container: HBoxContainer = %LogHeaderHBox

@onready var entry_format_line: LineEdit = %EntryFormatLineEdit
@onready var entry_format_lbl: Label = %EntryFormatLabel
@onready var entry_format_line_btn_cont: Panel = %EntryFormatLineEditButtons
@onready var entry_format_apply_btn: Button = %EntryFormatApplyButton
@onready var entry_format_revert_btn: Button = %EntryFormatRevertButton
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
var entry_count_spinbox_line: LineEdit
@onready var entry_count_spinbox: SpinBox = %EntryCountSpinBox

@onready var session_timer_action_btn: OptionButton = %SessionTimerActionOptButton
@onready var session_timer_action_lbl: Label = %SessionTimerActionLabel
@onready var session_timer_action_container: HBoxContainer = %SessionTimerActionHBox
var session_duration_spinbox_line: LineEdit
@onready var session_duration_spinbox: SpinBox = %SessionDurationSpinBox

var file_count_spinbox_line: LineEdit
@onready var file_count_spinbox: SpinBox = %FileCountSpinBox
@onready var file_count_lbl: Label = %FileCountLabel
@onready var file_count_container: HBoxContainer = %FileCountHBox 

@onready var error_rep_btn: OptionButton = %ErrorRepOptButton
@onready var error_rep_lbl: Label = %ErrorRepLabel
@onready var error_rep_container: HBoxContainer = %ErrorRepHBox

@onready var plugin_version_sett_lbl: Label = %PluginVersionSettLabel

@onready var id_fold_cont: FoldableContainer = %IDFoldableContainer
@onready var id_align_container: HBoxContainer = %IDAlignHBox
@onready var id_align_lbl: Label = %IDAlignLabel
@onready var id_align_opt_btn: OptionButton = %IDAlignOptButton

@onready var id_toggle_btn: CheckBox = %IDToggleShowCheckBox
@onready var id_startup_btn: CheckBox = %IDStartupCheckBox
@onready var id_print_btn: CheckBox = %IDPrintCheckBox 

@onready var id_font_sett_cont: FoldableContainer = %IDFontFoldableContainer
var id_inspector: EditorInspector

@onready var hotkey_container: FoldableContainer = %HotkeyFoldableContainer
var inspector: EditorInspector

@onready var user_dir_btn: Button = %UserDirButton ## Opens "user://"
@onready var general_fold_cont: FoldableContainer = %GeneralFoldableContainer
@onready var limit_fold_cont: FoldableContainer = %LimitersFoldableContainer
@onready var dir_fold_cont: FoldableContainer = %DirectoryFoldableContainer

# Help tab
@onready var help_tab: 						TabContainer = %HelpTab
@onready var getting_started_tab: ScrollContainer = %GettingStarted
@onready var help_setup: 					FoldableContainer = %SetupHelp
@onready var help_sessions: 			FoldableContainer = %SessionsHelp
@onready var help_categories: 		FoldableContainer = %CategoriesHelp
@onready var help_messages: 			FoldableContainer = %MessagesHelp
@onready var help_concurrencies: 	FoldableContainer = %ConcurrenciesHelp
@onready var help_log_browser:		FoldableContainer = %LogBrowserHelp
@onready var help_functions: 			FoldableContainer = %FunctionsHelp
@onready var help_hotkeys: 				FoldableContainer = %HotkeysHelp
@onready var help_file_limits: 		FoldableContainer = %FileLimitsHelp
@onready var help_formatting: 		FoldableContainer = %FormattingHelp

var theme_colors: Dictionary = {}
@onready var settings = EditorInterface.get_editor_settings()
@onready var editor_base_col: Color = settings.get("interface/theme/base_color")
@onready var editor_accent_col: Color = settings.get("interface/theme/accent_color")
@onready var editor_contrast = settings.get("interface/theme/contrast")

var sb_tab_bar_bg 										:= preload("uid://beo2bu5ofsw0u")
var sb_tab_panel_bg										:= preload("uid://br4lwoor8v8mi")
var sb_tab_panel_no_side_margins 			:= preload("uid://cv3q5yacoro7d")
var sb_tab_unselected 								:= preload("uid://427jdnrjcbba")
var sb_tab_selected 									:= preload("uid://cy0ifp487jfcg")
var sb_tab_hover 											:= preload("uid://yxpx0pyjme8s")

var panel_round_bg 										:= preload("uid://dqfhm2ywaj4dr")
var panel_round_base 									:= preload("uid://cywnobmluy31i")
var panel_round_base_border_highlight := preload("uid://qbiwr8hnwf5n")
var panel_round_accent 								:= preload("uid://3r3hhcvqp2au")
var panel_round_accent_muted 					:= preload("uid://l18dbl63e366")
var panel_top_round_base 							:= preload("uid://cqnilt2rk14bi")
var panel_top_round_accent 						:= preload("uid://dve2ih1gvvua7")
var panel_top_round_accent_muted 			:= preload("uid://7s65f804p1jc")
var panel_rounded_no_top_base					:= preload("uid://bqxadvxd6q2yj")
var foldable_container_panel					:= preload("uid://bkl7j8mna8rwb")
var content_panel											:= preload("uid://dsitl204qf1y3")

var sb_btn_normal 										:= preload("uid://di36bptu4b3n")
var sb_btn_toggled_on									:= preload("uid://bcprdy8psyd0k")
var sb_btn_apply 											:= preload("uid://bwsfno28una6g")
var sb_btn_apply_highlight						:= preload("uid://cws5raq1oykdn")

var sb_line_edit_normal 							:= preload("uid://pue22dsifmfd")
var sb_line_edit_invalid							:= preload("uid://cdij27b0tovx")

var sb_log_file_button_normal					:= preload("uid://xy4uummjvhgu")

var lv_content_lbl_settings 					:= preload("uid://cqn5x8cb7vjy3")
var lv_popup_panel										:= preload("uid://dugr1wllj4x3")
var gl_logfile_button_lbl_settings		:= preload("uid://c8w51vy1pqjq8")


## Index 3 is a SEPERATOR and should not be used.
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

var category_scene = preload("uid://c3n416c5fajm5") 
var plugin_version: String =  "1.4":
	set(value):
		plugin_version = value
		if plugin_version_sett_lbl != null:
			plugin_version_sett_lbl.text = str("GoLogger v.", value)

var log_header_value: String = "":
	set(value):
		if value != log_header_value:
			log_header_value = value
			log_header_revert_btn.tooltip_text = str("Revert to '", value, "'")
			data.header_format = value
var entry_format_value: String = "":
	set(value):
		if value != entry_format_value:
			entry_format_value = value
			entry_format_revert_btn.tooltip_text = str("Revert to '", value, "'")
			data.entry_format = value 

var _default_setting_in_progress: bool = false  
var id_font_settings_min_size: int = 200
var is_shutting_down: bool = false:
	set(value):
		if is_shutting_down != value:
			is_shutting_down = value
			category_tab.is_shutting_down = value



#region Inits and signals

func _ready() -> void:
	data = load(data_path)
	log_browser_tab.data = data
	category_tab.data = data
	settings_tab.data = data
	data.update_list()

	for i in [renable_btn1, renable_btn2, renable_btn3]:
		if i: i.visible = dev_mode
	theme_colors = _get_theme_colors()

	tab_changed.connect(
		func(tab: int) -> void: 
			match tab:
				1: category_tab.request_update_columns()
				2: 
					log_browser_tab.load_log_browser()
					log_browser_tab._update_columns(true)
	)
	category_tab.request_save.connect(save_data)
	category_tab.request_categories_save.connect(save_categories)
	log_browser_tab.log_file_added.connect(_on_log_file_added)
	settings_tab.request_save.connect(save_data)
	settings_tab.request_theme_colors.connect(func() -> void: theme_colors = _get_theme_colors())


	# Signal connections 
	_connect_unique(settings.settings_changed, _on_editor_settings_changed)
	_connect_unique(open_dir_btn.button_up, _open_directory)
	_connect_unique(log_browser_open_dir_btn.button_up, _open_directory)
	_connect_unique(user_dir_btn.button_up, _open_user_dir)
	_connect_unique(base_dir_opendir_btn.button_up, _open_directory)
	_connect_unique(reset_settings_btn.button_up, reset_to_default)

	initialize_dock()
	_apply_theme_colors()

	await get_tree().process_frame

	_assign_settings_controls()
	category_tab.initialize_tab()
	settings_tab.initialize_tab() 
	log_browser_tab.load_log_browser()



func _exit_tree() -> void: 
	is_shutting_down = true


func _init_visibility() -> void:
	set_current_tab(1)
	help_tab.set_current_tab(0)
	log_browser_tab.set_view(log_browser_tab.BrowserState.FILE_LIST)
	settings_tab.init_visibility()

	var fold_conts: Array[FoldableContainer] = [
		help_setup,
		help_sessions,
		help_categories,
		help_messages,
		help_concurrencies,
		help_log_browser,
		help_functions,
		help_hotkeys,
		help_file_limits,
		help_formatting
	]

	for container in fold_conts:
		container.folded = true



func _connect_unique(signal_obj: Signal, callback: Callable) -> void:
	if signal_obj.is_connected(callback):
		signal_obj.disconnect(callback)
	signal_obj.connect(callback)



## Reassigns all references after they're ready
func _assign_settings_controls() -> void:
	data.base_dir_ctrl = base_dir_line
	data.header_format_ctrl = log_header_line
	data.entry_format_ctrl = entry_format_line
	data.autostart_ctrl = autostart_btn
	data.utc_ctrl = utc_btn
	data.id_print_ctrl = id_print_btn
	data.id_toggle_ctrl = id_toggle_btn
	data.id_startup_ctrl = id_startup_btn
	data.id_align_ctrl = id_align_opt_btn
	data.limit_method_ctrl = limit_method_btn
	data.entry_count_action_ctrl = entry_count_action_btn
	data.session_timer_action_ctrl = session_timer_action_btn
	data.file_cap_ctrl = file_count_spinbox
	data.file_cap_ctrl_line = file_count_spinbox.get_line_edit()
	data.entry_cap_ctrl = entry_count_spinbox
	data.entry_cap_ctrl_line = entry_count_spinbox.get_line_edit()
	data.session_duration_ctrl = session_duration_spinbox
	data.session_duration_ctrl_line = session_duration_spinbox.get_line_edit()
	data.error_rep_ctrl = error_rep_btn
	data.browser_sort_ctrl = log_browser_sort_btn
	data.browser_view_ctrl = log_browser_view_btn

#endregion



#region Public

func initialize_dock() -> void:
	if data == null: data = GLData.new()

	_init_visibility()



func reset_to_default() -> void:
	data.reset_to_default()

	base_dir_apply_btn.disabled = true
	log_header_apply_btn.disabled = true
	entry_format_apply_btn.disabled = true
	entry_format_warning.hide()




## Saves dock state to file. "external_source" is used to debug what func/signal called this from another tab script.
func save_data(ignore_errors: bool = false, external_source: String = "") -> void: 
	if is_shutting_down:
		return
	
	save_categories()
	data.save()
	return 



func save_categories() -> void:
	if is_shutting_down:
		return

	# await get_tree().create_timer(0.01).timeout

	var cats: Array[GLCategoryData] = []

	for log_c in category_container.get_children():
		if log_c is LogCategory:
			if log_c.category_name.is_empty():
				continue

			if log_c.default_checkbox.button_pressed: 
				data.default_category = log_c.category_name

			var c_data: GLCategoryData = GLCategoryData.new()
			c_data.category_name = log_c.category_name
			c_data.file_name = log_c.file_name
			c_data.file_path = log_c.file_path
			c_data.is_locked = log_c.is_locked
			cats.append(c_data)
	
	data.categories = cats
	category_tab.handle_category_mov_button_state()

#endregion



## Opens "user://"
func _open_user_dir() -> void:
	var abs_path = ProjectSettings.globalize_path("user://")
	OS.shell_open(abs_path)



# Opens "user://GoLogger/category_name/"
func _open_directory() -> void:
	var abs_path = ProjectSettings.globalize_path(data.base_dir)
	OS.shell_open(abs_path)

#endregion


#region Signal receivers

func _on_log_file_added(logfile: Button) -> void:
	var theme_colors = _get_theme_colors() 
	logfile.add_theme_color_override("font_color", theme_colors["font"]["normal"])
	logfile.add_theme_color_override("font_hover_color", theme_colors["font"]["hover"])
	logfile.add_theme_color_override("font_pressed_color", theme_colors["font"]["normal"]) 



func _on_editor_settings_changed() -> void:
	settings = EditorInterface.get_editor_settings()
	editor_base_col = settings.get("interface/theme/base_color")
	_apply_theme_colors()



func _get_theme_colors() -> Dictionary:
	var contrast: 	float = settings.get("interface/theme/contrast")
	var base_col: 	Color = settings.get("interface/theme/base_color")
	var accent_col: Color = settings.get("interface/theme/accent_color")

	var base_light 			= base_col.lerp(Color.WHITE, contrast)
	var base_dark 			= base_col.lerp(Color.BLACK, contrast)
	var base_light_h 		= base_col.lerp(Color.WHITE, contrast * 0.5)
	var base_dark_h 		= base_col.lerp(Color.BLACK, contrast * 0.5)

	var accent_light 		= accent_col.lerp(Color.WHITE, contrast)
	var accent_dark 		= accent_col.lerp(Color.BLACK, contrast)
	var accent_light_h 	= accent_col.lerp(Color.WHITE, contrast * 0.5)
	var accent_dark_h 	= accent_col.lerp(Color.BLACK, contrast * 0.5)
	# print("base_col: " base_col, "    setting base col: ", base_col)
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
			"normal": Color("9d9ea0"),
			"hover": Color("ffffff"),
			"interact_normal": base_col,
			"interact_hover": base_light,
			"interact_pressed": base_col,
			"interact_hover_pressed": base_light,
			"fold_normal": Color("b3b3b3"),
			"fold_hover": Color("f2f2f2")
		}
	} 
	category_tab.theme_colors = colors
	settings_tab.theme_colors = colors
	return colors



func _apply_theme_colors():
	theme_colors = _get_theme_colors()
	var color_map := {
		# Transparent elements
		sb_tab_unselected: {"bg_color": Color.TRANSPARENT},
		sb_btn_normal: {"bg_color": Color.TRANSPARENT},
		
		# Base color elements
		panel_round_base: {"bg_color": theme_colors["base"]["col"]},
		panel_round_base_border_highlight: {"bg_color": theme_colors["base"]["col"], "border_color": theme_colors["accent"]["col"]},
		panel_top_round_base: {"bg_color": theme_colors["base"]["col"]},
		panel_rounded_no_top_base: {"border_color": theme_colors["base"]["col"]},
		foldable_container_panel: {"border_color": theme_colors["base"]["col"]},
		sb_tab_bar_bg: {"bg_color": theme_colors["base"]["col"]},
		sb_log_file_button_normal: {"bg_color": theme_colors["base"]["col"]},
		content_panel: {"border_color": theme_colors["base"]["col"]},
		sb_btn_toggled_on: {"bg_color": theme_colors["base"]["col"]},
		
		# Dark base variants
		sb_tab_panel_bg: {"bg_color": theme_colors["base"]["dark"]},
		sb_tab_panel_no_side_margins: {"bg_color": theme_colors["base"]["dark"]},
		panel_round_bg: {"bg_color": theme_colors["base"]["dark"]},
		lv_popup_panel: {"bg_color": theme_colors["base"]["dark"], "border_color": theme_colors["base"]["col"]},
		
		# Dark highlight
		sb_line_edit_normal: {"bg_color": theme_colors["base"]["dark_highlight"]},
		
		# Accent color elements
		panel_round_accent: {"bg_color": theme_colors["accent"]["col"]},
		panel_top_round_accent: {"bg_color": theme_colors["accent"]["col"]},
		sb_btn_toggled_on: {"border_color": theme_colors["accent"]["col"]},
		sb_tab_hover: {"bg_color": theme_colors["accent"]["light"]},
		sb_tab_selected: {"bg_color": theme_colors["accent"]["dark"]},
		
		# Accent muted variants
		panel_round_accent_muted: {"bg_color": theme_colors["accent"]["dark_highlight"]},
		panel_top_round_accent_muted: {"bg_color": theme_colors["accent"]["dark_highlight"]},
		sb_btn_apply: {"bg_color": theme_colors["accent"]["dark_highlight"]},
		
		# Label settings
		lv_content_lbl_settings: {"font_color": theme_colors["font"]["normal"]},
		gl_logfile_button_lbl_settings: {"font_color": theme_colors["font"]["normal"]},
	}
	
	for resource: Resource in color_map:
		var properties: Dictionary = color_map[resource]
		for prop_name: String in properties:
			resource[prop_name] = properties[prop_name]
	

	for line in [base_dir_line, log_header_line, entry_format_line]:
		line.add_theme_color_override("font_color", theme_colors["font"]["normal"])

	for cont in [general_fold_cont, limit_fold_cont, id_fold_cont, id_font_sett_cont, help_setup, help_sessions, help_categories, help_messages, help_concurrencies, help_functions, help_hotkeys, help_file_limits, help_formatting]:
		cont.add_theme_color_override("font_color", 						theme_colors["font"]["normal"] 		if theme_colors["font"]["interact_normal"].v 				< 0.7 else theme_colors["base"]["col"])
		cont.add_theme_color_override("hover_font_color", 			theme_colors["font"]["hover"] 		if theme_colors["font"]["interact_hover"].v 				< 0.7 else theme_colors["base"]["col"])
		cont.add_theme_color_override("collapsed_font_color", 	theme_colors["font"]["fold_normal"] 											if theme_colors["base"]["light_highlight"].v 				< 0.7 else theme_colors["base"]["col"]) 

	for btn in [error_rep_btn, limit_method_btn, entry_count_action_btn,	session_timer_action_btn,	id_align_opt_btn]:
		btn.add_theme_color_override("font_color", 								theme_colors["font"]["normal"] 	if theme_colors["font"]["interact_normal"].v 				< 0.7 else theme_colors["accent"]["col"])
		btn.add_theme_color_override("font_pressed_color", 				theme_colors["font"]["hover"] 	if theme_colors["font"]["interact_hover"].v 				< 0.7 else theme_colors["accent"]["col"])
		btn.add_theme_color_override("font_hover_color", 					Color.WHITE 										if theme_colors["font"]["interact_pressed"].v 			< 0.7 else theme_colors["accent"]["col"])
		btn.add_theme_color_override("font_hover_pressed_color", 	Color.WHITE											if theme_colors["font"]["interact_hover_pressed"].v < 0.7 else theme_colors["accent"]["col"])

#endregion