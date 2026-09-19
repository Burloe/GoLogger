@tool
class_name GLDock extends EditorDock

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



@export var data: GLData = null
const DATA_PATH: String = "res://addons/gdlogger/data.tres"
@onready var renable_btn1: Button = %RENABLEButton1 
@onready var renable_btn2: Button = %RENABLEButton3
@onready var docktab_container: TabContainer = %DockTabContainer

# Logs tab
@onready var logs_tab: HBoxContainer = %LogsTab
@onready var category_container: GridContainer = %CategoryGridContainer 
@onready var lg_add_cat_btn: Button = %AddCategoryButton
@onready var lg_open_dir_btn: Button = %LBOpenDirButton 
@onready var lg_reload_btn: Button = %LGReloadButton
@onready var lg_sort_btn: Button = %LGSortCheckButton
@onready var lg_colorcode_btn: Button = %LGColorCodeCheckButton
@onready var lg_open_with_os_btn: Button = %LGOpenLogsCheckButton
@onready var lg_auto_reload_btn: CheckButton = %LGAutoReloadCheckButton
@onready var lg_settings_btn: Button = %LogSettingsButton
@onready var lg_settings_popup: PopupPanel = %LogsSettingsPanelPopup
@onready var lg_popup: PopupPanel = %LogFilePanelPopup

# Settings tab
@onready var settings_tab: Control = %SettingsTab
@onready var sett_reset_btn: Button = %ResetSettingsButton
@onready var sett_base_dir_line: LineEdit = %BaseDirLineEdit
@onready var sett_base_dir_lbl: Label = %BaseDirLabel
@onready var sett_base_dir_line_btn_cont: Panel = %BaseDirLineEditButtons
@onready var sett_base_dir_apply_btn: Button = %BaseDirApplyButton
@onready var sett_base_dir_revert_btn: Button = %BaseDirRevertButton
@onready var sett_open_dir_btn: Button = %OpenDirButton
@onready var sett_base_dir_container: HBoxContainer = %BaseDirHBox

@onready var sett_log_header_line: LineEdit = %LogHeaderLineEdit
@onready var sett_log_header_lbl: Label = %LogHeaderLabel
@onready var sett_log_header_line_btn_cont: Panel = %LogHeaderLineEditButtons
@onready var sett_log_header_apply_btn: Button = %LogHeaderApplyButton
@onready var sett_log_header_revert_btn: Button = %LogHeaderRevertButton
@onready var sett_log_header_container: HBoxContainer = %LogHeaderHBox

@onready var sett_entry_format_line: LineEdit = %EntryFormatLineEdit
@onready var sett_entry_format_lbl: Label = %EntryFormatLabel
@onready var sett_entry_format_line_btn_cont: Panel = %EntryFormatLineEditButtons
@onready var sett_entry_format_apply_btn: Button = %EntryFormatApplyButton
@onready var sett_entry_format_revert_btn: Button = %EntryFormatRevertButton
@onready var sett_entry_format_warning: Panel = %EntryFormatWarning
@onready var sett_entry_format_container: HBoxContainer = %EntryFormatHBox

@onready var sett_autostart_btn: CheckButton = %AutostartCheckButton
@onready var sett_utc_btn: CheckButton = %UTCCheckButton

@onready var sett_limit_method_btn: OptionButton = %LimitMethodOptButton
@onready var sett_limit_method_lbl: Label = %LimitMethodLabel
@onready var sett_limit_method_container: HBoxContainer = %LimitMethodHBox

@onready var sett_entry_count_action_btn: OptionButton = %EntryActionOptButton
@onready var sett_entry_count_action_lbl: Label = %EntryActionLabel
@onready var sett_entry_count_action_container: HBoxContainer = %EntryCountActionHBox
var sett_entry_count_spinbox_line: LineEdit
@onready var sett_entry_count_spinbox: SpinBox = %EntryCountSpinBox

@onready var sett_session_timer_action_btn: OptionButton = %SessionTimerActionOptButton
@onready var sett_session_timer_action_lbl: Label = %SessionTimerActionLabel
@onready var sett_session_timer_action_container: HBoxContainer = %SessionTimerActionHBox
var sett_session_duration_spinbox_line: LineEdit
@onready var sett_session_duration_spinbox: SpinBox = %SessionDurationSpinBox

