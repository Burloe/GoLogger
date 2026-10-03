@tool
class_name GLDock extends EditorDock

# Adding a new setting:
	# Add the settings to all appropriate dictionaries in "settings_dict"
	# In _ready(), add the settings control node to btn_array so it's included in the uniform signal connections loop
	# If setting requires a Container node to show tooltips(as is the case for most) add the container node to container_array and add the appropriate index in the corresponding_lbls array for the font color changes on mouse hover
	# Implement the logic for applying the setting in signal function like _on_button_button_up()

# TODO:
	# GENERAL:
		# Add EditorInspector for SaveData in MoreInfo panel
	# Bugs: 
		# 
	# DOCK CATEGORY TAB:
		# 
	# DOCK SETTINGS TAB:

signal reload_dock

const THEME_DEBOUNCE_SEC: float = 0.08
const gdl_theme = preload("uid://gjcp57h03j4p")
const gdl_ico_darkmode = preload("uid://vlt2sbet5kyx")
const gdl_ico_lightmode = preload("uid://defy21wg6ksuo")
const gh_ico_darkmode = preload("uid://c74n2f1j4wew5")
const gh_ico_lightmode = preload("uid://c0fie23lxf1be")
const DATA_PATH: String = "res://addons/gdlogger/data.tres"

@export var data: GLData = null
@onready var renable_btn: Button = %RENABLEButton
@onready var docktab_container: TabContainer = %DockTabContainer
@onready var prompt_popup: PanelContainer = %PromptPopupPanelContainer
@onready var delete_category_popup: MarginContainer = %DeleteCategoryPopup
@onready var dock_reload_btn: Button = %ReloadDockButton
@onready var debounce_timer: Timer = %DebounceTimer

# Logs tab
@onready var logs_tab: HBoxContainer = %LogsTab
@onready var category_scroll_container: ScrollContainer = %CategoryScrollContainer
@onready var category_container: GridContainer = %CategoryGridContainer 
@onready var lg_scroll_container: ScrollContainer = %LogFileScrollContainer
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
@onready var l_settings_scroll_container: ScrollContainer = %LSettingsPanel
@onready var r_settings_scroll_container: ScrollContainer = %RSettingsPanel
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
@onready var sett_hotkey_container: FoldableContainer = %HotkeyFoldableContainer

# var sett_id_inspector: EditorInspector
# var inspector: EditorInspector
@onready var data_inspector: EditorInspector = %SaveDataEditorInspector

@onready var version_container: HBoxContainer = %VersionHBoxContainer
@onready var version_linkbtn: LinkButton = %VersionLinkButton

@onready var general_fold_cont: 	FoldableContainer = %GeneralFoldableContainer
@onready var dir_fold_cont: 			FoldableContainer = %DirectoryFoldableContainer

# Help tab
@onready var help_tab: 						TabContainer = 			%HelpTab
@onready var getting_started_tab: ScrollContainer = 	%GettingStarted
@onready var methods_hotkeys_tab: ScrollContainer = 	%Methods
@onready var more_info_tab: 			ScrollContainer = 	%MoreInfo
@onready var help_setup: 					FoldableContainer = %SetupHelp
@onready var help_categories: 		FoldableContainer = %CategoriesHelp
@onready var help_messages: 			FoldableContainer = %MessagesHelp
@onready var help_concurrencies: 	FoldableContainer = %ConcurrenciesHelp
@onready var help_log_browser:		FoldableContainer = %LogBrowserHelp
@onready var help_functions: 			FoldableContainer = %FunctionsHelp
@onready var help_hotkeys: 				FoldableContainer = %HotkeysHelp
@onready var help_file_limits: 		FoldableContainer = %FileLimitsHelp
@onready var help_formatting: 		FoldableContainer = %FormattingHelp
@onready var github_tex_rect: 		TextureRect = 			%GithubTextureRect

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

