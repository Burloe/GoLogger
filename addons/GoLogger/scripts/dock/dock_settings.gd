@tool
extends HBoxContainer


@onready var base_dir_line: LineEdit = %BaseDirLineEdit
@onready var base_dir_lbl: Label = %BaseDirLabel
@onready var base_dir_line_btn_cont: Panel = %BaseDirLineEditButtons
@onready var base_dir_apply_btn: Button = %BaseDirApplyButton
@onready var base_dir_revert_btn: Button = %BaseDirRevertButton
# @onready var base_dir_opendir_btn: Button = %BaseDirOpenDirButton
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

@onready var user_dir_btn: Button = %UserDirButton 
@onready var general_fold_cont: FoldableContainer = %GeneralFoldableContainer
@onready var limit_fold_cont: FoldableContainer = %LimitersFoldableContainer
@onready var dir_fold_cont: FoldableContainer = %DirectoryFoldableContainer


signal request_save(ignore_errors:bool, source: String) ## Emitted to dock.gd to save the entire dock state to file. "source" is used to specify what action emitted the signal for debugging purposes.
signal request_theme_colors
# signal open_directory


var sb_line_edit_normal 							:= preload("uid://pue22dsifmfd")
var sb_line_edit_invalid							:= preload("uid://cdij27b0tovx")


const PATH = "user://gologger_data.ini"


var config = ConfigFile.new() 
var plugin_version: String =  "1.4":
	set(value):
		plugin_version = value
		if plugin_version_sett_lbl != null:
			plugin_version_sett_lbl.text = str("GoLogger v.", value)

var _default_setting_in_progress: bool = false 
var _is_shutting_down: bool = false
var id_font_settings_min_size: int = 200

var btn_array: Array[Control] = []
var container_array: Array[Control] = [] 

var theme_colors = {}
var settings_dict: Dictionary = {}
var line_edit_states: Dictionary = {
	"base_dir": {"mouse": false, "edit": false},
	"log_header": {"mouse": false, "edit": false},
	"entry_format": {"mouse": false, "edit": false}
}


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