var sett_file_count_spinbox_line: LineEdit
@onready var sett_file_count_spinbox: SpinBox = %FileCountSpinBox
@onready var sett_file_count_lbl: Label = %FileCountLabel
@onready var sett_file_count_container: HBoxContainer = %FileCountHBox

@onready var sett_id_fold_cont: FoldableContainer = %IDFoldableContainer
@onready var sett_id_align_container: HBoxContainer = %IDAlignHBox
@onready var sett_id_align_lbl: Label = %IDAlignLabel
@onready var sett_id_align_opt_btn: OptionButton = %IDAlignOptButton

@onready var sett_id_toggle_btn: CheckButton = %IDToggleShowCheckButton
@onready var sett_id_startup_btn: CheckButton = %IDStartupCheckButton
@onready var sett_id_print_btn: CheckButton = %IDPrintCheckButton 

@onready var sett_id_font_sett_cont: FoldableContainer = %IDFontFoldableContainer
var sett_id_inspector: EditorInspector

@onready var sett_hotkey_container: FoldableContainer = %HotkeyFoldableContainer
var inspector: EditorInspector

@onready var settings_version_lbl: Label = %SettingsVersionLabel

@onready var general_fold_cont: FoldableContainer = %GeneralFoldableContainer
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
@onready var plugin_version_lbl: Label = %PluginVersionLabel
@onready var regenerate_btn: Button = %RegenerateButton

var theme_colors: Dictionary = {}
@onready var settings = EditorInterface.get_editor_settings()
@onready var editor_base_col: Color = settings.get_setting("interface/theme/base_color")
@onready var editor_accent_col: Color = settings.get_setting("interface/theme/accent_color")
@onready var editor_contrast = settings.get_setting("interface/theme/contrast")
@onready var editor_col_settings: Array = [
	settings.get_setting("interface/theme/follow_system_theme"), 
	settings.get_setting("interface(theme/color_preset)"), 
	settings.get_setting("interface/theme/icon_and_font_color"),
	settings.get_setting("interface/theme/base_color"),
	settings.get_setting("interface/theme/accent_color")
]

var gdl_ico = preload("uid://bch3ujgyd4vth")

var sb_path: String = "res://addons/gdlogger/resources/theme/"

var sb_line_edit_normal 							:= preload("uid://pue22dsifmfd")
var sb_line_edit_invalid							:= preload("uid://cdij27b0tovx")

# var sb_log_file_button_normal					:= preload("uid://xy4uummjvhgu")

var lv_content_lbl_settings 					:= preload("uid://cqn5x8cb7vjy3")
# var lv_popup_panel										:= preload("uid://dugr1wllj4x3")


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


var category_scene = preload("uid://c3n416c5fajm5")
var theme_col_base = ProjectSettings.get_setting("interface/theme/base_color")
var theme_col_accent = ProjectSettings.get_setting("interface/theme/accent_color")
var theme_contrast = ProjectSettings.get_setting("interface/theme/contrast")
var plugin_version: String =  "2.0":
	set(value):
		plugin_version = value
		if plugin_version_lbl:
			plugin_version_lbl.text = str("GDLogger v.", value)
		if settings_version_lbl:
			settings_version_lbl.text = str("GDLogger v.", value)

var log_header_value: String = "":
	set(value):
		if value != log_header_value:
			log_header_value = value
			sett_log_header_revert_btn.tooltip_text = str("Revert to '", value, "'")
			data.header_format = value
var entry_format_value: String = "":
	set(value):
		if value != entry_format_value:
			entry_format_value = value
			sett_entry_format_revert_btn.tooltip_text = str("Revert to '", value, "'")
			data.entry_format = value 

var is_shutting_down: bool = false:
	set(value):
		is_shutting_down = value
		if logs_tab != null and _node_has_property(logs_tab, "is_shutting_down"):
			logs_tab.is_shutting_down = value



#region Inits and signals

