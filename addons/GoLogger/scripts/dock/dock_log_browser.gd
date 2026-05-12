@tool
extends HBoxContainer

signal log_file_added(log_file: Button) ## Emitted to Dock to update font colors

@onready var reload_hider: MarginContainer = %ReloadTopper
@onready var fb_margin_container: MarginContainer = %FBMarginContainer
@onready var lv_margin_container: MarginContainer = %LVMarginContainer
@onready var category_tab_container = %CategoryTabContainer
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
var inspector: EditorInspector

const PATH = "user://gologger_data.ini"

var ico_fullscreen_view := preload("uid://ijiplwclq5pu")
var ico_splitscreen_view := preload("uid://cp2p55wdq2wuk")
var log_file_btn := preload("uid://bq7nahsc5aca7")
var cont_lbl_sett = preload("uid://cqn5x8cb7vjy3")

var config: ConfigFile = ConfigFile.new()
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
var categories: Array = [] # [["game", gameGridContainer], [player, playerGridContainer]]
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
var cur_sort: int = 0: # [0] Name Descend, [1] Name Ascend, [2]Day Descend, [3] Day Ascend
	set(value):
		cur_sort = value
		var modes := ["[Name Descending]", "[Name Descending]", "[Day Descending]", "[Day Ascending]"]
		lv_sort_mode_btn.tooltip_text = str("Sorting by: ", modes[value])
var reload_buffer_time: float = 0.01

var log_errors: Dictionary = {
	"OK": "Success",
	"FAIL_CONTENT_LOAD": "Failed to load log file contents...",
	"ERR_FILE_ACCESS": "FileAccess error!"
}

var state: BrowserState = BrowserState.FILE_LIST
enum BrowserState {
	LOG_FULL,
	LOG_SPLIT,
	FILE_LIST,
	RELOAD_HIDE
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
	config.load(PATH)
	load_log_browser()

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
	config.load(PATH)
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
	_update_columns()




## Used to both initialize and reload the file list
func load_log_browser() -> void:
	_close_log_file()
	is_reloading = true
	var e := config.load(PATH)
	if e != OK: printerr("Failed to load config: ", error_string(e))
	cur_view = config.get_value("settings", "browser_view", false)
	base_dir = config.get_value("settings", "base_directory", "")
	var cats = config.get_value("categories", "category_names", [])
	log_files.clear()

	if base_dir == "":
		printerr("Failed to load Base Directory!")
	if cats.is_empty():
		printerr("Failed to load Categories!") 

	categories.clear()
	grid_conts.clear()

	for child in category_tab_container.get_children():
		child.queue_free()
	
	var prev_state := state
	set_view(BrowserState.RELOAD_HIDE)
	await get_tree().create_timer(reload_buffer_time).timeout
	set_view(prev_state)

	for c in cats:

		if c == "":
				continue
		
		var sc: ScrollContainer = ScrollContainer.new()
		sc.set_name(c)
		category_tab_container.add_child(sc)
		sc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var gc: GridContainer = GridContainer.new()
		sc.add_child(gc) 
		gc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gc.size_flags_vertical   = Control.SIZE_EXPAND_FILL 
		gc.add_theme_constant_override("h_separation", 8)
		gc.add_theme_constant_override("v_separation", 8)
		var n: Array = [c, gc]
		categories.append(n)
		_load_logfiles(c)
	
	set_view(BrowserState.LOG_SPLIT if cur_view else BrowserState.LOG_FULL)
	_update_columns(true)
	is_reloading = false



func _load_logfiles(category_name: String) -> void: 
	config.load(PATH)
	var file_list: PackedStringArray = _get_category_files(category_name) 

	var actionable_list: PackedStringArray = [] 
	for file in file_list:
		if file.ends_with(".log"): 
			actionable_list.append(file)
	
	if cur_sort in [1, 3]: actionable_list.reverse()

	for file in actionable_list:
		var file_path: String = str(base_dir.path_join(str(category_name, "_logs")).path_join(file), "/")
		
		if not FileAccess.file_exists(file_path):
			continue

		var f = FileAccess.open(file_path, FileAccess.READ)
		var content = f.get_file_as_string(file_path)
			

		var lf: GLLogFile = log_file_btn.instantiate() as GLLogFile
		lf.category_name = category_name
		lf.file_name = file
		lf.file_path = file_path
		lf.file_contents = f.get_file_as_string(file_path)
		lf.assign_icon(true)

		if !lf.is_file_valid() or f.get_open_error() != OK:
			lf.assign_icon(false)

		for c in categories:
			# print("category_namae: ", category_name, "   iterated category: ", c, "    saved array category: ", c)
			if c[0] != category_name:
				continue
			
			c[1].add_child(lf)
			log_files.append(lf)
			lf.button_up.connect(_open_log_file.bind(lf))
			log_file_added.emit(lf)

		lv_contents_lbl.text = content
		f.close()



# func apply_sort(sort: int, files: Array) -> void:
# 	match sort:
# 		0: # time ascending
# 			files.reverse()
# 		1: # time descending

# 		2: # day



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

	config.load(PATH)
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



func display_log_file_error(log_file: GLLogFile) -> void:
	pass



func _on_button_toggled(toggled: bool, btn: Button) -> void:
	match btn:
		lv_lbl_sett_btn:
			lv_lbl_sett_popup.visible = toggled 
			lv_margin_container.custom_minimum_size.x = 315 if toggled else 115 



func _update_columns(is_initializing: bool = false) -> void:
	if min_cell_width <= 0:
		return
	
	var width = int(size.x - 55) if is_initializing else category_tab_container.size.x
	var cols = max(1, int(width / min_cell_width))
	for i in range(categories.size()):
		if categories[i][1] is GridContainer and categories[i][1] != null:
			categories[i][1].columns = cols 