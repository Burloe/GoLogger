@tool
class_name GLData extends Resource

signal data_ready

@export var categories: Array[GLCategoryData] = []
@export var default_category: String = ""

@export var base_dir: String = "user://gologger/"
@export var header_format: String = "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:"
@export var entry_format: String = "[{hh}:{mi}:{ss}] {instance_id}: {entry}"
@export var autostart: bool = true
@export var utc: bool = false
@export var id_print: bool = false
@export var id_toggle: bool = false
@export var id_startup: bool = false
@export_enum("Top-Left", "Top-Center", "Top-Right", "Center-Left", "Center-Center", "Center-Right", "Bottom-Left", "Bottom-Center", "Bottom-Right") var id_align: int = 0
@export_enum("Entry Count", "Session Timer", "Both", "Separator", "None") var limit_method: int = 0
@export_enum("Overwrite Entries", "Restart Session", "Stop Session") var entry_count_action: int = 0
@export_enum("Restart Session", "Stop Session") var session_timer_action: int = 0
@export var file_cap: int = 10
@export var entry_cap: int = 2000
@export var session_duration: int = 1200
@export_enum("Warnings & Errors", "Warnings only", "None") var error_reporting: int = 0
@export_enum("New", "Old", "Grouped New", "Grouped Old") var browser_sort: int = 0
@export var browser_view: bool = false

var base_dir_ctrl: LineEdit = null
var header_format_ctrl: LineEdit = null
var entry_format_ctrl: LineEdit = null
var autostart_ctrl: CheckBox = null
var utc_ctrl: CheckBox = null
var id_print_ctrl: CheckBox = null
var id_toggle_ctrl: CheckBox = null
var id_startup_ctrl: CheckBox = null
var id_align_ctrl: OptionButton = null
var limit_method_ctrl: OptionButton = null
var entry_count_action_ctrl: OptionButton = null
var session_timer_action_ctrl: OptionButton = null
var file_cap_ctrl: SpinBox = null
var file_cap_ctrl_line: LineEdit = null
var entry_cap_ctrl: SpinBox = null
var entry_cap_ctrl_line: LineEdit = null
var session_duration_ctrl: SpinBox = null
var session_duration_ctrl_line: LineEdit = null
var error_rep_ctrl: OptionButton = null
var browser_sort_ctrl: Button = null
var browser_view_ctrl: Button = null

var list: Dictionary = {}


func _init() -> void:
	changed.connect(update_list)
	update_list()
	data_ready.emit()





func validate_settings() -> bool:
	var faults: int = 0
	
	if id_align not in range(9):
			faults += 1
	if limit_method not in range(5):
			faults += 1
	if entry_count_action not in range(3):
			faults += 1
	if session_timer_action not in range(2):
			faults += 1
	if error_reporting not in range(3):
			faults += 1
	if browser_sort not in range(4):
			faults += 1
	
	# Clamp numeric fields
	if file_cap < 0:
			file_cap = 0
			faults += 1
	if entry_cap < 0:
			entry_cap = 0
			faults += 1
	if session_duration < 1:
			session_duration = 1
			faults += 1
	
	return faults > 0



func save() -> void:
	update_list()
	for key in list.keys():
		var val = list[key]["value"]
		var ctrl = list[key]["ctrl"]
		
		if ctrl == null:
			printerr("GoLogger Error: Null reference in save data list [", key, "]")
			continue
		
		
		if ctrl is Button and ctrl.toggle_mode:
			list[key]["value"] = ctrl.button_pressed
		
		elif ctrl is CheckBox:
			list[key]["value"] = ctrl.button_pressed
		
		elif ctrl is SpinBox:
			list[key]["value"] = ctrl.value
		
		elif ctrl is OptionButton:
			list[key]["value"] = ctrl.selected

		elif ctrl is LineEdit:
			list[key]["value"] = ctrl.text

		

func apply_values() -> void:
	update_list()

	for key in list.keys():
		var ctrl = list[key]["ctrl"] 
		var val = list[key]["value"]

		if ctrl is Button or ctrl is CheckBox:
			ctrl.button_pressed = val
		
		elif ctrl is SpinBox:
			ctrl.value = val 
		
		elif ctrl is OptionButton:
			ctrl.selected = val

		elif ctrl is LineEdit:
			ctrl.text = val



func reset_to_default() -> bool:
	if !validate_settings() or list.is_empty():
		return false

	for key in list.keys():
		var ctrl = list[key]["ctrl"]
		var def = list[key]["default"]

		list[key]["value"] = def
		
		if ctrl == null:
			prints("GoLogger Error: Failed to reset dock element", key, " - Null reference in Dictionary.", list[key])
			continue

		if ctrl is Button and ctrl.toggle_mode:
			ctrl.button_pressed = def
		
		elif ctrl is CheckBox:
			ctrl.button_pressed = def
		
		elif ctrl is SpinBox:
			ctrl.value = def
		
		elif ctrl is OptionButton:
			ctrl.selected = def

		elif ctrl is LineEdit:
			ctrl.text = def

	update_list()
	return true



func get_list() -> Dictionary:
	update_list()
	return list


func update_list() -> void:
	list = {
	"base_dir": 						{"value": base_dir, 						"default": "user://gologger/", 		"ctrl": base_dir_ctrl},
	"header_format": 				{"value": header_format, 				"default": "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:", 		"ctrl": header_format_ctrl},
	"entry_format": 				{"value": entry_format, 				"default": "[{hh}:{mi}:{ss}] {instance_id}: {entry}", 		"ctrl": entry_format_ctrl},
	"autostart": 						{"value": autostart, 						"default": true, 		"ctrl": autostart_ctrl},
	"utc": 									{"value": utc, 									"default": false, 	"ctrl": utc_ctrl},
	"id_print": 						{"value": id_print, 						"default": false, 	"ctrl": id_print_ctrl},
	"id_toggle": 						{"value": id_toggle, 						"default": false, 	"ctrl": id_toggle_ctrl},
	"id_startup": 					{"value": id_startup, 					"default": true, 		"ctrl": id_startup_ctrl},
	"id_align": 						{"value": id_align, 						"default": 0, 			"ctrl": id_align_ctrl},
	"limit_method": 				{"value": limit_method, 				"default": 0, 			"ctrl": limit_method_ctrl},
	"count_action": 				{"value": entry_count_action, 	"default": 0, 			"ctrl": entry_count_action_ctrl},
	"timer_action": 				{"value": session_timer_action, "default": 0, 			"ctrl": session_timer_action_ctrl},
	"file_cap": 						{"value": file_cap, 						"default": 10, 			"ctrl": file_cap_ctrl, "line": file_cap_ctrl_line},
	"entry_cap": 						{"value": entry_cap, 						"default": 2000, 		"ctrl": entry_cap_ctrl, "line": entry_cap_ctrl_line},
	"session_duration": 		{"value": session_duration, 		"default": 1200, 		"ctrl": session_duration_ctrl, "line": session_duration_ctrl_line},
	"err_report_lv":	 			{"value": error_reporting, 			"default": 0, 			"ctrl": error_rep_ctrl},
	"browser_sort": 				{"value": browser_sort, 				"default": 0, 			"ctrl": browser_sort_ctrl},
	"browser_view": 				{"value": browser_view, 				"default": 0, 			"ctrl": browser_view_ctrl},}