func _ready() -> void:
	draw.connect(logs_tab._update_columns.bind(true))
	hidden.connect(logs_tab._update_columns)

	data = load(DATA_PATH)
	# docktab_container.set_tab_icon(0, gdl_ico)
	logs_tab.data = data 
	logs_tab.is_active = true
	logs_tab.data = data 
	settings_tab.data = data
	data.update_list()
	theme_colors = _get_theme_colors()

	docktab_container.tab_changed.connect(
		func(tab: int) -> void: 
			if tab == 1: # 0 is empty tab for the plugin icon
				logs_tab.is_active = true
				logs_tab.load_log_files()
				logs_tab._update_columns()
			else:
				logs_tab.is_active = false
	)
	visibility_changed.connect( 
		func() -> void:
			if docktab_container.current_tab == 0 and visible:
				logs_tab.update_columns()

	) 
	logs_tab.request_save.connect(save_data)
	logs_tab.request_categories_save.connect(save_categories)
	settings_tab.request_save.connect(save_data)
	settings_tab.request_theme_colors.connect(func() -> void: theme_colors = _get_theme_colors())


	# # Signal connections 
	_connect_unique(settings.settings_changed, _on_editor_settings_changed) 
	_connect_unique(lg_open_dir_btn.button_up, _open_directory)
	# _connect_unique(user_dir_btn.button_up, _open_user_dir)
	_connect_unique(regenerate_btn.button_up, _on_regenerate_button_up)
	_connect_unique(sett_open_dir_btn.button_up, _open_directory)
	_connect_unique(sett_reset_btn.button_up, reset_to_default)

	initialize_dock()
	_apply_theme_colors()

	await get_tree().process_frame

	_assign_settings_controls()
	logs_tab.initialize_categories()
	settings_tab.initialize_tab() 
	logs_tab.load_log_files(true)
	_assign_editor_icons()



func _exit_tree() -> void: 
	is_shutting_down = true


func _init_visibility() -> void:
	docktab_container.set_current_tab(1)
	help_tab.set_current_tab(0) 
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


func _node_has_property(node: Object, property_name: StringName) -> bool:
	for prop_data in node.get_property_list():
		if prop_data.get("name", "") == property_name:
			return true
	return false



## Reassigns all references after they're ready
func _assign_settings_controls() -> void:
	data.base_dir_ctrl = sett_base_dir_line
	data.header_format_ctrl = sett_log_header_line
	data.entry_format_ctrl = sett_entry_format_line
	data.browser_sort_ctrl = lg_sort_btn 
	data.color_code_ctrl = lg_colorcode_btn
	data.open_logs_with_os_ctrl = lg_open_with_os_btn
	data.auto_reload_ctrl = lg_auto_reload_btn
	data.autostart_ctrl = sett_autostart_btn
	data.utc_ctrl = sett_utc_btn
	data.colorcode_dates_ctrl = lg_colorcode_btn
	data.id_print_ctrl = sett_id_print_btn
	data.id_toggle_ctrl = sett_id_toggle_btn
	data.id_startup_ctrl = sett_id_startup_btn
	data.id_align_ctrl = sett_id_align_opt_btn
	data.limit_method_ctrl = sett_limit_method_btn
	data.entry_count_container = sett_entry_count_action_container
	data.entry_count_action_ctrl = sett_entry_count_action_btn
	data.entry_count_action_lbl = sett_entry_count_action_lbl
	data.session_timer_container = sett_session_timer_action_container
	data.session_timer_action_ctrl = sett_session_timer_action_btn
	data.session_timer_action_lbl = sett_session_timer_action_lbl
	data.file_cap_ctrl = sett_file_count_spinbox
	data.file_cap_ctrl_line = sett_file_count_spinbox.get_line_edit()
	data.entry_cap_ctrl = sett_entry_count_spinbox
	data.entry_cap_ctrl_line = sett_entry_count_spinbox.get_line_edit()
	data.session_duration_ctrl = sett_session_duration_spinbox
	data.session_duration_ctrl_line = sett_session_duration_spinbox.get_line_edit()
	



func _assign_editor_icons() -> void:
	lg_add_cat_btn.set_button_icon(get_theme_icon("Add", "EditorIcons"))

	var _d: Dictionary = {
		"ImportCheck": [sett_base_dir_apply_btn, sett_entry_format_apply_btn, sett_log_header_apply_btn],
		"Reload": [lg_reload_btn, sett_reset_btn],
		"Folder": [lg_open_dir_btn, sett_open_dir_btn],
		"Redo": [sett_base_dir_revert_btn, sett_entry_format_revert_btn, sett_log_header_revert_btn],
		"GDScript": [lg_settings_btn],
		"Debug": [renable_btn1, renable_btn2]
	}

	for icon_name: String in _d.keys():
		for btn: Button in _d[icon_name]:
			btn.set_button_icon(get_theme_icon(icon_name, "EditorIcons")) 

