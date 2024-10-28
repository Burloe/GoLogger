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

var current_file	 	: String = ""
var current_filepath 	: String = ""
var entry_count			: int = 0

