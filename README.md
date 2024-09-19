# ![GoLogger.svg](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/GoLoggerIcon.png) GoLogger
A basic framework for logging game events and data into one or more external .log file for Godot 4. GoLogger was designed to easily be able to slot into any project with minimal setup so you can start logging quickly. Creating logging entries are as easy as writing `print()` calls.<br>
GoLogger runs in the background but comes with a controller(that you can toggle with F9) which provides information and controls of the current log session.
 
https://github.com/user-attachments/assets/f8b55481-cd32-4be3-9e06-df4368d1183c

## Introduction
Have you ever found yourself working on multiple new features or a large system involving numerous scripts, adding countless print statements to debug? This can clutter the output, making the information difficult to decipher and even harder to manage. Or perhaps you want your game to record events to help debug issues that your players may encounter. In that case, having a logging system in the background that records game events into external .log files could provide helpful a snapshot of the events leading up to a bug or crash that users can access and share.

GoLogger was designed as a foundation for you to build upon. As such, it is intentionally minimalistic, making it flexible and scalable. Log entries can contain any message and data(as long as it can be converted into a string). However, simply installing this plugin won’t automatically generate log entries out of the bo, but adding these log entries to your code is as easy as writing a print() statement:
	
 	Log.entry("Your log entry message.", 0)	     # Result: [14:44:44] Your log entry message.

**Note: GoLogger is as comprehensive as you make it.** However, it also works as a simple standalone logging system as is.<br><br><br>

