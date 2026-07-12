@tool
extends HBoxContainer

signal log_file_added(log_file: Button) ## Emitted to Dock to update font colors

@onready var reload_hider: MarginContainer = %ReloadTopper
@onready var fb_margin_container: MarginContainer = %FBMarginContainer
@onready var lv_margin_container: MarginContainer = %LVMarginContainer
@onready var category_tab_container = %LBCategoryTabContainer
@onready var log_viewer: Panel = %LogViewer
@onready var h_split_cont: HSplitContainer = %HSplitContainer
@onready var lv_title_lbl: Label = %ViewerTitleLabel
@onready var lv_refresh_btn: Button = %ViewerRefreshButton
@onready var lv_view_mode_btn: Button = %ViewModeButton
@onready var lv_sort_mode_btn: Button = %SortModeButton
@onready var lv_close_btn: Button = %ViewerCloseButton
@onready var lv_copy_content_btn: Button =%ViewerCopyContentButton
@onready var lv_contents_lbl: Label = %ContentLabel

@onready var lv_panel: Panel = %LVPanel
@onready var lv_scroll_container: ScrollContainer = %LVScrollContainer

@onready var lv_lbl_sett_btn: Button = %ViewerLblSettButton
@onready var lv_lbl_sett_popup: PanelContainer = %LblSettInspectorPopup
@onready var lv_lbl_sett_popup_scroll_cont: ScrollContainer = %LblSettPopupScrollContainer

@export var data: GLData = null
var inspector: EditorInspector

const GRID_SEPARATION = 8
const GRID_GROUP_SORT_SEPARATION = 24

var ico_fullscreen_view := preload("uid://ijiplwclq5pu")
var ico_splitscreen_view := preload("uid://cp2p55wdq2wuk")
var log_file_btn := preload("uid://bq7nahsc5aca7")
var cont_lbl_sett = preload("uid://cqn5x8cb7vjy3")
var ico_sort_date_new = preload("uid://b1fn0coq48ktv")
var ico_sort_date_old = preload("uid://cifx5d8dmjt38")
var ico_sort_new = preload("uid://dvjgbc6hibv5m")
var ico_sort_old = preload("uid://bljitewxdnvuh")

var grid_conts: Array[GridContainer] = []
var is_content_hovered: bool = false
var is_reloading: bool = false:
	set(value):
		is_reloading = value
		h_split_cont.visible = !value
		fb_margin_container.visible = !value
		reload_hider.visible = value
		lv_refresh_btn.disabled = value
var min_cell_width: int = 140
var base_dir = ""
var categories: Array = [] # [["game", gameGridContainer], ["player", playerGridContainer]]
var cat_containers: Array[GridContainer] = []
var log_files: Array[GLLogFile] = []
var cur_logfile: GLLogFile = null:
	set(value):
		cur_logfile = value
		lv_contents_lbl.text = cur_logfile.file_contents if value else ""
		if value != null:
			lv_copy_content_btn.visible = !cur_logfile.file_contents.is_empty() 
var cur_view: bool = false:
	set(value):
		cur_view = value
		lv_view_mode_btn.icon = ico_splitscreen_view if value else ico_fullscreen_view
		lv_view_mode_btn.tooltip_text = "Splitscreen View" if value else "Fullscreen View"
		set_view(BrowserState.LOG_SPLIT if value else BrowserState.LOG_FULL)
var cur_sort: SortModes = SortModes.NEW: 
	set(value):
		cur_sort = value
		var modes := ["\nNew first", "\nOld first", "\nGroup by date - New first", "\nGroup by date - Old first"]
		lv_sort_mode_btn.tooltip_text = str("Sorting by:", modes[value])
		var icons := [ico_sort_new, ico_sort_old, ico_sort_date_new, ico_sort_date_old]
		lv_sort_mode_btn.icon = icons[value]
		data.browser_sort = value

var theme_colors: Dictionary = {}

var state: BrowserState = BrowserState.FILE_LIST
enum BrowserState {
	LOG_FULL,
	LOG_SPLIT,
	FILE_LIST,
	RELOAD_HIDE
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
	
	if event is InputEventKey and event.keycode == KEY_O:
		if event.is_pressed():
			set_view(BrowserState.RELOAD_HIDE)
		if event.is_released():
			set_view(BrowserState.FILE_LIST)
	 


func _ready() -> void:
	for mo in [lv_contents_lbl, lv_scroll_container, lv_panel, lv_panel.get_child(0), lv_title_lbl, log_viewer, log_viewer.get_child(0)]:
		if mo != null:
			mo.mouse_entered.connect(func() -> void: is_content_hovered = true)
			mo.mouse_exited.connect(func() -> void: is_content_hovered = false)
	h_split_cont.dragged.connect(func(offset: int) -> void: _update_columns())
	lv_close_btn.button_up.connect(_close_log_file) 
	lv_refresh_btn.button_up.connect(load_log_browser)
	lv_view_mode_btn.button_up.connect(func() -> void: cur_view = !cur_view)
	lv_sort_mode_btn.button_up.connect(
		func() -> void:
			cur_sort = (cur_sort + 1) % 4
			load_log_browser()
	)
	lv_lbl_sett_btn.toggled.connect(_on_button_toggled.bind(lv_lbl_sett_btn))
	lv_copy_content_btn.button_up.connect(func() -> void: if cur_logfile != null: DisplayServer.clipboard_set(cur_logfile.file_contents))
	resized.connect(_update_columns)
	
	inspector = EditorInspector.new()
	inspector.edit(ResourceLoader.load("uid://cqn5x8cb7vjy3"))
	inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lv_lbl_sett_popup.get_child(0).add_child(inspector) 
	set_view(BrowserState.FILE_LIST)

