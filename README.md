# ![GoLogger.svg](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/GoLogger.svg) GoLogger
A basic framework for logging game events in into one or more external .log file for Godot 4. GoLogger was designed to easily be able to slot into any project with minimal setup so you can start logging quickly.<br>Creating logging entries are as easy as writing a `print()` call!
 
https://github.com/user-attachments/assets/f8b55481-cd32-4be3-9e06-df4368d1183c

<br><br>
## Introduction
Have you ever found yourself working on multiple new features or a large system involving numerous scripts, adding countless print statements to debug? This can clutter the output, making the information difficult to decipher and even harder to manage. Or perhaps you want your game to record events to help debug issues that your players may encounter. In that case, having a logging system in the background that records game events into external .log files could provide helpful a snapshot of the events leading up to a bug or crash that users can access and share.

GoLogger was designed as a foundation for you to build upon. As such, it is intentionally minimalistic, making it flexible and scalable. Log entries can contain any message and data(as long as it can be converted into a string). However, simply installing this plugin won’t automatically generate log entries out of the bo, but adding these log entries to your code is as easy as writing a print() statement:
	
 	Log.entry("Your log entry message.", 0)	# Result: [2024-04-04 14:44:44] Your log entry message.

**Note: This system is only as comprehensive and detailed as you make it.** But it also works as a simple standalone logging system as is.<br><br><br>

### .log files:
GoLogger will create and manage up to three .log files by default(limit can be changed) for two category of logs, named 'game.log' and 'player.log'. Two file categories was included to showcase how and what's required to add additional files. Modifying the plugin to have more or less files or use different file names is a simple process and steps are detailed in "Modifying the log names, adding or removing the number of logs" paragraph of the "How to Use" section. Note that the "game" and "player" logs are just suggestions of names and a way to categorize/separate logs into multiple files. If you just want to consolidate all logs into one file, you don't need to change anything. Calling `Log.entry("Your log entry here", 0)` and only using 0 as the second param will always log into "game.log" file, effectively achieving the same result.

The .log files are located in the User Data folder can be accessed through `Project > Open User Data Folder` and opening the "game_Gologs" and "player_Gologs" folder. This folder location is different on every OS. Because they are stored externally from the project, your players/users can therefore access these logs files and can share them when investigating bugs and issues.

### Settings & GoLogger Controller :
GoLogger had optional settings that change the way it behaves which all are located on the "GoLogger.tscn" or its script if you intend to change the default values. Documentation has been added to the entire scripts, including the export variables to describe what they do. 
The plugin comes with a "controller" which is why we autoload the scene rather than the script. This affords us the option to make changes in the inspector using the export variables too. The controller allows you to stop and start sessions, print log contents, shows the character count and the session timer during gameplay and can be shown/hidden using F9.


## Managing .log file size:
There's one potential problem one should be mindful of when loading and storing data. In order to write log entries into an external file, `FileAccess.open(file, FileAccess.WRITE)` is used which truncates the file every time. In short terms, first store the old entries before the file is truncated. Adding the old entries before adding the new entry. Meaning we load and unload potentially very large strings which are prone to performance issues if the file gets excessively long and may cause memory leaks. To combat this issue, two methods of managing the file size w added to GoLogger. <br>
**Entry count limit:** *(Recommended)* In the Gologger inspector(and script), `entry count limit` sets the max number of lines allowed in any one file. When starting a new session, the log entries are added until they hit the limit. Afterwards, the oldest entry will be removed when adding a new one.
**Session Timer:** A timer is started in tandem with the session. Upon timeout, the session will stop and restart by default. The action taken upon timeout can be changed with `session_timeout_action` which allows you to either stop and start a session or just stop. Note that the session needs to be started manually using the GoLoggerController or if you've added some option yourself. 

You can choose to use Entry count limit, Session Timer, both or none using `log_manage_method`. It is **Highly Recommended** that you use one or both of these options, especially if you intend on using GoLogger in your released product. Objectively speaking, Entry Count Limit is the better solution and should be used. However, Session Timer has uses for other purposes. If you want to stress test a certain feature during a specific time, only logging entries during a set time can be helpful. Regardless. If you experience performance issue and suspect GoLogger to be the cause. Consider using one or both of these options. <br><br><br> 

## Installation and setup:
GoLogger requires an autoload to manage a signal and a few variables since static functions can't use variables otherwise, which the plugin adds automatically upon installation. However, this isn't always a reliable process and therefore **it is crucial that you ensure the "GoLogger.tscn" was added properly for the plugin to work.**