## Installation and setup:
![Errors](https://github.com/Burloe/GoLogger/blob/main/Showcase/InstallErrors.png)<br>
**Godot will print a ton of these errors when first installing the plugin. This is expected!** <br>
Do not worry! GoLogger simply requires an autoload to work which isn't added until you've enabled the plugin. There are only two steps to install the plugin correctly.
* **Importing it into your project:** Only import the "addons" into your root folder. The folder structure should look like `res://addons/GoLogger`. 
* **Enabling the plugin:** Navigate to `Project > Project Settings > Plugins`, where you should see "GoLogger" as an unchecked entry in the list of available plugins. Check it to enable the plugin. *If you still get the errors, make sure "GoLogger.tscn" was added as an autoload.*

You're all set! You can navigate to and open `res://addons/GoLogger/GoLogger.tscn"` where you'll see all the options of the plugin in the inspector. I recommend that you add `Log.stop_session()` in the function that calls `get_tree().quit()` and put it above the quit() call. Frankly, closing your game without stopping won't break the plugin or the .log file but can be used to indicate if the game was closed, force closed or crashed.<br><br><br>

## **How it works:**
The .log files created by the plugin are located in the User Data folder and can be accessed through `Project > Open User Data Folder`. Inside the "logs" folder, there are two folders named "game_Gologs" and "player_Gologs". This folder location is different on every OS. Because they are stored externally from the project, your players/users can therefore access these logs files and can share them when investigating bugs and issues. The directory can be changed.
GoLogger will create and manage two .log files by default(can be changed) for two category of logs, named 'game.log' and 'player.log'. Two file categories was included to showcase how and what's required to add additional files. Modifying the plugin to have more or less files or use different file names is a simple process and steps are detailed in "Modifying the log names, adding or removing the number of logs" paragraph of the "How to Use" section. Note that the "game" and "player" logs are just suggestions of names and a way to categorize/separate logs into multiple files. If you just want to consolidate all logs into one file, you don't need to change anything. Calling `Log.entry("Your log entry here")` without any secondary parameter will always log into "game.log" file, effectively achieving the same result.<br><br>


### Settings & GoLogger Controller :
GoLogger has optional settings that change the way it behaves which all are located on the "GoLogger.tscn" or its script if you intend to change the default values. Documentation has been added to the entire scripts, including the export variables to describe what they do. Meaning you can hover over options in the inspector and you can use "Search Help" to find documentation pages for the scripts.
The plugin comes with a "controller" which is why we autoload the scene rather than the script. This affords us the option to make changes in the inspector using the export variables too. The controller allows you to stop and start sessions, print log contents, shows the character count and the session timer during gameplay and can be shown/hidden using F9.<br><br>


## Managing .log file size:
There's one potential problem one should be mindful of when loading and storing ever increasing data. In order to write log entries into an external file, `FileAccess.WRITE` is used which truncates the file every time. In short terms, first store the old entries before the file is truncated. Adding the old entries before adding the new entry. Meaning we load and unload potentially very large strings which are prone to performance issues if the file gets excessively long and may cause memory leaks. To combat this issue, two methods of managing the file size was added to GoLogger. <br>
#### **Entry count limit** *(Recommended)*:
 In the Gologger inspector(and script), `entry_count_limit` sets the max number of lines allowed in any one file. When starting a new session, the log entries are added until they hit the limit. Afterwards, the oldest entry will be removed when adding a new one. This is a very reliable method which simply keeps the files from becoming too long.<br>
#### **Session Timer:** 
A timer is started in tandem with the session. Upon timeout, the session will stop and restart by default. The action taken upon timeout can be changed with `session_timeout_action` which allows you to either stop and start a session or just stop. This method can be reliable but is inherently flawed. If you had several systems logging several entries continually, it has the potential of writing large files. However, there are use cases for such a timer outside of file size management which is why it was included. I found that stress testing a system for short bursts was helpful to setup to sync with the session timer(which is why there's a `session_timer_started` signal).<br>
*Note using "Stop session only" requires a new session to be started manually using GoLoggerController or if you've added a `start_session()` trigger in your code yourself.* <br><br>

You can choose to use Entry count limit, Session Timer, both or none using `log_manage_method`. It is **Highly Recommended** that you use one or both of these options, especially if you intend on using GoLogger in your released product. Objectively speaking, Entry Count Limit is the better solution and should be used but it's always good to have options. Regardless, if you experience performance issue and suspect GoLogger to be the cause. Consider using one or both of these options and setting the entry limit to something smaller and decrease the wait time on the session timer. <br><br><br> 


## How to use GoLogger:<br>
### **Where can I access options and settings:** <br>
All export variables containing the settings and options are located in the "GoLogger.tscn". To change the default values for these settings, you can find those in the "GoLogger.gd" script.<br><br>

### **Stopping and starting log sessions:**<br>
This plugin uses sessions to indicate when its logging entries or not and new .log files are created with each session. Starting and stopping sessions are as simple as calling `start_session()` and `stop_session()` If you intend on starting and stopping during gameplay. It is recommended that you add a 'cooldown' of at least 1 second before starting the next session. You can find an example of how this can be implemented in GoLoggerController.gd within the `_on_session_button_toggled()` signal receiver. The reason for this is to prevent the possibility from two or more sessions to be created within the same second timestamp which causes some reliability issues when sorting the files to identify the oldest file.<br><br>

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

You can call function this from any script in your project. The string message can contain almost any data, but you may need to convert that data into a string format using str(). Godot allows you to format the strings in many ways. [See this documentation page for more information](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html) <br><br>


### **Modifying log names, adding or removing the number of log files:**
A game.log and player.log file are created upon running your project the first time. Every time a session is stopped and started, a new file is created. Using the file cap option, its possible to prevent the number of files in the directories at any one time. It's recommended to keep this at around the 1-6 range.
Changing the name of the files and directories are not hard but can be tedious which is why I plan on making a tutorial on the subject(either text based or video). The "player.log" file was added to showcase how and what is required to add more files and directories. **Be aware** that changing the default files will certainly break the controller and will require code and scene changes to accommodate your changes. There are however helper functions to make this process easier and shouldn't be difficult to add the required buttons and labels for your changes. A step-by-step tutorial will be made on how to add files, adding the controller elements to include the new files as well as how and what is required to connect the proper signals for it all to work. <br><br>

### **How can I save a specific .log file from being deleted:**
If you encountered an issue and need to keep the .log file from being deleted is very simple. Just create a copy and/or move the file out of the original folder.<br><br>

### **Questions regarding the plugin, it's use or installation:**
Questions can be submitted to the GitHub repo. Click the issue tab and 'New issue', then select "Question About GoLogger" to submit any questions you might have.<br><br>

## **Future development:**
GoLogger will be updated to the latest version of Godot. Currently, it supports version 4.0 and above with no plans to support 3.x. 
Currently, all planned features have been added to the plugin. While it could be further improved and have added customization and formatting, that's beyond the scope of the plugin. The intention is for every user to add to and customize GoLogger for your purposes and project. It's kept simple with some added quality of life options in order for the plugin to easily be added and used with any project. Feature requests are accepted and will always be considered but if a request comes in that doesn't aligns with this "vision" of the plugin, it will most likely not be added. <br>
Feedback and bug reports are taken seriously and should be submitted through Github <br><br><br>

## **Credit and permissions**
This is a completely free plugin. No monetary contributions are accepted and no credit is necessary. This plugin was designed to be customized by the you to fit your projects, be expanded and improved. You are not required to ask for permission or credit the author or the plugin to use it in your commercial or non-commercial product. 