	lv_title_lbl.text = ""
	lv_contents_lbl.text = ""
	lv_lbl_sett_popup.hide()




func set_view(to: BrowserState) -> void: 
	reload_hider.hide()
	fb_margin_container.hide()
	lv_margin_container.hide()
	fb_margin_container.add_theme_constant_override("margin_right", 0)

	if to != BrowserState.FILE_LIST and cur_logfile == null:
		to = BrowserState.FILE_LIST

	match to:
		BrowserState.FILE_LIST:
			fb_margin_container.show()
		BrowserState.LOG_FULL:
			lv_margin_container.show()
		BrowserState.LOG_SPLIT:
			fb_margin_container.show()
			lv_margin_container.show()
			fb_margin_container.add_theme_constant_override("margin_right", 8)
		BrowserState.RELOAD_HIDE:
			reload_hider.show()
	state = to
	await get_tree().physics_frame
	await get_tree().physics_frame
	_update_columns()




## Used to both initialize and reload the file list
func load_log_browser() -> void:
	var opened_tab = max(0, category_tab_container.current_tab)


	_close_log_file()
	is_reloading = true
	if data != null:
		cur_view = data.browser_view
		base_dir = data.base_dir
	log_files.clear()

	if base_dir == "":
		printerr("[GoLogger] Failed to load Base Directory!") 

	categories.clear()
	grid_conts.clear()

	for child in category_tab_container.get_children():
		category_tab_container.remove_child(child)
		child.queue_free()
	
	var prev_state := state
	set_view(BrowserState.RELOAD_HIDE)
	await get_tree().process_frame
	set_view(prev_state)

	for c in data.categories:
		if c.category_name == "":
				continue
		
		var sc: ScrollContainer = ScrollContainer.new()
		sc.set_name(c.category_name.capitalize())
		category_tab_container.add_child(sc)
		sc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var gc: GridContainer = GridContainer.new()
		sc.add_child(gc)
		gc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gc.size_flags_vertical   = Control.SIZE_EXPAND_FILL 
		gc.add_theme_constant_override("h_separation", GRID_SEPARATION if cur_sort < 2 else GRID_GROUP_SORT_SEPARATION)
		gc.add_theme_constant_override("v_separation", GRID_SEPARATION if cur_sort < 2 else GRID_GROUP_SORT_SEPARATION)
		var n: Array = [c.category_name, gc]
		categories.append(n)
		_load_logfiles(c.category_name, gc)
	
	set_view(BrowserState.LOG_SPLIT if cur_view else BrowserState.LOG_FULL)
	_update_columns(true)
	is_reloading = false 
	if category_tab_container.get_tab_count() > 0:
		category_tab_container.current_tab = opened_tab



func _load_logfiles(category_name: String, base_gc: GridContainer) -> void:
	var actionable_list: PackedStringArray = []
	var grouped_list: Dictionary = {}
	var stray_file_list: PackedStringArray = []
	var fin_list: Array = _sort_file_list(category_name)

	if cur_sort in [SortModes.GROUP_OLD, SortModes.GROUP_NEW]:
		for group in fin_list: 
			_add_logfiles_to_container(base_gc, group, category_name)
	else:
		_add_logfiles_to_container(base_gc, fin_list, category_name)



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



func _add_logfiles_to_container(base_gc: GridContainer, list: Array, category_name: String) -> void:
	var gc : GridContainer
	var is_grouped: bool = cur_sort in [SortModes.GROUP_OLD, SortModes.GROUP_NEW]
	if is_grouped:
		gc = GridContainer.new()
		gc.add_theme_constant_override("h_separation", GRID_SEPARATION)
		gc.add_theme_constant_override("v_separation", GRID_SEPARATION)
		if is_grouped: gc.columns = 3
		base_gc.add_child(gc)
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
			base_gc.add_child(lf)
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

	if !lf.is_file_valid() or f.get_open_error() != OK:
		lf.assign_icon(false)

	f.close()
	return lf



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

	var log_content: String = log_file.file_contents
	
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
	for lf in log_files:
		if lf != log_file and lf.selected:
			lf.selected = false 
	
	log_file.selected = true 
	lv_title_lbl.text = str("  ", log_file.file_name)
	lv_contents_lbl.text = log_content if !log_content.is_empty() else "< File is empty or failed to load properly >"
	cur_logfile = log_file
	set_view(BrowserState.LOG_SPLIT if cur_view else BrowserState.LOG_FULL)
	


func _close_log_file() -> void:
	if cur_logfile:
		cur_logfile.selected = false
		cur_logfile = null
	set_view(BrowserState.FILE_LIST)



func _on_button_toggled(toggled: bool, btn: Button) -> void:
	match btn:
		lv_lbl_sett_btn:
			lv_lbl_sett_popup.visible = toggled 
			lv_margin_container.custom_minimum_size.x = 315 if toggled else 115 



func _update_columns(is_initializing: bool = false) -> void:
	if min_cell_width <= 0: return

	if cur_sort in [SortModes.GROUP_NEW, SortModes.GROUP_OLD]:
		for child in category_tab_container.get_children():
			for grid_cont in child.get_children():
				if grid_cont is GridContainer:
					grid_cont.columns = max(grid_cont.get_child_count(), 1)
		return
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var cell_width: int = 0
	for category in category_tab_container.get_children():
		for grid_cont in category.get_children():
			if grid_cont is GridContainer and log_files.size() > 0:
				cell_width = log_files[0].size.x + grid_cont.get_theme_constant("h_separation")
				grid_cont.columns = max(1, int(grid_cont.size.x / cell_width))