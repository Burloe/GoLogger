@tool
class_name GLData extends Resource

#! TBD NYI
## Proposed resourced based saving system rather than a ConfigFile approach


# Would implement a CustomResource for the categories that replaces the [categories.category_name] section
# @export var categories: Array[GLCategory] = [] 
@export var category_names: Array[String] = ["game"]
@export var default_category: String = ""

@export var base_directory: String = "user://gologger/"
@export var log_header_format: String = "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:"
@export var entry_format: String = "[{hh}:{mi}:{ss}] {instance_id}: {entry}"
@export var autostart_session: bool = true
@export var use_utc: bool = false
@export var id_print: bool = false
@export var id_toggle: bool = false
@export var id_startup_state: bool = false
@export_enum("Top-Left", "Top-Center", "Top-Right", "Center-Left", "Center-Center", "Center-Right", "Bottom-Left", "Bottom-Center", "Bottom-Right") var id_align: int = 0
@export_enum("Entry Count", "Session Timer", "Both", "Separator", "None") var limit_method: int = 0
@export_enum("Overwrite Entries", "Restart Session", "Stop Session") var entry_count_action: int = 0
@export_enum("Restart Session", "Stop Session") var session_timer_action: int = 0
@export var file_cap: int = 10
@export var entry_cap: int = 2000
@export var session_duration: int = 1200
@export_enum("Warnings & Errors", "Warnings only", "None") var error_reporting: int = 0
@export var columns: int = 5