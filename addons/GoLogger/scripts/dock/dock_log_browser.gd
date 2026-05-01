@tool
extends Control

signal log_file_added(log_file: Button) ## Emitted to Dock to update font colors

@onready var category_tab_container = %CategoryTabContainer
@onready var fake_topbar: VBoxContainer = %FakeTopBar
@onready var log_viewer: Panel = %LogViewer
@onready var lv_title_lbl: Label = %ViewerTitleLabel
@onready var lv_refresh_btn: Button = %ViewerRefreshButton
@onready var lv_close_btn: Button = %ViewerCloseButton
@onready var lv_font_size_slider: VSlider = %ViewerFontSizeVSlider
@onready var lv_contents_lbl: Label = %ContentLabel
@onready var ctrl_padding: Control = %Padding

@onready var lv_panel: Panel = %LVPanel
@onready var lv_scroll_container: ScrollContainer = %LVScrollContainer
# @onready var lv_panel: Panel = %LVPanel


@export var grid_columns: int = 10
const PATH = "user://gologger_data.ini"
var log_file_btn := preload("uid://bq7nahsc5aca7")
var cont_lbl_sett = preload("uid://cqn5x8cb7vjy3")
var config: ConfigFile = ConfigFile.new()
var base_dir = ""
var categories: Array = [] # 2D array of category names and it's associated [GridContainer]
var cat_containers: Array[GridContainer] = [] 

enum BrowserState {
	LIST_VIEW,
	LOG_VIEW
}
var state: BrowserState = BrowserState.LIST_VIEW
var mo_states: Dictionary = {
	"log_browser": {
		"state": false,
		"ref": self
	},
	"category_tab_container": {
		"state": false,
		"ref": category_tab_container
	},
	"log_viewer": {
		"state": false,
		"ref": log_viewer
	},
	"lv_panel": {
		"state": false,
		"ref": lv_panel
	},
	"lv_scroll_container": {
		"state": false,
		"ref": lv_scroll_container
	},
	"content_lbl": {
		"state": false,
		"ref": lv_contents_lbl
	}
}


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
		if state == BrowserState.LOG_VIEW and is_any_hovered():
			_toggle_view()



func _ready() -> void:
	load_log_browser(true)
	lv_close_btn.button_up.connect(_on_button_up.bind(lv_close_btn))
	lv_refresh_btn.button_up.connect(_on_button_up.bind(lv_refresh_btn))
	lv_font_size_slider.value_changed.connect(on_slider_value_changed.bind(lv_font_size_slider))
	lv_font_size_slider.value = lv_contents_lbl.label_settings.font_size 
	
	mo_states["log_browser"]["ref"] = self
	mo_states["category_tab_container"]["ref"] = category_tab_container
	mo_states["log_viewer"]["ref"] = log_viewer
	mo_states["lv_panel"]["ref"] = lv_panel
	mo_states["lv_scroll_container"]["ref"] = lv_scroll_container
	mo_states["content_lbl"]["ref"] = lv_contents_lbl

	for key in mo_states.keys():
		if mo_states[key]["ref"] != null:
			mo_states[key]["ref"].mouse_entered.connect(func() -> void: mo_states[key]["state"] = true)
			mo_states[key]["ref"].mouse_exited.connect(func() -> void: mo_states[key]["state"] = false)
			print(key)



func init_visibility() -> void:
	category_tab_container.show()
	log_viewer.hide()
	lv_refresh_btn.show()
	lv_close_btn.hide()
	lv_font_size_slider.hide()
	ctrl_padding.show()
	state = BrowserState.LIST_VIEW 



## Used to both initialize and reload the file list
func load_log_browser(is_initializing: bool = false) -> void:
	var e := config.load(PATH)
	if e != OK: printerr("Failed to load config: ", error_string(e))
	base_dir = config.get_value("settings", "base_directory", "")
	var cats = config.get_value("categories", "category_names", [])

	if base_dir == "":
		printerr("Failed to load Base Directory!")
	if cats.is_empty():
		printerr("Failed to load Categories!") 

	categories.clear()

	for child in category_tab_container.get_children():
		child.queue_free()
	
	if !is_initializing:
		lv_refresh_btn.disabled = true
		category_tab_container.hide()
		fake_topbar.show()
		await get_tree().create_timer(0.1).timeout 
		lv_refresh_btn.disabled = false
		category_tab_container.show()
		fake_topbar.hide()

	for c in cats:

		if c == "":
				continue
		
		var gc: GridContainer = GridContainer.new()
		gc.columns = grid_columns
		category_tab_container.add_child(gc)
		gc.set_name(c)
		gc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gc.size_flags_vertical   = Control.SIZE_EXPAND_FILL 
		gc.add_theme_constant_override("h_separation", 8)
		gc.add_theme_constant_override("v_separation", 8)
		var n: Array = [c, gc]
		categories.append(n)
		_load_logfiles(c)



