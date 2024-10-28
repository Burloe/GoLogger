extends Resource
class_name LogFileResource

## Resource containing file names and paths in order to scale the number of log files to fit the users need. Allows for renaming of the files and filepaths. By default, the directory where .log files are stored are in the user data folder.
## These paths can be accessed by selecting Project > Open User Data Folder in the top-left.[br]
## Normally located in:[br]
## Windows: %APPDATA%\Godot\app_userdata\[project_name][br]
## macOS:   ~/Library/Application Support/Godot/app_userdata/[project_name][br]
## Linux:   ~/.local/share/godot/app_userdata/[project_name]

## Sets the file name prefix, followed by the date and timestamp. prefix(241118_130959).log. If left empty, prefix will be "file1". 
@export_placeholder("Enter file name prefix.") var filename_prefix : String = ""
## Use to set a custom filepath to store logs within. If left empty, files are saved in "user://logs/file1_Gologs/". Uses [param filename_prefix] in the directory path[br][b]Note:[/b][br]    One or more folders are created within this directory for each [LogFileResource] in the plugin's [param file] parameter.
@export var filepath 	: String = "user://logs/"

var current_file	 	: String = ""
var current_filepath 	: String = ""
var entry_count			: int = 0

@export var save_uniques_in_subfolder : bool = true ## When enabled, saving unique logs using the hotkey or controller will store the .log file within a subfolder of [param filepath].