# var gdl_ico = preload("uid://bch3ujgyd4vth")
var sb_line_edit_normal 							:= preload("uid://pue22dsifmfd")
var sb_line_edit_invalid							:= preload("uid://cdij27b0tovx")
var lv_content_lbl_settings 					:= preload("uid://cqn5x8cb7vjy3")


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


var theme_res_path: String = "res://addons/gdlogger/resources/theme/" # Path to theme resources to edit on EditorSettings changed
var category_scene = preload("uid://c3n416c5fajm5")
var theme_col_base = ProjectSettings.get_setting("interface/theme/base_color")
var theme_col_accent = ProjectSettings.get_setting("interface/theme/accent_color")
var theme_contrast = ProjectSettings.get_setting("interface/theme/contrast") 
var plugin_version: String =  "2.0":
	set(value):
		plugin_version = value
		if version_linkbtn:
			version_linkbtn.text = str("GDLogger v.", value)

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
		logs_tab.is_shutting_down = value



#region Inits and signals

func _ready() -> void:
	if FileAccess.file_exists(DATA_PATH):
		data = load(DATA_PATH)
	else:
		regen_data() 
	
	data_inspector.edit(ResourceLoader.load(DATA_PATH))

	logs_tab.data = data 
	logs_tab.is_active = true
	settings_tab.data = data
	data.update_list()
	theme_colors = _get_theme_colors()

	debounce_timer.wait_time = THEME_DEBOUNCE_SEC
	debounce_timer.timeout.connect(_apply_theme_colors)

	_apply_theme_colors()

	docktab_container.tab_changed.connect(
		func(tab: int) -> void: 
			if tab == 1: # 0 is empty tab for the plugin icon
				logs_tab.is_active = true
				logs_tab.load_log_files()
			else:
				logs_tab.is_active = false
	)
	
	logs_tab.request_save.connect(save_data)
	logs_tab.request_categories_save.connect(save_categories)
	settings_tab.request_save.connect(save_data)
	settings_tab.request_theme_colors.connect(func() -> void: theme_colors = _get_theme_colors())

	# # Signal connections 
	_connect_unique(settings.settings_changed, _on_editor_settings_changed) 
	_connect_unique(lg_open_dir_btn.button_up, _open_directory)
	# _connect_unique(user_dir_btn.button_up, _open_user_dir)
	_connect_unique(sett_open_dir_btn.button_up, _open_directory)
	_connect_unique(sett_reset_btn.button_up, reset_to_default)

	_apply_theme_colors()

	await get_tree().process_frame

	_assign_settings_controls()
	logs_tab.initialize_tab()
	settings_tab.initialize_tab() 
	logs_tab.load_log_files(true)
	_init_visibility()




func _exit_tree() -> void: 
	is_shutting_down = true