func _load_logfiles(category_name: String) -> void: 
	var file_list: PackedStringArray = _get_category_files(category_name) 

	for file in file_list:
		var file_path: String = str(base_dir.path_join(str(category_name, "_logs")).path_join(file), "/")
		
		if not FileAccess.file_exists(file_path):
			continue

		var f = FileAccess.open(file_path, FileAccess.READ)
		var content = f.get_file_as_string(file_path)
			

		var lf: Button = log_file_btn.instantiate() as Button
		lf.category_name = category_name
		lf.file_name = file 
		lf.file_path = file_path
		lf.file_contents = f.get_file_as_string(file_path)

		if lf.file_contents.is_empty() or f.get_open_error() != OK:
			lf.assign_icon(false)

		for c in categories:
			# print("category_namae: ", category_name, "   iterated category: ", c, "    saved array category: ", c)
			if c[0] != category_name:
				continue
			
			c[1].add_child(lf)
			lf.button_up.connect(_open_log_file.bind(lf))
			log_file_added.emit(lf)

		lv_contents_lbl.text = content
		f.close()






func _get_file_contents(log_file: GLLogFile) -> String:
	var f := FileAccess.open(log_file.file_path, FileAccess.READ)
	if f == null:
		return str("Failed to fetch file contents - FileAccess error[", f.get_open_error(), "] opening: ", log_file.file_path)
	var content: String = f.get_file_as_string(log_file.file_path)

	if content.is_empty():
		return str("Failed to fetch file contents - FileAccess error[", f.get_open_error(), "] opening: ", log_file.file_path)
	
	log_file.file_contents = content
	f.close()

	return content



func _get_category_files(category_name: String) -> PackedStringArray:
	if categories.is_empty():
		return []	
	if base_dir == "":
		return []

	var c_path: String = str(base_dir.path_join(category_name), "_logs/")

	var d := DirAccess.open(c_path)
	if d != null:
		return d.get_files()

	printerr("Failed to open category path: ", c_path)
	return []



func _toggle_view() -> void:
	fake_topbar.hide()
	match state:
		BrowserState.LIST_VIEW:
			category_tab_container.hide()
			log_viewer.show()
			lv_refresh_btn.hide()
			lv_close_btn.show()
			lv_font_size_slider.show()
			ctrl_padding.hide()
			state = BrowserState.LOG_VIEW
		BrowserState.LOG_VIEW:
			category_tab_container.show()
			log_viewer.hide()
			lv_refresh_btn.show()
			lv_close_btn.hide()
			lv_font_size_slider.hide()
			ctrl_padding.show()
			state = BrowserState.LIST_VIEW



func _open_log_file(log_file: GLLogFile) -> void:
	var log_content: String = _get_file_contents(log_file)
	if log_content.begins_with("Failed"):
		display_log_file_error(log_file)
		return


	var _timestamp: String = log_file.file_name.lstrip(str(log_file.category_name, "(")).rstrip(str(").log"))
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

	lv_title_lbl.text = str("    ", log_file.category_name.capitalize(), " ", fin_date, " [",fin_time, "] ", "   -   ", log_file.file_name)
	lv_contents_lbl.text = log_content
	_toggle_view() 



func display_log_file_error(log_file: GLLogFile) -> void:
	pass



func is_any_hovered() -> bool: 
	for key in mo_states.keys():
		if mo_states[key]["state"]:
			return true
	return false



func _on_button_up(btn: Button) -> void:
	match btn:
		lv_close_btn:
			_toggle_view()  
		lv_refresh_btn:
			load_log_browser()



func on_slider_value_changed(value: int, slider: VSlider) -> void:
	match slider:
		lv_font_size_slider:
			cont_lbl_sett.font_size = value