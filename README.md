# ![GoLogger.svg](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/GoLogger.svg) GoLogger
A basic lightweight logging system for game events in into one or more external .log file for Godot 4.<br>
 
https://github.com/user-attachments/assets/f8b55481-cd32-4be3-9e06-df4368d1183c

<br><br>
## Introduction
Have you ever found yourself working on multiple new features or a large system involving numerous scripts, adding countless print statements to debug? This can clutter the output, making the information difficult to decipher and even harder to manage. Or perhaps you want your game to record events to help debug issues that your players encounter, especially when you can’t access their instance. In that case, creating a logging system to record game events could provide a snapshot of the events leading up to a bug or crash.

This plugin is a basic logging system designed to serve as a foundation for you to build upon. As such, it is intentionally minimalistic, making it flexible and scalable. The plugin logs any game event or data(that can be converted into a string) to a .log file. However, simply installing this plugin won’t instantly and automatically generate log entries once installed. on the plus side, adding these log entries to your code is almost as simply as writing a print() statement:
	
 	Log.entry(0, "Your log entry message.")	# Result: [2024-04-04 14:04:44] Your log entry message.

**Note: This system is only as comprehensive and detailed as you make it.** But it also works as a simple standalone logging system as is.<br><br><br>

## .log files
GoLogger will create and add logs to three .log files, named 'game.log', 'ui.log' and 'player.log'. Modifying the plugin to use different names is simple and steps are detailed in Modify paragraph of the "How to Use" section. The .log files are located in the User Data folder can be accessed through `Project > Open User Data Folder` and opening the `logs` folder. This folder location is different on every OS. Because they are stored externally from the project, your players/users can access these logs file and can include them when making bug reports to the developer(you).

## Installation and setup:
GoLogger requires an autoload to manage a signal and a few variables due to the nature of the static functions we use to be able to call them from anywhere in this way. When installing the plugin, an autoload "GoLogger.gd" is included and added to your autoloads automatically. GoLogger contains just 8 lines of code which can just as easily be incorporated into one of your existing autoload scripts. Therefore, it is **HIGHLY** recommended to do just that, and steps on how to do that is provided in the "Additional Setup".