#endregion



#region Public

func initialize_dock() -> void:
	if data == null: 
		if FileAccess.file_exists(DATA_PATH):
			data = load(DATA_PATH)
		else:
			regen_data()
	_init_visibility()



func reset_to_default() -> void:
	sett_base_dir_apply_btn.disabled = true
	sett_log_header_apply_btn.disabled = true
	sett_entry_format_apply_btn.disabled = true
	sett_entry_format_warning.hide()



func regen_data() -> void:
	var new := GLData.new()
	ResourceSaver.save(new, DATA_PATH)
	logs_tab.data = new
	settings_tab.data = new
	for lc in category_container.get_children():
		if lc is GLLogCategory:
			lc.data = new


func check_data_exists() -> bool:
	return FileAccess.file_exists(DATA_PATH)



## Saves dock state to file. "external_source" is used to debug what func/signal called this from another tab script.
func save_data(ignore_errors: bool = false, external_source: String = "") -> void: 
	if is_shutting_down:
		return
	
	save_categories()
	data.save()
	var save_err: int = ResourceSaver.save(data, DATA_PATH)
	if save_err != OK and !ignore_errors:
		push_warning("GDLogger: Failed to save settings resource at '", DATA_PATH, "' [", save_err, "] from ", external_source)
	return 



func save_categories() -> void:
	if is_shutting_down:
		return

	data.categories.clear()
	var cats: Array[GLCategoryData] = []

	for log_c in category_container.get_children():
		if log_c is not GLLogCategory:
			continue

		if log_c.default_btn.button_pressed: 
			data.default_category = log_c.category_name

		var c_data: GLCategoryData = GLCategoryData.new()
		c_data.category_name = log_c.category_name 
		log_c.cat_data = c_data
		cats.append(c_data) 
	
	data.categories = cats
	logs_tab.handle_category_mov_button_state()

#endregion


#region Private

## Opens "user://"
func _open_user_dir() -> void:
	var abs_path = ProjectSettings.globalize_path("user://")
	OS.shell_open(abs_path)



## Opens "user://gdlogger/category_name/"
func _open_directory() -> void:
	var abs_path = ProjectSettings.globalize_path(data.base_dir)
	OS.shell_open(abs_path)

#endregion


#region Signal receivers

func _on_regenerate_button_up() -> void:
	var _new := GLData.new()
	var _err := ResourceSaver.save(_new, DATA_PATH)
	if _err != OK:
		printerr("GDLogger: Failed to regenerate 'data.tres' - Error[", _err, "] ", error_string(_err))
		print("You can manually create a new GLData resource, name it 'data.tres' and save it to path: ", DATA_PATH, "\nRemember to reload Godot afterwards.")



func _on_editor_settings_changed() -> void:
	var col_settings: Array = [
		settings.get_setting("interface/theme/follow_system_theme"), 
		settings.get_setting("interface(theme/color_preset)"), 
		settings.get_setting("interface/theme/icon_and_font_color"),
		settings.get_setting("interface/theme/base_color"),
		settings.get_setting("interface/theme/accent_color")
	]
	var new_base: Color = settings.get_setting("interface/theme/base_color")
	var new_accent: Color = settings.get_setting("interface/theme/accent_color")
	var new_contrast: float = settings.get_setting("interface/theme/contrast")

	# for i in range(col_settings.size()):
	# 	if col_settings[i] != editor_col_settings[i]:
	# 		return

	# var base_changed: bool = theme_col_base != new_base
	# var accent_changed: bool = theme_col_accent != new_accent
	# var contrast_changed: bool = theme_contrast != new_contrast
	# if not base_changed and not accent_changed and not contrast_changed:
	# 	return

	theme_col_base = new_base
	theme_col_accent = new_accent
	theme_contrast = new_contrast
	editor_col_settings = col_settings.duplicate()
	_apply_theme_colors()



