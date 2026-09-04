@tool
extends HBoxContainer

signal log_file_added(log_file: Button) ## Emitted to Dock to update font colors

@onready var category_panel: HBoxContainer = %CategoryPanel
@onready var polling_timer: Timer = %PollingTimer
@onready var popup: PopupPanel = %LogFilePanelPopup

@onready var open_w_os_btn: Button = %LBOpenWOSButton
@onready var sort_mode_btn: Button = %LBSortModeButton

@onready var margin_container: MarginContainer = %LBMarginContainer
@onready var category_grid_container = %LBCategoryGridContainer 
@onready var reload_btn: Button = %LBReloadButton 
@onready var current_cat_lbl: Label = %CurrentCategoryLabel


@export var data: GLData = null
var inspector: EditorInspector

const GRID_SEPARATION = 8
const GRID_GROUP_SORT_SEPARATION = 24
var log_file_btn := preload("uid://bq7nahsc5aca7")
var cont_lbl_sett = preload("uid://cqn5x8cb7vjy3")
var ico_sort_date_new = preload("uid://b1fn0coq48ktv")
var ico_sort_date_old = preload("uid://cifx5d8dmjt38")
var ico_sort_new = preload("uid://dvjgbc6hibv5m")
var ico_sort_old = preload("uid://bljitewxdnvuh") 

var is_active: bool = false
var grid_conts: Array[GridContainer] = []
var is_content_hovered: bool = false
var is_reloading: bool = false
var hovered_logfile: GLLogFile

var open_log_with_os: bool = false:
	set(value):
		open_log_with_os = value
		open_w_os_btn.icon = get_theme_icon("GuiChecked" if value else "GuiUnchecked", "EditorIcons")
		open_w_os_btn.tooltip_text = "Open logs using OS" if value else "Open logs within Editor"
		data.open_logs_with_os = value

var min_cell_width: int = 140
var base_dir = ""
var categories: Array = [] # [["game", gameGridContainer], ["player", playerGridContainer]]
var cat_containers: Array[GridContainer] = []
var log_files: Array[GLLogFile] = []
var current_category: String = "":
	set(value):
		current_category = value
		current_cat_lbl.text = value.capitalize()
var cur_logfile: GLLogFile = null:
	set(value):
		cur_logfile = value 
var cur_sort: SortModes = SortModes.NEW: 
	set(value):
		cur_sort = value
		var modes := ["\nNew first", "\nOld first", "\nGroup by date - New first", "\nGroup by date - Old first"]
		sort_mode_btn.tooltip_text = str("Sorting by:", modes[value])
		var icons := [ico_sort_new, ico_sort_old, ico_sort_date_new, ico_sort_date_old]
		sort_mode_btn.icon = icons[value]
		data.browser_sort = value

var theme_colors: Dictionary = {}

var state: BrowserState = BrowserState.FILE_LIST
enum BrowserState {
	LOG_FULL,
	LOG_SPLIT,
	FILE_LIST, 
}

enum SortModes {
	NEW,
	OLD,
	GROUP_NEW,
	GROUP_OLD
}




func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
		if state != BrowserState.FILE_LIST and is_content_hovered:
			_close_log_file()
	
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		_close_log_file()



func _ready() -> void: 
	reload_btn.button_up.connect(load_log_files)
	polling_timer.timeout.connect(load_log_files)
	open_w_os_btn.button_up.connect(func() -> void: open_log_with_os = !open_log_with_os)
	sort_mode_btn.button_up.connect(
		func() -> void:
			cur_sort = (cur_sort + 1) % 4
			load_log_files()
	)
	category_panel.category_created.connect(
		func(cat: GLLogCategory) -> void: 
			cat.select_btn.button_up.connect(
				func() -> void:
					current_category = cat.category_name
			)
	)
	resized.connect(_update_columns)
	
	inspector = EditorInspector.new()
	inspector.edit(ResourceLoader.load("uid://cqn5x8cb7vjy3"))
	inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL 
	open_log_with_os = open_log_with_os # loads the icon



