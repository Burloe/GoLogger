# ![GoLogger.svg](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/GoLogger.svg) GoLogger
A basic framework for logging game events in into one or more external .log file for Godot 4. GoLogger was designed to easily be able to slot into any project with minimal setup so you can start logging quickly.<br>Creating logging entries are as easy as writing a `print()` call!
 
https://github.com/user-attachments/assets/f8b55481-cd32-4be3-9e06-df4368d1183c

<br><br>
## Introduction
Have you ever found yourself working on multiple new features or a large system involving numerous scripts, adding countless print statements to debug? This can clutter the output, making the information difficult to decipher and even harder to manage. Or perhaps you want your game to record events to help debug issues that your players may encounter. In that case, having a logging system in the background to record game events into external files could provide helpful a snapshot of the events leading up to a bug or crash that users can access and share.

GoLogger was designed as a foundation for you to build upon. As such, it is intentionally minimalistic, making it flexible and scalable. Log entries can contain any message and data(as long as it can be converted into a string). However, simply installing this plugin won’t automatically generate log entries out of the bo, but adding these log entries to your code is as easy as writing a print() statement:
	
 	Log.entry(0, "Your log entry message.")	# Result: [2024-04-04 14:04:44] Your log entry message.

**Note: This system is only as comprehensive and detailed as you make it.** But it also works as a simple standalone logging system as is.<br><br><br>

### .log files:
GoLogger will create and manage up to three .log files(file limit can be changed) for two category of logs, named 'game.log' and 'player.log'. Modifying the plugin to use different file names is a simple process and steps are detailed in "Modifying the log names, adding or removing the number of logs" paragraph of the "How to Use" section. Note that the "game" and "player" logs are just suggestions of names and a way to categorize/separate logs into multiple files. If you just want to consolidate all logs into one file, you don't need to change anything. You can just call `Log.entry(0, "Your log entry here")` and it'll always log into the "game.log" file.

The .log files are located in the User Data folder can be accessed through `Project > Open User Data Folder` and opening the "game_Gologs" and "player_Gologs" folder. This folder location is different on every OS. Because they are stored externally from the project, your players/users can therefore access these logs files and can share them when investigating bugs and issues.

### GoLogger Controller:
The plugin comes with a "controller" which is why we autoload the scene rather than the script. This affords us the option to make changes in the inspector using the export variables too. The controller allows you to stop and start sessions, print log contents, shows the character count and the session timer during gameplay and can be shown/hidden using F9.


## Options for automatic stopping and starting of logging sessions:
There's one potential problem one should be mindful of performing operations to load and store data as done here. In order to write log entries into an external file, `FileAccess.open(file, FileAccess.WRITE)` is used which truncates the file every time. In short terms, we need to load and store the old log entries into a variable everytime we log a new entry. Meaning we load and unload potentially very large strings which are prone to performance issues if the file gets excessively long and may cause memory leaks. 

To combat this issue, an optional `end_session_condition` along with `end_session_action` was added in order to prevent any .log file from becoming too large. There are three possible conditions to use which perform the action once fullfilled. 
**Conditions:**
a) When we READ and store the old entries, a check to see if the character count exceeds a predefined character limit. 
b) When a session is started, a 2 minute timer start(time can be changed). 
c) Third option uses both of them, meaning the timer will stop and start every 2 minutes AND the character count is checked upon each entry. 
**Actions:**
a) **Stop & Start Session**. 
b) **Stop only**. Stops a session WITHOUT starting a new one, requiring either a manual start or if you have added some automatic trigger yourself. 
c) **Clear**. Simply purges the file contents and continues to log in the same file. 

If you are experiencing performance issues like micro-stutters, lags or freezes and you suspect it's due to GoLogger. You can turn these options on in the GoLogger.tscn scene in the inspector(they are exported variables).
### I HIGHLY RECOMMEND using one or both of these `end_session_condition`s if you intend to include GoLogger in your released game!<br><br><br>


## Installation and setup:
GoLogger requires an autoload to manage a signal and a few variables since static functions can't use variables otherwise which the plugin adds automatically upon installation. However, this isn't always a reliable process and therefore **it is crucial that you ensure the "GoLogger.tscn" was added properly for the plugin to work.**