func _get_theme_colors() -> Dictionary:
	var contrast: 	float = settings.get_setting("interface/theme/contrast")
	var base_col: 	Color = settings.get_setting("interface/theme/base_color")
	var accent_col: Color = settings.get_setting("interface/theme/accent_color")

	# print("base_col: " base_col, "    setting base col: ", base_col)
	var colors := {
		"bgClr(base-2)": 		base_col.darkened(  contrast * 2),
		"bgClr(base-1)": 		base_col.darkened(  contrast),
		"bgClr(base)":  		base_col,
		"bgClr(base+1)": 		base_col.lightened( contrast),
		"bgClr(base+2)": 		base_col.lightened( contrast * 2),
		"brdClr(base-2)": 	base_col.darkened(  contrast * 2),
		"brdClr(base-1)": 	base_col.darkened(  contrast * 2),
		"brdClr(base)": 		base_col,
		"brdClr(base+1)":	 	base_col.lightened( contrast * 2),
		"brdClr(base+2)": 	base_col.lightened( contrast * 2),
		"bgClr(acc-2)":			accent_col.darkened( contrast * 2),
		"bgClr(acc-1)":			accent_col.darkened( contrast * 2),
		"bgClr(acc)":				accent_col.darkened( contrast * 2),
		"bgClr(acc+1)":			accent_col.lightened(contrast * 2),
		"bgClr(acc+2)":			accent_col.lightened(contrast * 2),
		"brdClr(acc-2)":		accent_col.darkened( contrast * 2),
		"brdClr(acc-1)":		accent_col.darkened( contrast * 2),
		"brdClr(acc)":			accent_col.darkened( contrast * 2),
		"brdClr(acc+1)":		accent_col.lightened(contrast * 2),
		"brdClr(acc+2)":		accent_col.lightened(contrast * 2),
		"brdClr(red)":			Color("c64040"),
		"contrast_value": 	contrast
	}
	return colors



func _apply_theme_colors() -> void:
	# var col_settings: Array = [
	# 	settings.get_setting("interface/theme/follow_system_theme"), 
	# 	settings.get_setting("interface(theme/color_preset)"), 
	# 	settings.get_setting("interface/theme/icon_and_font_color"),
	# 	settings.get_setting("interface/theme/base_color"),
	# 	settings.get_setting("interface/theme/accent_color")
	# ]
	var contrast: 	float = settings.get_setting("interface/theme/contrast")
	var base_col: 	Color = settings.get_setting("interface/theme/base_color")
	var accent_col: Color = settings.get_setting("interface/theme/accent_color")

	var files := DirAccess.get_files_at(sb_path)
	var sb: Array = []
	var tags: Dictionary = {
		"bgClr(base-2)": 		base_col.darkened(   contrast * 2),
		"bgClr(base-1)": 		base_col.darkened(   contrast),
		"bgClr(base)":  		base_col,
		"bgClr(base+1)": 		base_col.lightened(  contrast),
		"bgClr(base+2)": 		base_col.lightened(  contrast * 2),
		"brdClr(base-2)": 	base_col.darkened(   contrast * 2),
		"brdClr(base-1)": 	base_col.darkened(   contrast * 2),
		"brdClr(base)": 		base_col,
		"brdClr(base+1)":	 	base_col.lightened(  contrast * 2),
		"brdClr(base+2)": 	base_col.lightened(  contrast * 2),
		"bgClr(acc-2)":			accent_col.darkened( contrast * 2),
		"bgClr(acc-1)":			accent_col.darkened( contrast * 2),
		"bgClr(acc)":				accent_col,
		"bgClr(acc+1)":			accent_col.lightened(contrast * 2),
		"bgClr(acc+2)":			accent_col.lightened(contrast * 2),
		"brdClr(acc-2)":		accent_col.darkened( contrast * 2),
		"brdClr(acc-1)":		accent_col.darkened( contrast * 2),
		"brdClr(acc)":			accent_col,
		"brdClr(acc+1)":		accent_col.lightened(contrast * 2),
		"brdClr(acc+2)":		accent_col.lightened(contrast * 2),
		"brdClr(red)":			Color("c64040"),
		"contrast_value": 	contrast
	}

	for i in range(files.size()):
		var rsrc := ResourceLoader.load(str(sb_path + files[i]))
		for key in tags.keys():
			if key.begins_with("bgClr") and rsrc is not StyleBoxEmpty and files[i].contains(key):
				rsrc.bg_color = tags[key]
				# print("BGColor Identified: ", rsrc)
			elif key.begins_with("brdClr") and rsrc is not StyleBoxEmpty and files[i].contains(key):
				rsrc.border_color = tags[key]
				print("BorderColor Identified: ", rsrc)
	
	logs_tab.theme_colors = tags
	settings_tab.theme_colors = tags

#endregion