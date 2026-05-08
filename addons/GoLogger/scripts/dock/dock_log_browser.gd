@tool
extends HBoxContainer

signal log_file_added(log_file: Button) ## Emitted to Dock to update font colors

@onready var fb_margin_container: MarginContainer = %FBMarginContainer
@onready var lv_margin_container: MarginContainer = %LVMarginContainer
@onready var category_tab_container = %CategoryTabContainer
@onready var reload_hider: VBoxContainer = %ReloadHider
@onready var log_viewer: Panel = %LogViewer
@onready var h_split_cont: HSplitContainer = %HSplitContainer
@onready var lv_title_lbl: Label = %ViewerTitleLabel
@onready var lv_refresh_btn: Button = %ViewerRefreshButton
@onready var lv_view_type_btn: Button = %ViewTypeButton
@onready var lv_close_btn: Button = %ViewerCloseButton
@onready var lv_contents_lbl: Label = %ContentLabel

@onready var lv_panel: Panel = %LVPanel
@onready var lv_scroll_container: ScrollContainer = %LVScrollContainer

@onready var lv_lbl_sett_btn: Button = %ViewerLblSettButton
@onready var lv_lbl_sett_popup: PanelContainer = %LblSettInspectorPopup
@onready var lv_lbl_sett_popup_scroll_cont: ScrollContainer = %LblSettPopupScrollContainer
var inspector: EditorInspector

const PATH = "user://gologger_data.ini"

var fullscreen_view := preload("uid://ijiplwclq5pu")
var splitscreen_view := preload("uid://cp2p55wdq2wuk")
var log_file_btn := preload("uid://bq7nahsc5aca7")
var cont_lbl_sett = preload("uid://cqn5x8cb7vjy3")

var config: ConfigFile = ConfigFile.new()
var grid_conts: Array[GridContainer] = []
var is_content_hovered: bool = false
var is_reloading: bool = false:
	set(value):
		is_reloading = value
		h_split_cont.visible = !value
		reload_hider.visible = value
var min_cell_width: int = 140
var base_dir = ""
var categories: Array = [] # [["game", gameGridContainer], [player, playerGridContainer]]
var cat_containers: Array[GridContainer] = []
var cur_logfile: GLLogFile = null:
	set(value):
		cur_logfile = value
		lv_contents_lbl.text = cur_logfile.file_contents if value else ""
var log_files: Array[GLLogFile] = []

var log_errors: Dictionary = {
	"OK": "Success",
	"FAIL_CONTENT_LOAD": "Failed to load log file contents...",
	"ERR_FILE_ACCESS": "FileAccess error!"
}

var state: BrowserState = BrowserState.FILE_LIST
enum BrowserState {
	LOG_FULL,
	LOG_SPLIT,
	FILE_LIST
}




func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
		if state != BrowserState.FILE_LIST and is_content_hovered:
			_close_log_file()
	 


func _ready() -> void:
	config.load(PATH)
	load_log_browser(true)

	for mo in [lv_contents_lbl, lv_scroll_container, lv_panel, lv_panel.get_child(0), lv_title_lbl, log_viewer, log_viewer.get_child(0)]:
		if mo != null:
			mo.mouse_entered.connect(func() -> void: is_content_hovered = true)
			mo.mouse_exited.connect(func() -> void: is_content_hovered = false)

	h_split_cont.dragged.connect(func(offset: int) -> void: _update_columns())
	lv_close_btn.button_up.connect(_close_log_file)
	lv_refresh_btn.button_up.connect(load_log_browser)
	lv_view_type_btn.toggled.connect(_on_button_toggled.bind(lv_view_type_btn))
	lv_lbl_sett_btn.toggled.connect(_on_button_toggled.bind(lv_lbl_sett_btn))
	resized.connect(_update_columns)
	lv_title_lbl.text = ""
	lv_contents_lbl.text = ""
	lv_lbl_sett_popup.hide()
	
	inspector = EditorInspector.new()
	inspector.edit(ResourceLoader.load("uid://cqn5x8cb7vjy3"))
	inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lv_lbl_sett_popup.get_child(0).add_child(inspector) 




func set_view(to: BrowserState) -> void:
	config.load(PATH)
	reload_hider.hide()
	fb_margin_container.hide()
	lv_margin_container.hide()

	match to:
		BrowserState.FILE_LIST:
			fb_margin_container.show()
		BrowserState.LOG_FULL:
			lv_margin_container.show()
			fb_margin_container.add_theme_constant_override("margin_right", 0)
		BrowserState.LOG_SPLIT:
			fb_margin_container.show()
			lv_margin_container.show()
			fb_margin_container.add_theme_constant_override("margin_right", 8)
	state = to




## Used to both initialize and reload the file list
func load_log_browser(is_initializing: bool = false) -> void:
	_close_log_file()
	is_reloading = true
	var e := config.load(PATH)
	if e != OK: printerr("Failed to load config: ", error_string(e))
	var view = config.get_value("settings", "browser_view", 0)
	lv_view_type_btn.button_pressed = true if view == 1 else false
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
	
	if !is_initializing:
		lv_refresh_btn.disabled = true
		fb_margin_container.hide()
		reload_hider.show()
		await get_tree().create_timer(0.1).timeout 
		lv_refresh_btn.disabled = false
		fb_margin_container.show()
		reload_hider.hide()

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
	
	_update_columns()
	is_reloading = false



func _load_logfiles(category_name: String) -> void: 
	config.load(PATH)
	var file_list: PackedStringArray = _get_category_files(category_name) 

	var actionable_list: PackedStringArray = [] 
	for file in file_list:
		if file.ends_with(".log"): 
			actionable_list.append(file)

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
	set_view(config.get_value("settings", "browser_view"))
	


func _close_log_file() -> void:
	set_view(BrowserState.FILE_LIST)
	if cur_logfile:
		cur_logfile.selected = false
		cur_logfile = null
	await get_tree().physics_frame
	_update_columns()



func display_log_file_error(log_file: GLLogFile) -> void:
	pass



func _on_button_toggled(toggled: bool, btn: Button) -> void:
	match btn:
		lv_view_type_btn:
			lv_view_type_btn.icon = splitscreen_view if lv_view_type_btn.button_pressed else fullscreen_view
			if toggled:
				set_view(BrowserState.FILE_LIST if cur_logfile == null else BrowserState.LOG_SPLIT)
			else:
				set_view(BrowserState.FILE_LIST if cur_logfile == null else BrowserState.LOG_FULL)

			config.load(PATH)
			config.set_value("settings", "browser_view", 1 if toggled else 0)
			config.save(PATH)
			await get_tree().physics_frame
			_update_columns()

		lv_lbl_sett_btn:
			lv_lbl_sett_popup.visible = toggled 
			lv_margin_container.custom_minimum_size.x = 315 if toggled else 115 



func _update_columns() -> void:
	if min_cell_width <= 0:
		return
	var cols = max(1, int(category_tab_container.size.x / min_cell_width))
	for i in range(categories.size()):
		if categories[i][1] is GridContainer and categories[i][1] != null:
			categories[i][1].columns = cols