### **Installation:**
* Download the plugin from either GitHub(!https://github.com/Burloe/GoLogger) or the Asset Library. If you download the .zip from GitHub, extract **only** the "addons" folder to any folder in your PC, then place the extracted "addons" folder into your project's root directory. The folder structure should look like `res://addons/GoLogger`. 
* Navigate to `Project > Project Settings > Plugins`, where you should see "GoLogger" as an unchecked entry in the list of installed plugins. Check it to activate the plugin.
* Go to `Project > Project Settings > Globals > Autoload` and ensure that the GoLogger autoload has been added correctly. If not, you can manually add it by clicking the folder icon, locating GoLogger.gd, and restarting Godot.
* *Optional but recommended:* Add `Log.stop_session()` in whatever function that triggers your game to close with `get_tree().quit()`. Frankly, this is purely for the aesthetics, closing without stopping won't break the plugin.
* *Optional:* The autoload "GoLogger.tscn" has the option to enable "autostart session". This will start the session in the _ready() method and works well. Disabling it means you have to use the GoLoggerController to manually start the session, or you need to add some way to call `start_session()` in your code.<br><br><br>



## How to use:<br>
### **How to start and stop log sessions:**<br>
This plugin uses sessions to indicate when its logging entries or not but will also create a new .log file with each session. Starting and stopping sessions are as simple as calling `start_session()` and `stop_session()` If you intend on starting and stopping during gameplay. It is recommended that you add a 'cooldown' of at least 1 second before starting the next session. You can find an example of how this can be implemented in GoLoggerController.gd within the `_on_session_button_toggled()` signal receiver.<br><br><br>


### **How to create log entries and include data:**<br>
Simply installing GoLogger doesn't generate any log entries for your project. You still need to write out when and where logs are entered and what message + data is included in the entry. However, doing so is just as easy as writing a `print()` statement. For this example, lets say we want to log when the player dies, the position of the player, what dealt the killing blow and for how much damage the blow inflicted. Additionally, we assume there's a signal that sends the amount of damage dealt and the entity that dealt it to the Player script in which we want to log an entry.

	func _on_damage_taken(entity: CharacterBody2D, damage : float):
		current_health -= damage
 		if current_health <= 0:
			death()
  			Log.entry(str("Player died @", position, " by the hands of ", entity.get_name(), ". Final blow dealt ", damage, " damage.")
     			# Resulting log entry:  [21:42:18] Player died @(918, 2103) at the hand of Swamp Monster. Final blow dealt 68 damage. 

The `entry()` function has some mandatory and optional parameters. `entry(category : int, log_entry : String, date_time_flag : int = 0, utc : bool = true, space : bool = true)`. Only the first two are mandatory and needs to be defined when calling the function while the rest are optional and allow you to customize the log to your liking.
1. `category` - This denotes which log file the entry will be stored in. 0 = "game.log", 2 = "ui.log", 3 = "player.log".
2. `entry` - This is the string that makes up your entry. Data can be added as long as it is able to be converted to a string.
3. `include_timestamp` - Flags whether to include time or not. Log entries are always added sequentially so timestamps just helps you to measure the time between events.
4. `utc` - UTC is the standardized date and time format used. Using false, the timestamp will adhere to the users local time format. [More info can be found in the doc page.](https://docs.godotengine.org/en/stable/classes/class_time.html#class-time-method-get-time-string-from-system)

You can call function this from any script in your project. The string message can contain almost any data, but you may need to convert that data into a string format using str(). Godot allows you to format the strings in many ways. [See this documentation page for more information](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html) <br><br><br>


### **Modifying the log names, adding or removing the number of logs:**
A game.log and player.log file are created upon running your project the first time. Every time a session is stopped and started, a new file is created. Using the file cap option, its possible to how many files you want to keep in the directories at any one time. It's recommended to keep this at around the 1-6 range.
Changing the name of the files and directories are not hard but can be tedious which is why I plan on making a tutorial on the subject(either text based or video). The "player.log" file was added to showcase how and what is required to add more files and directories. **Be aware** that changing the files will certainly break the controller and will require code and scene changes to accommodate your changes. There are however helper functions to make this process easier. 
 <br><br><br>


### Examples:
Here are some examples I use in my code for my save system and inventory.
![SaveSystem](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example1.png)
![Inventory1](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example2.png)
![Inventory2](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example3.png)
![Log file contents](https://github.com/Burloe/GoLogger/blob/main/Showcase/Example4.png)