func _ready() -> void:
	if Engine.is_editor_hint(): 
		entry_format_warning.visible = !_is_entry_format_valid(entry_format_line.text)
		inspector = _create_editor_inspector(hotkey_container)
		inspector.edit(ResourceLoader.load("uid://dyi2aml73k4g8"))
		id_inspector = _create_editor_inspector(id_font_sett_cont)
		id_inspector.edit(ResourceLoader.load("uid://dskegm87ypj8f"))
		id_font_sett_cont.folding_changed.connect(_handle_fold_container_min_size.bind(id_font_sett_cont))
		hotkey_container.folding_changed.connect(_handle_fold_container_min_size.bind(hotkey_container))

		_connect_line_edit_toggled()
		_assign_spinbox_line_edits()
		_connect_spinbox_line_submitted()

		btn_array = [
			base_dir_line,
			base_dir_apply_btn,
			base_dir_revert_btn, 
			log_header_line,
			log_header_apply_btn,
			log_header_revert_btn,
			entry_format_line,
			entry_format_apply_btn,
			entry_format_revert_btn,
			autostart_btn,
			utc_btn,
			id_print_btn,
			id_toggle_btn,
			id_align_opt_btn,
			id_startup_btn,
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


		for node in btn_array:
			_connect_control_signal(node)

		var	container_array: Array[HBoxContainer] = [
			base_dir_container,
			log_header_container,
			entry_format_container,
			limit_method_container, 
			file_count_container, 
			error_rep_container,
			id_align_container
		]

		var btns_array: Array[Control] = [
			base_dir_line,
			log_header_line,
			entry_format_line,
			limit_method_btn, 
			file_count_spinbox,
			error_rep_btn,
			id_align_opt_btn
		]

		var corresponding_lbls: Array[Label] = [
			base_dir_lbl,
			log_header_lbl,
			entry_format_lbl,
			limit_method_lbl, 
			file_count_lbl, 
			error_rep_lbl,
			id_align_lbl,
		]

		_bind_settings_hover_groups()
		_handle_limit_method_visibility(config.get_value("settings", "limit_method", settings_dict.get("limit_method", {}).get("default", 0)))




func initialize_tab() -> void:
	for key in settings_dict.keys():
		var _s: Dictionary = settings_dict[key]
		var ctrl = settings_dict[key].get("control")
		var value = config.get_value("settings", _s["name"], _s["default"])

		if ctrl is Button or ctrl is CheckBox:
			ctrl.button_pressed = value
		
		elif ctrl is SpinBox:
			ctrl.value = value 
		
		elif ctrl is OptionButton:
			ctrl.selected = value

		elif ctrl is LineEdit:
			ctrl.text = value
	


func init_visibility() -> void:
	id_startup_btn.show() if config.get_value("settings", "id_toggle", false) else id_startup_btn.hide()
	base_dir_line_btn_cont.hide()
	base_dir_revert_btn.disabled = true
	log_header_line_btn_cont.hide()
	log_header_revert_btn.disabled = true
	entry_format_line_btn_cont.hide()
	entry_format_revert_btn.disabled = true
	
	var fold_conts: Array[FoldableContainer] = [
		general_fold_cont,
		limit_fold_cont,
		id_fold_cont,
		dir_fold_cont,
		hotkey_container
	]

	for container in fold_conts:
		container.folded = true 
	
	dir_fold_cont.folded = false 



func init_settings() -> void:
	for key in settings_dict.keys():
		var _s: Dictionary = settings_dict[key]
		var ctrl = settings_dict[key].get("control")
		var value = config.get_value("settings", _s["name"], _s["default"])

		if ctrl is Button or ctrl is CheckBox or ctrl is CheckButton:
			ctrl.button_pressed = value
		
		elif ctrl is SpinBox:
			ctrl.value = value
		
		elif ctrl is OptionButton:
			ctrl.selected = value

		elif ctrl is LineEdit:
			ctrl.text = value

		init_visibility() 



func _create_editor_inspector(parent: Control) -> EditorInspector:
	var new_inspector := EditorInspector.new()
	parent.add_child(new_inspector)
	new_inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return new_inspector



func _connect_unique(signal_obj: Signal, callback: Callable) -> void:
	if signal_obj.is_connected(callback):
		signal_obj.disconnect(callback)
	signal_obj.connect(callback)



func _connect_line_edit_toggled() -> void:
	base_dir_line.editing_toggled.connect(_on_line_edit_edit_toggled.bind(base_dir_line))
	log_header_line.editing_toggled.connect(_on_line_edit_edit_toggled.bind(log_header_line))
	entry_format_line.editing_toggled.connect(_on_line_edit_edit_toggled.bind(entry_format_line))



func _assign_spinbox_line_edits() -> void:
	file_count_spinbox_line = file_count_spinbox.get_line_edit()
	entry_count_spinbox_line = entry_count_spinbox.get_line_edit()
	session_duration_spinbox_line = session_duration_spinbox.get_line_edit() 



func _connect_spinbox_line_submitted() -> void:
	var line_edits: Array[LineEdit] = [
		file_count_spinbox_line,
		entry_count_spinbox_line,
		session_duration_spinbox_line 
	]

	for line_edit in line_edits:
		_connect_unique(line_edit.text_submitted, _on_spinbox_lineedit_submitted.bind(line_edit))



func _connect_control_signal(node: Control) -> void:
	if node is Button:
		_connect_unique(node.button_up, _on_button_button_up.bind(node))

	if node is CheckBox:
		_connect_unique(node.toggled, _on_checkbox_toggled.bind(node))
	elif node is OptionButton:
		_connect_unique(node.item_selected, _on_optbtn_item_selected.bind(node))
	elif node is LineEdit:
		_connect_unique(node.text_changed, _on_line_edit_text_changed.bind(node))
		_connect_unique(node.text_submitted, _on_line_edit_text_submitted.bind(node))
	elif node is SpinBox:
		_connect_unique(node.value_changed, _on_spinbox_value_changed.bind(node)) 




func _bind_settings_hover_groups() -> void:
	var _groups = [
		[
			base_dir_container,
			base_dir_line,
			base_dir_lbl
		],
		[
			log_header_container,
			log_header_line,
			log_header_lbl
		],
		[
			entry_format_container,
			entry_format_line,
			entry_format_lbl
		],
		[
			error_rep_container,
			error_rep_btn,
			error_rep_lbl
		],
		[
			file_count_container,
			file_count_spinbox,
			file_count_lbl
		],
		[
			limit_method_container,
			limit_method_btn,
			limit_method_lbl
		],
		[
			entry_count_action_container, 
			entry_count_action_btn, 
			entry_count_spinbox,
			entry_count_action_lbl
		],
		[
			session_timer_action_container, 
			session_timer_action_btn, 
			session_duration_spinbox,
			session_timer_action_lbl
		],
		[
			id_align_container,
			id_align_opt_btn,
			id_align_lbl
		]
	]

	for group in _groups:
		for ctrl in group:
			if ctrl is Label: continue

			_connect_unique(ctrl.mouse_entered, _on_setting_hover.bind(group, true))
			_connect_unique(ctrl.mouse_exited, _on_setting_hover.bind(group, false))



func _assign_settings_controls() -> void:
	var control_map := {
		"base_directory": base_dir_line,
		"log_header_format": log_header_line,
		"entry_format": entry_format_line,
		"autostart_session": autostart_btn,
		"use_utc": utc_btn,
		"id_print": id_print_btn,
		"id_toggle": id_toggle_btn,
		"id_startup_state": id_startup_btn,
		"id_align": id_align_opt_btn, 
		"limit_method": limit_method_btn,
		"entry_count_action": entry_count_action_btn,
		"session_timer_action": session_timer_action_btn,
		"file_cap": file_count_spinbox,
		"entry_cap": entry_count_spinbox,
		"session_duration": session_duration_spinbox,
		"error_reporting": error_rep_btn,
	}

	for key in control_map.keys():
		if settings_dict.has(key):
			settings_dict[key]["control"] = control_map[key]






#region Local Functions

func _apply_new_base_directory() -> bool:
	config.load(PATH)
	var old_dir = config.get_value("settings", "base_directory")
	var new_dir = base_dir_line.text.strip_edges()
 
	if new_dir == "":
		if config.get_value("settings", "error_reporting") != 2:
			push_warning("GoLogger: Base directory cannot be empty. Reverting to previous path[", old_dir, "].")
		base_dir_line.text = old_dir
		return false


	if not new_dir.ends_with("/"):
		new_dir += "/"


	var d = DirAccess.open(new_dir) 
	if d == null or DirAccess.get_open_error() != OK:
		var res : int = OK

		var create_path = new_dir
		if new_dir.begins_with("user://") or new_dir.begins_with("res://"):
			create_path = ProjectSettings.globalize_path(new_dir)

		res = DirAccess.make_dir_absolute(create_path)
		if res != OK:
			if config.get_value("settings", "error_reporting") != 2:
				push_warning("GoLogger: Failed to create directory using path[", new_dir, "]. Reverting back to previous directory path[", old_dir, "].")
			base_dir_line.text = old_dir 
			return false

		d = DirAccess.open(new_dir)

	config.set_value("settings", "base_directory", new_dir)
	
	var save_err = config.save(PATH)
	if save_err != OK:
		if config.get_value("settings", "error_reporting") != 2:
			push_warning("GoLogger: Failed to save settings.ini after changing base_directory. Reverting back to previous directory path[", old_dir, "].")
		base_dir_line.text = old_dir 
		return false

	base_dir_line.text = new_dir
	base_dir_revert_btn.tooltip_text = str("Revert to '", new_dir, "'")
 
	return true



func _handle_limit_method_visibility(method: int) -> void:
	var show_entry_limits := method == LimitMethod.ENTRY_COUNT or method == LimitMethod.BOTH
	var show_time_limits := method == LimitMethod.SESSION_TIMER or method == LimitMethod.BOTH

	entry_count_action_container.visible = show_entry_limits 
	session_timer_action_container.visible = show_time_limits 

	entry_count_action_lbl.text = "Entry Action" if method == LimitMethod.BOTH else "Action"
	session_timer_action_lbl.text = "Timer Action" if method == LimitMethod.BOTH else "Action"



func _handle_fold_container_min_size(is_folded: bool, fold_container: FoldableContainer) -> void:
	match fold_container:
		id_font_sett_cont:
			id_fold_cont.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if is_folded else Control.SIZE_EXPAND_FILL
			id_font_sett_cont.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if is_folded else Control.SIZE_EXPAND_FILL 
			id_font_sett_cont.custom_minimum_size.y = id_font_settings_min_size if !is_folded else 0
		hotkey_container:
			id_fold_cont.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if is_folded else Control.SIZE_EXPAND_FILL
			hotkey_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if is_folded else Control.SIZE_EXPAND_FILL 
			hotkey_container.custom_minimum_size.y = id_font_settings_min_size if !is_folded else 0

#endregion







#region Helpers

## Returns true if {entry} tag is present or is NOT empty.
func _is_entry_format_valid(format: String) -> bool:
	if format.is_empty(): return false
	return format.contains("{entry}")

#endregion








#region Signal receivers

func _on_setting_hover(group: Array, is_hovered: bool) -> void:
	request_theme_colors.emit()
	var c_norm:  Color = theme_colors["font"]["normal"] 
	var c_hover: Color = theme_colors["font"]["hover"] 

	for ctrl in group:
		if ctrl is HBoxContainer:
			continue

		if ctrl is LineEdit:
			var key: String = ""
			match ctrl:
				base_dir_line: key = "base_dir"
				log_header_line: key = "log_header"
				entry_format_line: key = "entry_format"

			line_edit_states[key]["mouse"] = is_hovered
			if not line_edit_states[key]["edit"]:
				ctrl.add_theme_color_override("font_color", c_hover if is_hovered else c_norm)

		if ctrl is OptionButton:
			ctrl.add_theme_color_override("font_color", c_hover if is_hovered else c_norm)
			continue

		if ctrl is SpinBox:
			ctrl.get_line_edit().add_theme_color_override("font_color", c_hover if is_hovered else c_norm)
			continue
		
		if ctrl is Label:
			ctrl.add_theme_color_override("font_color", c_hover if is_hovered else c_norm)



func _on_button_button_up(node: Button) -> void:
	config.load(PATH)

	match node:
		base_dir_apply_btn:
			_apply_new_base_directory()
			base_dir_apply_btn.hide()
			base_dir_line_btn_cont.hide()
			request_save.emit(false, "Base Directory Apply Button Button Up")
		
		base_dir_revert_btn:
			base_dir_line.text = config.get_value("settings", "base_directory", settings_dict.get("base_directory", {}).get("default", ""))
			base_dir_apply_btn.disabled = true
			base_dir_revert_btn.disabled = true
			base_dir_line_btn_cont.hide()
			request_save.emit(false, "Base Directory Revert Button Button Up")

		log_header_apply_btn:
			config.set_value("settings", "log_header_format", log_header_line.text) 
			log_header_apply_btn.disabled = true
			log_header_line.release_focus() 
			log_header_line_btn_cont.hide()
			request_save.emit(false, "Log Header Apply Button Button Up")
		
		log_header_revert_btn:
			log_header_line.text = config.get_value("settings", "log_header_format")
			log_header_apply_btn.disabled = true
			log_header_revert_btn.disabled = true
			log_header_line_btn_cont.hide()
			request_save.emit(false, "Log Header Revert Button Button Up")

		entry_format_apply_btn:
			config.set_value("settings", "entry_format", entry_format_line.text)
			var err := config.save(PATH) 
			entry_format_apply_btn.disabled = true
			entry_format_line.release_focus() 
			entry_format_line_btn_cont.hide()
			request_save.emit(false, "Entry Format Apply Button Button Up")

		entry_format_revert_btn:
			entry_format_line.text = config.get_value("settings", "entry_format")
			entry_format_apply_btn.disabled = true
			entry_format_revert_btn.disabled = true
			entry_format_line_btn_cont.hide()
			request_save.emit(false, "Entry Format Revert Button Button Up")




func _on_line_edit_text_changed(new_text: String, node: LineEdit) -> void:
	config.load(PATH)
	var last_applied_value: String = ""
	match node:
		base_dir_line:
			base_dir_apply_btn.disabled = true 
			base_dir_revert_btn.disabled = true 

			if new_text != config.get_value("settings", "base_directory"):
				base_dir_apply_btn.disabled = false 
				base_dir_revert_btn.disabled = false
			# request_save.emit(false, "Base Directory LineEdit Text Changed")

		log_header_line:
			last_applied_value = config.get_value("settings", "log_header_format")
			log_header_apply_btn.disabled = true 
			log_header_revert_btn.disabled = true
			if new_text != last_applied_value:
				log_header_revert_btn.disabled = false
				log_header_apply_btn.disabled = false
			# request_save.emit(false, "Log Header LineEdit Text Changed")

		entry_format_line: 
			last_applied_value = config.get_value("settings", "entry_format")
			entry_format_apply_btn.disabled = true
			entry_format_revert_btn.disabled = true 
			
			entry_format_warning.visible = !_is_entry_format_valid(new_text)
			entry_format_line.add_theme_stylebox_override(
				"normal", 
				sb_line_edit_normal if _is_entry_format_valid(new_text) else sb_line_edit_invalid
			)

			if new_text != last_applied_value and _is_entry_format_valid(new_text):
				entry_format_apply_btn.disabled = false 
				entry_format_revert_btn.disabled = false
			# request_save.emit(false, "Entry Format LineEdit Text Changed")
			


func _on_line_edit_text_submitted(new_text: String, node: LineEdit) -> void: 
	config.load(PATH)
	match node:
		base_dir_line:
			var v = config.get_value("settings", "base_directory", settings_dict.get("base_directory", {}).get("default", ""))

			if _apply_new_base_directory():
				base_dir_line.release_focus()
				base_dir_apply_btn.disabled = true
				base_dir_revert_btn.disabled = true
			request_save.emit(false, "Base Directory LineEdit Text Submitted")

		log_header_line:
			log_header_line.release_focus()
			log_header_apply_btn.disabled = true
			log_header_revert_btn.disabled = true
			request_save.emit(false, "Log Header LineEdit Text Submitted")

		entry_format_line:
			entry_format_line.release_focus()
			entry_format_apply_btn.disabled = true
			entry_format_revert_btn.disabled = true
			request_save.emit(false, "Entry Format LineEdit Text Submitted")



func _on_optbtn_item_selected(index: int, node: OptionButton) -> void:
	match node:
		limit_method_btn:
			config.set_value("settings", "limit_method", index)
			entry_count_action_container.hide() 
			session_timer_action_container.hide() 
			entry_count_action_lbl.text = "Action"
			session_timer_action_lbl.text = "Action"
			
			match index:
				LimitMethod.ENTRY_COUNT:
					entry_count_action_container.show() 
				LimitMethod.SESSION_TIMER: 
					session_timer_action_container.show() 
				LimitMethod.BOTH:
					entry_count_action_container.show()
					session_timer_action_container.show() 
					entry_count_action_lbl.text = "Entry Action"
					session_timer_action_lbl.text = "Timer Action"
			request_save.emit(false, "Limit Method OptionButton Item Selected")

		entry_count_action_btn:
			config.set_value("settings", "entry_count_action", index)
			request_save.emit(false, "Entry Count OptionButton Item Selected")

		session_timer_action_btn:
			config.set_value("settings", "session_timer_action", index)
			request_save.emit(false, "Session Timer OptionButton Item Selected")

		error_rep_btn:
			config.set_value("settings", "error_reporting", index)
			request_save.emit(false, "Error Report OptionButton Item Selected")

		id_align_opt_btn:
			config.set_value("settings", "id_align", index)
			request_save.emit(false, "ID Align OptionButton Item Selected")



func _on_checkbox_toggled(toggled_on: bool, node: CheckBox) -> void:
	match node:
		autostart_btn:
			config.set_value("settings", "autostart_session", toggled_on) 
			request_save.emit(false, "Autostart Checkbox Toggled")

		utc_btn:
			config.set_value("settings", "use_utc", toggled_on) 
			request_save.emit(false, "UTC Checkbox Toggled")

		id_print_btn:
			config.set_value("settings", "id_print", toggled_on)
			request_save.emit(false, "ID Print Checkbox Toggled")

		id_toggle_btn:
			config.set_value("settings", "id_toggle", toggled_on)
			id_startup_btn.show() if toggled_on else id_startup_btn.hide()
			request_save.emit(false, "ID Toggle Checkbox Toggled")

		id_startup_btn:
			config.set_value("settings", "id_startup_state", toggled_on)
			request_save.emit(false, "ID Startup Checkbox Toggled")



func _on_line_edit_edit_toggled(toggled_on: bool, node: LineEdit) -> void:
	request_theme_colors.emit()
	var c_norm:  Color = theme_colors["font"]["normal"] 
	var c_hover: Color = theme_colors["font"]["hover"] 
	var key: String
	
	match node:
		base_dir_line: 
			base_dir_line_btn_cont.visible = toggled_on
			key = "base_dir"
		log_header_line: 
			log_header_line_btn_cont.visible = toggled_on
			key = "log_header"
		entry_format_line: 
			entry_format_line_btn_cont.visible = toggled_on
			key = "entry_format"
	
	line_edit_states[key]["edit"] = toggled_on
	if not line_edit_states[key]["mouse"]:
		node.add_theme_color_override("font_color", c_hover if toggled_on else c_norm) 



func _on_spinbox_lineedit_submitted(new_text: String, node: Control) -> void:
	config.load(PATH)
	match node:

		file_count_spinbox_line:
			var value = int(new_text)
			config.set_value("settings", "file_cap", value)
			file_count_spinbox_line.release_focus()
			file_count_spinbox.release_focus() 
			request_save.emit(false, "File Count SpinBox LineEdit Text Submitted")

		entry_count_spinbox_line:
			var value = int(new_text)
			config.set_value("settings", "entry_cap", value)
			entry_count_spinbox.release_focus()
			entry_count_spinbox_line.release_focus() 
			request_save.emit(false, "Entry Count Spinbox LineEdit Text Submitted")

		session_duration_spinbox_line:
			var value = float(new_text)
			config.set_value("settings", "session_duration", value)
			session_duration_spinbox.release_focus()
			session_duration_spinbox_line.release_focus() 
			request_save.emit(false, "Session Duration Spinbox LineEdit Text Submitted")



func _on_spinbox_value_changed(value: float, node: SpinBox) -> void:
	config.load(PATH)

	var u_line = node.get_line_edit()
	u_line.set_caret_column(u_line.text.length())
	if u_line.get_caret_column() == u_line.text.length() - 1:
		u_line.set_caret_column(u_line.text.length())
	else: u_line.set_caret_column(u_line.get_caret_column() + 1)

	match node:
		file_count_spinbox:
			config.set_value("settings", "file_cap", int(value)) 
			request_save.emit(false, "File Count Spinbox Value Changed")
			
		entry_count_spinbox:
			config.set_value("settings", "entry_cap", int(value)) 
			request_save.emit(false, "Entry Count Spinbox Value Changed")

		session_duration_spinbox:
			config.set_value("settings", "session_duration", int(value)) 
			request_save.emit(false, "Session Duration Spinbox Value Changed")

#endregion