### **Installation:**
* Download the plugin from either GitHub(!https://github.com/Burloe/GoLogger) or the Asset Library. If you download the .zip from GitHub, extract **only** the "addons" folder to any folder in your PC, then place the extracted "addons" folder into your project's root directory. The folder structure should look like `res://addons/GoLogger`. 
* Navigate to `Project > Project Settings > Plugins`, where you should see "GoLogger" as an unchecked entry in the list of installed plugins. Check it to activate the plugin.
* Go to `Project > Project Settings > Globals > Autoload` and ensure that the GoLogger autoload has been added correctly. If not, you can manually add it by clicking the folder icon, locating GoLogger.gd, and restarting Godot.
* *Optional but recommended:* Add `Log.stop_session()` in whatever function that triggers your game to close with `get_tree().quit()`. Frankly, this is purely for the aesthetics, closing without stopping won't break the plugin.
* *Optional:* The autoload "GoLogger.tscn" has the option to enable "autostart session". This will start the session in the _ready() method and works well. Disabling it means you have to use the GoLoggerController to manually start the session, or you need to add some way to call `start_session()` in your code.<br><br><br>



## How to use GoLogger:<br>
### **Where can I access options and settings:** <br>
All export variables containing the settings and options are located in the "GoLogger.tscn". To change the default values for these settings, you can find those in the "GoLogger.gd" script.

### **Stopping and starting log sessions:**<br>
This plugin uses sessions to indicate when its logging entries or not and new .log file are created with each session. Starting and stopping sessions are as simple as calling `start_session()` and `stop_session()` If you intend on starting and stopping during gameplay. It is recommended that you add a 'cooldown' of at least 1 second before starting the next session. You can find an example of how this can be implemented in GoLoggerController.gd within the `_on_session_button_toggled()` signal receiver. The reason for this is to prevent the possibility from two or more sessions to be created within the same second timestamp which causes some reliability issues when sorting the files to identify the oldest file.<br><br><br>


### **Creating log entries and include data:**<br>
Simply installing GoLogger will not generate any log entries for your project. You still need to add `Log.entry()` calls to your code, add a string message to the entry and data is included in the entry. Any data that can be converted into a string is able to be added into an entry(which can be done using `str()`. Be mindful though that converting to string might not format the data into a human legible format. Here's a simple example of how to create a log entry with some formatting to make it more legible. 

	func _on_damage_taken(entity: CharacterBody2D, damage : float):
		current_health -= damage
 		if current_health <= 0:
			death()
  			Log.entry(str("Player died @", get_position(), " by the hands of ", entity.get_name(), ". Final blow dealt ", damage, " damage.")
     			# Resulting log entry:  [21:42:18] Player died @(918, 2103) at the hand of Swamp Monster. Final blow dealt 68 damage. 

The `entry()` function has one mandatory and optional parameters: `entry(category : int, log_entry : String, date_time_flag : int = 0, utc : bool = true, space : bool = true)`
Only the first parameter mandatory and needs to be defined when calling the function while the rest are optional and allow you to customize the formatting of your log entry to your liking.
1. `entry` - *Mandatory* -This is the string that makes up your entry. Data can be added as long as it is able to be converted to a string.
2. `category` - *Optional* - This denotes which log file the entry will be stored in. 0 = "game.log", 2 = "player.log". Not specifying the file will make it log into "game.log" by default.
3. `include_timestamp` - *Optional* -  Flags whether to include time or not. Log entries are always added sequentially so timestamps just helps you to measure the time between events.
4. `utc` - *Optional* -  UTC is the standardized date and time format used. Using false, the timestamp will adhere to the users local time format. [More info can be found in the doc page.](https://docs.godotengine.org/en/stable/classes/class_time.html#class-time-method-get-time-string-from-system)

You can call function this from any script in your project. The string message can contain almost any data, but you may need to convert that data into a string format using str(). Godot allows you to format the strings in many ways. [See this documentation page for more information](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html) <br><br><br>


### **Modifying log names, adding or removing the number of log files:**
A game.log and player.log file are created upon running your project the first time. Every time a session is stopped and started, a new file is created. Using the file cap option, its possible to prevent the number of files in the directories at any one time. It's recommended to keep this at around the 1-6 range.
Changing the name of the files and directories are not hard but can be tedious which is why I plan on making a tutorial on the subject(either text based or video). The "player.log" file was added to showcase how and what is required to add more files and directories. **Be aware** that changing the files will certainly break the controller and will require code and scene changes to accommodate your changes. There are however helper functions to make this process easier. 
 <br><br><br>

### **How can I save a specific .log file from being deleted:**
If you encountered an issue and need to keep the .log file from being deleted is very simple. Just create a copy and/or move the file out of the original folder.

## **Future development:**
I will address bugs and issues as they come to my attention. Please report issues on GitHub if you encounter them. I will also update the plugin for the latest Godot Version.
Currently, all features I had the goal of implementing has been added. The plugin was designed to be minimalistic intentionally in order for it to easily be slotted into any project. Adding major features to change this would be in conflict of this goal. I *currently* have no plans to add any major features or increase the scope, merely because I(personally) don't have the need for more features but that might change in the future(especially if people request features that are reasonable). 

## Examples:
Here are some examples I use in my code for my save system and inventory.
![SaveSystem](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example1.png)
![Inventory1](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example2.png)
![Inventory2](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example3.png)
![Log file contents](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example4.png)



### Future development of GoLogger:
Currently, all the features I
