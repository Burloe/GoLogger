@tool
extends HBoxContainer


@onready var add_category_btn: Button = %AddCategoryButton
@onready var category_container: GridContainer = %CategoryGridContainer
@onready var open_dir_btn: Button = %OpenDirCatButton
@onready var reset_settings_btn: Button = %ResetSettingsButton

@export var data: GLData = null

signal request_save(source: String) ## Emitted to dock.gd to save the entire dock state to file. "source" is used to specify what action emitted the signal for debugging purposes.
signal request_categories_save
signal request_theme_colors 


# const PATH = "user://gologger_data.ini"

@export var min_cell_width: int = 120

var theme_colors: Dictionary = {}
var category_scene = preload("uid://c3n416c5fajm5")
# var config = ConfigFile.new() 

var is_shutting_down: bool = false
var _default_setting_in_progress: bool = false  
var _column_update_pending: bool = false

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

	visibility_changed.connect(func() -> void: if visible: request_update_columns())
	resized.connect(_update_columns)
	_connect_unique(add_category_btn.button_up, _add_category) 
	

	for log_c in category_container.get_children():
		if log_c is not LogCategory:
			print_rich("[color=fb776a]GoLogger error: Unexpected node in category container ", log_c.get_name(), "{", log_c.get_class(), "} - Please report bug: [url]https://github.com/Burloe/GoLogger/issues[/url][/color]")
		log_c.queue_free()
	
	request_update_columns()



## Called by dock.gd after data is initialized.
func initialize_tab() -> void:	
	ensure_default_category()
	for cat in data.categories:
		_add_category(
			cat.category_name,
			cat.is_locked
		)

	if data.default_category != "":
		for cat in category_container.get_children():
			if cat is LogCategory and cat.category_name == data.default_category and cat.default_checkbox != null:
				cat.default_checkbox.button_pressed = true
				break

	request_update_columns()



func _connect_unique(signal_obj: Signal, callback: Callable) -> void:
	if signal_obj.is_connected(callback):
		signal_obj.disconnect(callback)
	signal_obj.connect(callback)

#endregion




#region Public Functions

func ensure_default_category() -> void:
	var c_names := []
	for c in data.categories:
		c_names.append(c.category_name)
	if c_names.is_empty() and data.default_category != "" or !c_names.has(data.default_category):
		data.default_category = ""



func _on_category_move_requested(category: LogCategory, direction: int) -> void:
	var cats: Array = category_container.get_children()
	var from: int = category.get_index()
	var to: int = from
	to += direction
	
	if to < 0 or to >= cats.size():
		return

	category_container.move_child(category, to)
	request_categories_save.emit()

#endregion



#region Private Functions

func _add_category(_name: String = "", _is_locked: bool = false) -> void: 
	var _n = category_scene.instantiate() as LogCategory 
	var low_name: String = _name.to_lower()
	_n.category_name = low_name
	_n.is_locked = _is_locked
	category_container.add_child(_n)
	_n.data = data

	var _c_data: GLCategoryData = GLCategoryData.new()
	_c_data.category_name = low_name
	_n.cat_data = _c_data
	_n._data_ready()
	data.categories.append(_c_data)

	_n.log_category_changed.connect(func() -> void: request_categories_save.emit())
	_n.set_default_category.connect(_on_set_default_category)
	_n.move_category_requested.connect(_on_category_move_requested)
	_n.tree_entered.connect(request_update_columns)
	_n.tree_exited.connect(_on_category_tree_exited.bind(_n.category_name))
	
	if !low_name.is_empty():
		_n.default_checkbox.button_pressed = data.default_category == low_name
	else:	
		_n.line_edit.grab_focus()
		
	handle_category_mov_button_state()
	request_update_columns()
 



func _on_category_tree_exited(name: String) -> void: 
	if is_shutting_down:
		return
	
	handle_category_mov_button_state()
	request_categories_save.emit()
	request_update_columns() 


func request_update_columns() -> void:
	if _column_update_pending or !is_inside_tree():
		return

	_column_update_pending = true
	_deferred_update_columns.call_deferred()


func _deferred_update_columns() -> void:
	if !is_inside_tree():
		_column_update_pending = false
		return

	await get_tree().process_frame
	await get_tree().process_frame

	_column_update_pending = false
	if is_inside_tree():
		_update_columns()

	 

func _on_set_default_category(cat: LogCategory, set_status: bool) -> void:
	if _default_setting_in_progress:
		return
	
	_default_setting_in_progress = true
	
	for log_c in category_container.get_children():
		if log_c is LogCategory and log_c.default_checkbox != null:
			if log_c != cat:
				log_c.default_checkbox.button_pressed = false

	if set_status and cat.default_checkbox != null:
		cat.default_checkbox.button_pressed = true
	
	data.default_category = cat.category_name if set_status else "" 
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

#endregion




#region Signal receivers

func _update_columns() -> void:
	if min_cell_width <= 0:
		return
	
	var cols = max(1, int(category_container.size.x / min_cell_width))
	category_container.columns = cols
	# print("Size.x: ", category_container.size.x, "       Cell Width: ", min_cell_width, "       Applied column value: ", cols)

#endregion