## Used to both initialize and reload the file list
func load_log_files() -> void:
	if not is_active: 
		return 

	_close_log_file()
	is_reloading = true

	if data != null:
		base_dir = data.base_dir
	log_files.clear()

	if base_dir == "":
		printerr("[GoLogger] Failed to load Base Directory!") 

	#Collect > hide > deelete old files
	var old := []
	for cat in category_grid_container.get_children():
		var c = []
		for log in cat.get_children():
			c.append(log)
		old.append(cat)
		cat.hide()

	categories.clear()
	grid_conts.clear()

	# Add fallback
	if current_category == "" or data.categories.is_empty() or data.categories[0] != null:
		for cat in data.categories:
			if cat.category_name == data.default_category:
				current_category = cat.category_name
				break
		
		if current_category == "":
			current_category = data.categories[0].category_name

	for child in category_grid_container.get_children():
		category_grid_container.remove_child(child)
		child.queue_free()

	for c: GLCategoryData in data.categories:
		if c.category_name == "" or c.category_name != current_category:
				continue 

		var n: Array = [c.category_name]
		categories.append(n)
		_load_logfiles(c.category_name)
	
	_update_columns(true) 
	is_reloading = false



func _load_logfiles(category_name: String) -> void:
	var actionable_list: PackedStringArray = []
	var grouped_list: Dictionary = {}
	var stray_file_list: PackedStringArray = []
	var fin_list: Array = _sort_file_list(category_name)

	if cur_sort in [SortModes.GROUP_OLD, SortModes.GROUP_NEW]:
		for group in fin_list: 
			_add_logfiles_to_container(group, category_name)
	else:
		_add_logfiles_to_container(fin_list, category_name)



func _add_logfiles_to_container(list: Array, category_name: String) -> void:
	var gc : GridContainer
	var is_grouped: bool = cur_sort in [SortModes.GROUP_OLD, SortModes.GROUP_NEW]
	if is_grouped:
		gc = GridContainer.new()
		gc.add_theme_constant_override("h_separation", GRID_SEPARATION)
		gc.add_theme_constant_override("v_separation", GRID_SEPARATION)
		if is_grouped: gc.columns = 3
		category_grid_container.add_child(gc)
		gc.size_flags_horizontal = Control.SIZE_FILL
		gc.size_flags_vertical = Control.SIZE_FILL
	
	for file in list:
		if typeof(file) != TYPE_STRING:
			continue

		var lf: GLLogFile = _create_logfile_obj(category_name, file)

		if lf == null:
			continue

		if is_grouped:
			gc.add_child(lf)
		else:
			category_grid_container.add_child(lf)
		log_files.append(lf)
		lf.button_up.connect(_open_log_file.bind(lf))
		log_file_added.emit(lf)



func _create_logfile_obj(category_name: String, file_name: String) -> GLLogFile:
	var file_path: String = str(base_dir.path_join(str(category_name, "_logs")).path_join(file_name), "/")
	
	if not FileAccess.file_exists(file_path):
			return

	var f = FileAccess.open(file_path, FileAccess.READ)
	var content = f.get_file_as_string(file_path)
		
	var lf: GLLogFile = log_file_btn.instantiate() as GLLogFile
	lf.category_name = category_name
	lf.file_name = file_name
	lf.file_path = file_path
	lf.file_contents = f.get_file_as_string(file_path)
	lf.assign_icon(true)
	lf.mouse_entered.connect(func() -> void: hovered_logfile = lf)
	lf.mouse_entered.connect(func() -> void: hovered_logfile = null)
	if hovered_logfile != null and hovered_logfile.file_name == file_name and hovered_logfile.category_name == category_name:
		lf.mouse_entered.emit()

	if !lf.is_file_valid() or f.get_open_error() != OK:
		lf.assign_icon(false)

	f.close()
	return lf



