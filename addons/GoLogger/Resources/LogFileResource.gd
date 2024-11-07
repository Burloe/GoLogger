extends Resource
class_name LogFileResource

##DEPRECATED
## Resource containing file names and paths in order to expand the number of log files to fit the users need. By default, the directory where .log files are stored are in the user data folder.
## These paths can be accessed by selecting Project > Open User Data Folder in the top-left.[br]
## Normally located in:[br]
## Windows: %APPDATA%\Godot\app_userdata\[project_name][br]
## macOS:   ~/Library/Application Support/Godot/app_userdata/[project_name][br]
## Linux:   ~/.local/share/godot/app_userdata/[project_name]

## Name of the log category. This determines both the name of the folder created for this category and the name of each .log file followed by the date and timestamp(name(241118_130959).log). If left empty, the name will default to "file" + the categories position in the array.
@export_placeholder("Enter category name.") var category_name : String = ""

var current_file	 	: String = ""
var current_filepath 	: String = ""
var file_count 			: int = 0
var entry_count			: int = 0

