# ![GoLogger.svg](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/GoLogger.svg) GoLogger
 A basic logging system for game events in into a .log file for Godot 4.

## Introduction
 Have you found yourself working on either several new features/systems or a big one involving several scripts where you've added a ton of print statements in order to debug. Littering the Output, making the info hard to decipher and even harder to manage? Maybe you want to your game to record events to help you debug issues your players are facing where you can't access their instance. Then you might want to look into creating a way for your game to log events in your game in order to provide a sort or snapshot of the history of events led to a bug or crash.

 This is a basic logging system meant to serve as a base for you to build upon and as such, is very barebones by design. That also means it's very flexible and scalable. With some minor changes, you can make it categorize events into separate files. The system can log whatever game event and/or data in a .log file but it won't magically generate log entries for you, meaning you will need to add 'GameLog.log()' calls to your code for it to actually log anything. <u>This system is only as comprehensive and complicated as you make it</u>.

## .log files
 The system in it's current state uses two possible log files. A "DEVFILE" created/located in the project file under "res://GameLog/game.log" which is meant to be used during development because it's easily accessible. While the "FILE" is the one intended for use for release, located in "user://logs/game.log" amongst the other log files Godot generates. The idea being that when a player encounters a bug or crash and they want to report it to the developer(you), you can ask them to include the log file to hopefully give you some insights as to what led to the issue.


## Installation and setup:
Download either on GitHub(!https://github.com/Burloe/GoLogger) or through the Asset Library. After importing it into your project, some files are added which are not strictly necessary that are added for the sake of making the installation simplified. But I highly recommend doing the complicated installation because it will be easier to manage and build upon the system if that's what you're looking for.
### Simple setup:
1. Find the "Log.gd" file in the addon folder and specify the desired location of the log inside your project by altering this line:
   
   `const DEVFILE = "res://GoLogger/game.log"` 
3. In order to swap between saving logs in the project file and the User Data folder. You find the "GoLogger.gd" in the addons folder and set `log_in_devfile` to `false` in order to save logs in User Data and `true` to save logs in your project. 
4. The plugin will add a new autoload script called GoLogger to your project. This handles autoload only handles telling the plugin whether or not it's currently logging by using a signal and the setting which handles the log location(see step 2). Everything involved with the actual logging is handled in the `Log.gd` script. 
	
### Elaborate setup:
In order to make this an easy installation to quickly get the plugin running with as little setup as possible, additional scripts were required. They are GoLogger.gd, plugin.gd and plugin.cfg. Only GoLogger is required but can be easily merged into one of your existing autoloads. It's required to be an autoload due to the nature of static functions. How to do that:
1. Copy the code below and put it into any of your existing autoload scripts.  Then delete GoLogger.gd:
NoteIt REQUIRES TO BE IN AN AUTOLOAD!
 	signal session_status_changed(status : bool) ## Session Status is changed whenever a session is started or stopped.
	var session_status: bool = false ## Flags whether a log session is in progress or not. 
	var log_in_devfile : bool = true ## Flags whether or not logs are saved using the [param FILE](false) or [param DEVFILE](true).
	
	func _ready() -> void:
		session_status_changed.connect(_on_session_status_changed) 
		Log.start_session() # Begins the logging seesion
	
	func _on_session_status_changed(status : bool) -> void:
		session_status = status` [/codeblock]
 
1. In Log.gd, use Find and Replace to replace any code referencing GoLogger with your own autoload.
	2(sidenote). The example scene script also references the GoLogger.gd script so this will break that but you can just use Find and Replace there too and it's fixed. That has no bearing on the logging system since that's just example/showcase of what the plugin does.
2. Optional! At this point, you can delete the plugin.gd and plugin.cfg and use the scripts as is. 


## How to use:
Simply installing this plugin wont magically generate log entries when you run your game. You still need to do that and specify what data each entry displays(if that's what you want. <u>Entries are as simple or detailed as you make them</u>. However, doing that is very easy thanks to this plugin and is done with one line of code with `Log.entry("Your entry string here")` and you can call it from any script in your project. The string message can contain almost any data you want to add. Just know that you probably need to convert the data to a string format which can be done with `str()`. Example of a use case `Log.entry(str("Picked up item[", item_name, "] x", item_amount, "."))`.

Here are some examples I use in my code for my save system and inventory.
![SaveSystem](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/Example/Example1.png)
![Inventory](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/Example/Example2.png)
![Inventory](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/Example/Example3.png)