func _sort_file_list(category_name: String) -> Array:
	var file_list: PackedStringArray = _get_category_files(category_name) 
	var fin_list: Array = []
	if cur_sort in [SortModes.GROUP_OLD, SortModes.GROUP_NEW]:
		var grouped_list: Dictionary = {}
		var stray_files: PackedStringArray = []
		for file in file_list:
			if !file.ends_with(".log"):
				continue

			if file.is_empty() or !file.begins_with(category_name):
				stray_files.append(file)

			var start := file.find("(") + 1
			var end := file.find("_")
			if start == 0 or end == -1:
				continue

			var file_date = file.substr(start, end - start)

			if !grouped_list.has(file_date):
				grouped_list[file_date] = []
			grouped_list[file_date].append(file)
		
		for date in grouped_list.keys():
			fin_list.append(grouped_list[date])

		if cur_sort == SortModes.GROUP_NEW:
			for group in fin_list:
				group.reverse()
			fin_list.reverse()
		
		if !stray_files.is_empty():
			fin_list.append(stray_files)
	
	if cur_sort in [SortModes.NEW, SortModes.OLD]:
		var stray_files: PackedStringArray = []
		for file in file_list:
			if !file.ends_with(".log") or file.is_empty():
				continue

			if file.begins_with(category_name):
				fin_list.append(file)
			else:
				stray_files.append(file)

		if cur_sort == SortModes.NEW:
			fin_list.reverse()
	
		if !stray_files.is_empty():
			for file in stray_files:
				fin_list.append(file)

	return fin_list



func _get_category_files(category_name: String) -> PackedStringArray:
	if categories.is_empty():
		return []	
	if base_dir == "":
		return []

	var c_path: String = str(base_dir.path_join(category_name), "_logs/")

	var d := DirAccess.open(c_path)
	if d != null:
		return d.get_files()

	return []



func _open_log_file(log_file: GLLogFile) -> void:
	if !log_file.file_name.ends_with(".log"):
		return
	
	if open_log_with_os:
		var abs_path = ProjectSettings.globalize_path(log_file.file_path)
		OS.shell_open(abs_path)
		return

	var log_content: String = log_file.file_contents

	popup.contents = log_file.file_contents
	popup.show()
	
	if log_file.is_gl_name(log_file.file_name):
		var _timestamp: String = log_file.file_name.lstrip(str(log_file.category_name, "(")).rstrip(").log")
		var _splits: Array = _timestamp.split("_") 
		var _m: Array[String] = [
			"N/A",
			" Jan ",
			" Feb ",
			" March ",
			" April ",
			" May ",
			" June ",
			" July ",
			" Aug ",
			" Sep ",
			" Oct ",
			" Nov ",
			" Dec "
		]

		var fin_time: String = str(
			_splits[1].substr(0, 2), ":", 
			_splits[1].substr(2, 2), ":", 
			_splits[1].substr(4, 2)	
		)
		
		var fin_date: String = str(
			_splits[0].substr(4, 2),
			_m[int(_splits[0].substr(2, 2))],
			str(20, (_splits[0].substr(0, 2)))
		)
	for lf: GLLogFile in log_files:
		if lf != log_file and lf.selected:
			lf.selected = false 
	
	log_file.selected = true 
	# title_lbl.text = str("  ", log_file.file_name)
	# contents_lbl.text = log_content if !log_content.is_empty() else "< File is empty or failed to load properly >"
	cur_logfile = log_file
	


func _close_log_file() -> void:
	if cur_logfile:
		cur_logfile.selected = false
		cur_logfile = null
		popup.hide()



func _update_columns(is_initializing: bool = false) -> void:
	if min_cell_width <= 0 or !category_grid_container: 
		return

	if cur_sort in [SortModes.GROUP_NEW, SortModes.GROUP_OLD]:
		category_grid_container.columns = max(category_grid_container.get_child_count(), 1)
		return
	
	await get_tree().physics_frame
	await get_tree().physics_frame 

	var cell_width: int = log_files[0].size.x + category_grid_container.get_theme_constant("h_separation")\
		if !log_files.is_empty() else 1
	var col: int = max(1, int(category_grid_container.size.x / cell_width))
	
	category_grid_container.columns = col 