func _init_visibility() -> void:
	docktab_container.set_current_tab(1)
	help_tab.set_current_tab(0) 
	settings_tab.init_visibility()

	prompt_popup.hide()
	dock_reload_btn.hide()
	delete_category_popup.hide()
	version_container.show()

	var fold_conts: Array[FoldableContainer] = [
		help_setup,
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
	data.base_dir_ctrl = sett_base_dir_line
	data.header_format_ctrl = sett_log_header_line
	data.entry_format_ctrl = sett_entry_format_line
	data.browser_sort_ctrl = lg_sort_btn 
	data.color_code_ctrl = lg_colorcode_btn
	data.open_logs_enternally_ctrl = lg_open_with_os_btn
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
	
#endregion



#region Public

func reset_to_default() -> void:
	sett_base_dir_apply_btn.disabled = true
	sett_log_header_apply_btn.disabled = true
	sett_entry_format_apply_btn.disabled = true
	sett_entry_format_warning.hide()
	data.reset_to_default()



func regen_data() -> void:
	var new := GLData.new()
	if ResourceSaver.save(new, DATA_PATH) == OK:
		printerr("GDLogger: No plugin data found at path. Successfully generated a new, please reload dock/plugin.")
		prompt_popup.show()
		dock_reload_btn.show()
		delete_category_popup.hide()
	else:
		printerr("GDLogger: No plugin data found at path '", DATA_PATH, "' and GDLogger wasn't able to generate a new one. Please manually R-Click in directory, Create new > Resource > GLData > Name 'data.tres' > Restart Godot.")
	
	logs_tab.data = new
	settings_tab.data = new
	data = new



## Saves dock state to file. "external_source" is used to debug what func/signal called this from another tab script.
func save_data(ignore_errors: bool = false, external_source: String = "") -> void: 
	if is_shutting_down:
		return
	
	save_categories()
	data.update_list()
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
		if log_c is not GLLogCategory or log_c.category_name.is_empty():
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

	# Ignore unrelated editor settings changes and skip no-op reapplies
	if new_base == theme_col_base and new_accent == theme_col_accent and new_contrast == theme_contrast:
		return

	theme_col_base = new_base
	theme_col_accent = new_accent
	theme_contrast = new_contrast
	editor_col_settings = col_settings.duplicate()
	
	if debounce_timer: 
		debounce_timer.start()



func _get_theme_colors() -> Dictionary:
	var contrast: 	float = settings.get_setting("interface/theme/contrast")
	var base_col: 	Color = settings.get_setting("interface/theme/base_color")
	var accent_col: Color = settings.get_setting("interface/theme/accent_color")

	# print("base_col: ", base_col, "    setting base col: ", base_col)
	var colors := {}
	if base_col.get_luminance() <= 0.5: # Dark
		colors = {
			"base_col":											base_col,
			"accent_col":										accent_col,
			# Button
			"normal": 											base_col,
			"pressed": 											base_col.darkened(contrast * 2),
			"hover": 												base_col.lightened(contrast * 2),
			"hover_pressed":								base_col.lightened(contrast),
			
			# LogFile
			"logfile_hover": 								base_col,
			"logfile_hover_border": 				accent_col,
			"logfile_hover_pressed": 				base_col.darkened(contrast * 1.25),
			"logfile_hover_pressed_border":	accent_col.darkened(contrast * 1.25),
			"logfile_pressed":							base_col.darkened(contrast * 1.25),
			"logfile_pressed_border":				accent_col.darkened(contrast * 1.25),

			# FoldableContainer - All base_col
			
			# Scrollbar
			"grabber_highlight":						base_col.lightened(contrast * 2),
			"grabber_pressed":							base_col.darkened(contrast * 2),
			
			# LineEdit
			"line_edit_normal":							base_col.darkened(contrast * 1.25),
			
			# Panel
			"panel_normal":									base_col.darkened(contrast * 2),
			
			# PopupMenu
			"popup_menu_hover":							base_col.lightened(contrast * 2.5),
			"popup_menu_panel":							base_col.darkened(contrast * 2),
			"popup_menu_separator":					base_col.lightened(contrast * 2),
			
			# TabContainer
			"tab_container_panel":					base_col.darkened(contrast * 1.25),
			"tab_container_tab_selected": 	accent_col,
			"tab_container_tab_bar_bg": 		base_col,
			
			# ScrolContainer
			"scroll_container_panel":				base_col.darkened(contrast * 1.25),

			# Separator
			"separator":										base_col.darkened(contrast * 4),
			"colors": {
				"icon_hover":									accent_col,
				"icon_pressed":								accent_col.darkened(contrast * 2),
				"icon_hover_pressed":					accent_col.darkened(contrast * 2),
				"up_icon_hover_modulate": 		accent_col,
				"up_icon_pressed_modulate":		accent_col.darkened(contrast * 2),
				"down_icon_hover_modulate":		accent_col,
				"down_icon_pressed_mdulate":	accent_col.darkened(contrast * 2),
				"font_hovered_color":					Color("1a1a1a"),
				"font_selected_color":				base_col,
				"font_pressed_color":					Color("1a1a1a"),
				"font_hover_pressed_color":		Color("1a1a1a")
			}
		}
	else: # Light
		colors = {
			# Button
			"normal": 											base_col,
			"pressed": 											base_col.lightened(contrast * 2),
			"hover": 												base_col.darkened(contrast * 2),
			"hover_pressed":								base_col.darkened(contrast),
			
			# FoldableContainer - All base_col
			
			# Scrollbar
			"grabber_highlight":						base_col.darkened(contrast * 2),
			"grabber_pressed":							base_col.lightened(contrast * 2),
			
			# LineEdit
			"line_edit_normal":							base_col.lightened(contrast * 2),
			
			# Panel
			"panel_normal":									base_col.lightened(contrast * 2),
			
			# PopupMenu
			"popup_menu_hover":							base_col.darkened(contrast * 2.5),
			"popup_menu_panel":							base_col.lightened(contrast * 2),
			"popup_menu_separator":					base_col.darkened(contrast * 2),
			
			# TabContainer
			"tab_container_panel":					base_col.lightened(contrast * 1.2),
			"tab_container_tab_selected": 	accent_col,
			"tab_container_tab_bar_bg": 		base_col,
			
			# Separator
			"separator":										base_col.lightened(contrast * 4),
			# Colors
			"colors": {
				"icon_pressed":								accent_col,
				"icon_hover":									accent_col.darkened(contrast * 2),
			}
		}
	return colors



func _apply_theme_colors() -> void:
	var tags: Dictionary = _get_theme_colors()

	#TODO Tyoe variations needs to be added? 
	
	gdl_theme.set_block_signals(true)

	for control_type in gdl_theme.get_stylebox_type_list():
		for stylebox_name in gdl_theme.get_stylebox_list(control_type):
			var sb: StyleBox = gdl_theme.get_stylebox(stylebox_name, control_type)
			
			if sb is not StyleBoxFlat and sb is not StyleBoxLine:
				continue

			if sb is StyleBoxFlat:
				sb.bg_color = tags["normal"]
			else:
				sb.color = tags["normal"]

			match control_type:
				"LogFile":
					match stylebox_name:
						"hover": 							
							sb.bg_color = tags["base_col"]
							sb.border_color = tags["accent_col"]
						"hover_pressed":
							sb.bg_color = tags["base_col"]
							sb.border_color = tags["accent_col"]
						
				"LineEdit":
					sb.bg_color = tags["line_edit_normal"]
				"LineEdit_format_fields":
					sb.bg_color = tags["line_edit_normal"]
				"LineEdit_category_field_valid":
					sb.bg_color = tags["line_edit_normal"]
				"LineEdit_category_field_invalid":
					sb.bg_color = tags["line_edit_normal"]
				"HScrollBar", "VScrollBar":
					match stylebox_name:
						"grabber_highlight": 	sb.bg_color = tags[stylebox_name]
						"grabber_pressed": 		sb.bg_color = tags[stylebox_name]
				"Panel":
					sb.bg_color = tags["panel_normal"]
				"Panel_base_col_no_cmarg":
					sb.bg_color = tags["normal"]				
				"PopupMenu":
					match stylebox_name:
						"hover": 							sb.bg_color = tags["popup_menu_hover"]
						"panel": 							sb.bg_color = tags["popup_menu_panel"]
						"separator": 					sb.color 		= tags["popup_menu_separator"]
				"TabContainer":
					match stylebox_name:
						"panel": 							sb.bg_color = tags["tab_container_panel"]
						"tab_selected":				sb.bg_color = tags["tab_container_tab_selected"]
						"tab_bar_background": sb.bg_color = tags["tab_container_tab_bar_bg"]
				"ScrollContainer":
					match stylebox_name:
						"panel": 							sb.bg_color = tags["scroll_container_panel"]
				
				"HSeparator", "VSeparator":
					match stylebox_name:
						"separator": sb.color = tags["separator"]
		
	for control_type in gdl_theme.get_color_type_list():
		for color_name in gdl_theme.get_color_list(control_type):
			for key in tags["colors"].keys():
				if color_name.contains(key):
					gdl_theme.set_color(color_name, control_type, tags["colors"][key])

	gdl_theme.set_block_signals(false)
	gdl_theme.emit_changed()

#endregion