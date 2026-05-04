@tool
extends HBoxContainer


@onready var add_category_btn: Button = %AddCategoryButton
@onready var category_container: GridContainer = %CategoryGridContainer
@onready var open_dir_btn: Button = %OpenDirCatButton 
@onready var column_slider: VSlider = %ColumnsVSlider
@onready var reset_settings_btn: Button = %ResetSettingsButton


signal request_save(source: String) ## Emitted to dock.gd to save the entire dock state to file. "source" is used to specify what action emitted the signal for debugging purposes.
signal request_categories_save
signal request_theme_colors 


const PATH = "user://gologger_data.ini"

var theme_colors: Dictionary = {}
var category_scene = preload("uid://c3n416c5fajm5")
var config = ConfigFile.new() 

var is_shutting_down: bool = false
var _default_setting_in_progress: bool = false  

var settings_dict: Dictionary = {}



enum LimitMethod { ## Index 3 is a SEPERATOR and should not be used.
	ENTRY_COUNT,
	SESSION_TIMER,
	BOTH,
	SEPERATOR,
	NONE
}

enum EntryCountAction { #Delete?
	OVERWRITE_ENTRIES,
	RESTART,
	STOP
}

enum SessionTimerAction {#Delete?
	RESTART,
	STOP
}

enum ErrorReportLevel {
	WARNINGS_ERRORS,
	ERRORS,
	NONE
}


#region Initializers

func _ready() -> void:

	config.load(PATH)
	ensure_default_category()

	_connect_unique(add_category_btn.button_up, _add_category)
	_connect_unique(column_slider.value_changed, _on_column_slider_value_changed)

	for log_c in category_container.get_children():
		if log_c is not LogCategory:
			print_rich("[color=fb776a]GoLogger error: Unexpected node in category container ", log_c.get_name(), "{", log_c.get_class(), "} - Please report bug: [url]https://github.com/Burloe/GoLogger/issues[/url][/color]")
		log_c.queue_free()



## Called by dock.gd after settings_dict is initialized.
func initialize_tab() -> void:
	if config.load(PATH) != OK:
		printerr("GoLogger Error: Failed to load settings.ini file!")
		return
	
	for c_name in config.get_value("categories", "category_names", []):
		_add_category(
			c_name, 
			config.get_value("categories." + c_name, "is_locked", false)
		)

	var def_cat = config.get_value("categories", "default_category", "")
	if def_cat != "":
		for cat in category_container.get_children():
			if cat is LogCategory and cat.category_name == def_cat and cat.default_checkbox != null:
				cat.default_checkbox.button_pressed = true
				break
	
	column_slider.value = _get_column_value(
		config.get_value("settings", "columns", settings_dict.get("columns", {}).get("default", 5))
	)



func _connect_unique(signal_obj: Signal, callback: Callable) -> void:
	if signal_obj.is_connected(callback):
		signal_obj.disconnect(callback)
	signal_obj.connect(callback)

#endregion




#region Public

func ensure_default_category() -> void:
	config.load(PATH)
	var cat_names: Array = config.get_value("categories", "category_names", [])
	var def_cat: String = config.get_value("categories", "default_category", "")
	if cat_names.is_empty() and def_cat != "" or !cat_names.has(def_cat):
		config.set_value("categories", "default_category", "")
	config.save(PATH)



func _on_category_move_requested(category: LogCategory, direction: int) -> void:
	var cats: Array = category_container.get_children()
	var from: int = category.get_index()
	var to: int = from
	to += direction
	
	if to < 0 or to >= cats.size():
		return

	category_container.move_child(category, to)
	request_categories_save.emit()
	# save_categories() 

#endregion



#region Private functions

func _add_category(_name: String = "", _is_locked: bool = false) -> void:
	config.load(PATH)
	var _n = category_scene.instantiate() as LogCategory
	var _def = config.get_value("categories", "default_category", "")
	_n.category_name = _name
	_n.is_locked = _is_locked 
	category_container.add_child(_n)

	_n.log_category_changed.connect(func() -> void: request_categories_save.emit()) 
	# _n.log_category_changed.connect(save_categories) 
	_n.set_default_category.connect(_on_set_default_category)
	_n.move_category_requested.connect(_on_category_move_requested)
	if !_name.is_empty():
		_n.default_checkbox.button_pressed = _def == _name
	_n.tree_exited.connect(_on_category_tree_exited.bind(_n.category_name)) 

	if _name == "":	_n.line_edit.grab_focus()
	handle_category_mov_button_state()
 



func _on_category_tree_exited(name: String) -> void: 
	if is_shutting_down:
		return
	
	handle_category_mov_button_state()
	request_categories_save.emit()
	# save_categories()

	 

func _on_set_default_category(cat: LogCategory, set_status: bool) -> void:
	if _default_setting_in_progress:
		return

	_default_setting_in_progress = true
	config.load(PATH)
	config.set_value("categories", "default_category", cat.category_name if set_status else "")

	for log_c in category_container.get_children():
		if log_c is LogCategory and log_c.default_checkbox != null:
			if log_c != cat:
				log_c.default_checkbox.button_pressed = false

	if set_status and cat.default_checkbox != null:
		cat.default_checkbox.button_pressed = true

	config.save(PATH)
	_default_setting_in_progress = false

func handle_category_mov_button_state() -> void:
	for i in range(category_container.get_child_count()):
		var category = category_container.get_child(i)
		category.move_left_btn.disabled = (i == 0)
		category.move_right_btn.disabled = (i == category_container.get_child_count() - 1)

#endregion







#region Helpers

func _check_conflict_name(cat_obj: LogCategory, new_name: String) -> bool:
	for log_c in category_container.get_children():
		if log_c == cat_obj:
			continue
		elif log_c.category_name == new_name:
			if name == "": return false
			return true
	return false



## Returns the inverted value for the column slider
func _get_column_value(slider_value: int) -> int:
	return clampi(slider_value, column_slider.min_value, column_slider.max_value)

#endregion




#region Signal receivers


func _on_column_slider_value_changed(value: int) -> void:
	config.load(PATH)
	category_container.columns = _get_column_value(value)
	column_slider.tooltip_text = str("Columns: ", _get_column_value(value))
	config.set_value("settings", "columns", _get_column_value(value)) 
	request_save.emit()

#endregion