###**Installation:**
* Download the plugin from either GitHub(!https://github.com/Burloe/GoLogger) or the Asset Library. If you download the .zip from GitHub, extract **only** the "addons" folder to any folder in your PC, then place the extracted "addons" folder into your project's root directory. The folder structure should look like `res://addons/GoLogger`. 
* Navigate to `Project > Project Settings > Plugins`, where you should see "GoLogger" as an unchecked entry in the list of installed plugins. Check it to activate the plugin.
* Go to `Project > Project Settings > Globals > Autoload` and ensure that the GoLogger autoload has been added correctly. If not, you can manually add it by clicking the folder icon, locating GoLogger.gd, and restarting Godot.
* You are ready to use the plugin and start adding "Log.entry()" calls to your code. If you plan on exanding on this system and build upon it. I recommend going through the additional steps below but you can skip it. 
	
### **Additional Setup** - For those intending to further improve and customize the system:
In order for static functions to have access to variables and signals, they are required to be in an autoload script and as such, one was added to the plugin called `GoLogger.gd`. This autoload only contains 8 lines of code which can and **should** be be merged into one of your existing autoloads. 
1. Copy the code below and put it into any of your existing autoload scripts. Then delete GoLogger.gd:

*It is REQUIRED to be an autoload! If your existing autoload already has a _ready() function declared, simply add the two _ready() lines from the code below inside your existing _ready() function.*

	signal toggle_session_status(category : int, status : bool) ## Session Status is changed whenever a session is started or stopped.
	signal session_status_changed ## Emitted after session status is changed. Not used by the plugin but can be useful if you plan on expanding the system. 
	var game_session_status: bool = false ## Flags whether a log session is in progress or not. 
	var ui_session_status: bool = false ## Flags whether a log session is in progress or not. 
	var player_session_status: bool = false ## Flags whether a log session is in progress or not. 
	var log_in_devfile : bool = true ## Flags whether or not logs are saved using the [param FILE](false) or [param DEVFILE](true).
	
	func _ready() -> void:
		toggle_session_status.connect(_on_toggle_session_status)
		Log.start_session(0)
		Log.start_session(1)
		Log.start_session(2)
	## Toggles the session status between true/false upon signal [signal GoLogger.toggle_session_status] emitting. 
	func _on_toggle_session_status(category : int, status : bool) -> void:
		match category:
			0: game_session_status = status
			1: ui_session_status = status
			2: player_session_status = status
		session_status_changed.emit()
  
3. In Log.gd, use "Find and Replace" to update any code referencing the deleted `GoLogger` autoload with your own updated one.
	*Note: The example scene script also references the GoLogger.gd script, so this will break the example scene. However, you can fix this by using "Find and Replace" in the example script "main.gd" as well. This doesn't affect the logging system itself, but if you try to open scene "main.tscn" after completing these steps, you may encounter a series of errors.*
*4. Optional:* At this point, you can delete plugin.gd and plugin.cfg and use the scripts as your own. Building upon this plugin and making it your own is not only encouraged, it was made for it.<br><br><br>


##How to use:
**Creating log entries:**<br>
Simply installing this plugin is not enough to for log entries to appear in the log files when you run your game. You still need to manually add log entries and specify the data each entry should display (if necessary). Fortunately, adding entries is as easy as writing `print()` calls, done with a single line of code:

	Log.entry(0, "Your entry string here")
The `entry()` function has some mandatory and optional parameters. `entry(category : int, log_entry : String, date_time_flag : int = 0, utc : bool = true, space : bool = true)`. Only the first two are mandatory and needs to be declared when called while the rest are optional and allow you to customize the log to your liking.
1. `category` - This denotes which log file the entry will be stored in. 0 = "game.log", 2 = "ui.log", 3 = "player.log".
2. `entry` - This is the string that makes up your entry. Data can be added as long as it is able to be converted to a string.
3. `date_time_flag` - Flags whether to include either date, time or none of the two in your log entries. 0 = date + time, 1 = date, 2 = time, 3 = none.
4. `utc` - UTC is the date and time format used. If you call this will false. The date and time will adhere to the users local date and time format. [More info can be found in the doc page.](https://docs.godotengine.org/en/stable/classes/class_time.html#class-time-method-get-datetime-string-from-system)
5. `space` - This separates the date and time with a space if true. False will put a T instead of a space. Which will look like [2024-09-10T12.42:09].

You can call function this from any script in your project. The string message can contain almost any data, but you may need to convert that data into a string format using str(). For example:

 	Log.entry(str("Player died at position", player.position, ".")		# Result: [2024-09-10 12:42:09] Player died at position(531, 82).

Godot allows you to format the strings in many ways. [See this documentation page for more information](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html) 


**Modifying the files:**
The files that are logged when first installing the plugin are "game.log", "ui.log and "player.log". These are just examples of what you can log and how to sort then. You can easily change the name of them, plus, you decide where entry's are logged in your `Log.entry()` calls regardless. In order to change them, there are a couple of steps to do it safely without breaking anything and for the purposes of this example. We'll change the "ui.log" file to instead be an "npc.log" file where one might log events pertaining to NPCs and their pathfinding:

**In "Log.gd":**
* At the top of the script. Change `const UI_FILE = "user://logs/ui.log"` to `const NPC_FILE = "user://logs/npc.log"`
* Press `Search > Replace` in the script editor and use it to replace following:
  	"UI_FILE" > "NPC_FILE"
   	"_fui" > "_fnpc"
   	"_flui" > "_flnpc"
* *Optional* Use `Search > Find` and find occurances of "ui" in the comments/documentation and change them appropriately.

**In "GoLogger.gd" OR the autoload you integrated the "GoLogger" code into:**
* Change variable `ui_session_status` to `npc_session_status`.
  
* *optional* Select `Project > Open User Data folder` and navigate inside the "logs" folder. If you've ran your game one, the "ui.log" file was created so we can now delete it.

If you want to remove files and just use 2 or one. The code is fairly clear on separating codeblocks in charge of handlings each file. Just delete whichever file you want.
Similarly, if you want to add. You can just duplicate the same codeblocks, to expand the number of files/categories.


**How to stop and start sessions at runtime:**<br>
Because this plugin runs completely in the background, there's no built-in way to start, stop and restart sessions if you need to. However, this is easy to achieve since we can also access the `Log.start_sessiion()` and `Log.stop_session()` functions from anywhere in your project, much like the `Log.entry()`. Just call them using "Log." prefix. If you have a developer console or menu, just call these two function for your console command or button signals. 
<br><br><br>

### Examples:
Here are some examples I use in my code for my save system and inventory.
![SaveSystem](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example1.png)
![Inventory1](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example2.png)
![Inventory2](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example3.png)
![Log file contents](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example4.png)



