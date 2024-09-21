# ![GoLogger.svg](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/GoLoggerIcon.png) GoLogger
A basic framework for logging game events and data into one or more external .log file for Godot 4. GoLogger was designed to easily be able to slot into any project with minimal setup so you can start logging quickly. Creating logging entries are as easy as writing `print()` calls.<br>
GoLogger runs in the background but comes with a controller(that you can toggle with F9) which provides information and controls of the current log session.

https://github.com/user-attachments/assets/d49a569a-0702-433a-bc66-45c5253d543d

*Note: The file count limitation code was improved and works a lot better than what's seen in this video.*

## **Contents**
1. Introduction
2. Installation and setup
3. How it works
   * GoLogger Controller & Settings
   * Managing .log file size
4. How to use GoLogger
   * Starting & Stopping Log Sessions
   *  Creating log entries and include data
   *  Modifying log names, adding or removing the number of log files

## Introduction
GoLogger is a standalone logging system that creates external .log files that your players/user or you can access. This plugin aims to aid in your development by storing game events with timestamps into an external file that you and your players/users can access to provide a history snapshot, a list of events leading up to a crash, bug or issue. This can replace the need for excessive use of `print()` and runs in the background.

GoLogger was designed to be used as a foundation for you to build upon. As such, it is intentionally minimalistic, making it flexible and scalable. Log entries can contain any message and data(as long as it can be converted into a string). However, simply installing this plugin won’t automatically generate log entries out of the box, but adding these log entries to your code is as easy as writing a print() statement:
	
 	Log.entry("Your log entry message.", 0)	     # Result: [14:44:44] Your log entry message.

**Note: GoLogger is as comprehensive as you make it.** However, the plugin will work as a standalone logging system as is.<br><br>

## Installation and setup:
![InstallErrors](https://github.com/user-attachments/assets/8875e569-7cd3-4517-8d7c-e51412f8cafd)<br>

**Godot will print a ton of these errors when first installing the plugin and is expected!** <br>
Do not worry. GoLogger simply requires an autoload to work which isn't added until you've enabled the plugin. There are only two steps to install the plugin correctly.
* **Importing it into your project:** Only import the "addons" into your root folder. The folder structure should look like `res://addons/GoLogger`.

* **Enabling the plugin:** Navigate to `Project > Project Settings > Plugins`, where you should see "GoLogger" as an unchecked entry in the list of available plugins. Check it to enable the plugin. *If you still get the errors, make sure "GoLogger.tscn" was added as an autoload and restart Godot.*<br>

![enable_plugin](https://github.com/user-attachments/assets/f6eecd64-16ca-4158-815b-70eda5ad6fab)

You're all set! You can navigate to and open `res://addons/GoLogger/GoLogger.tscn"` where you'll see all the options of the plugin in the inspector. I recommend that you add `Log.stop_session()` in the function that calls `get_tree().quit()` and put it above the quit() call. Frankly, closing your game without first stopping a session won't break the plugin but it's best practice to add it to your exit game function. That way, it can be used as an indication as to whether or not the game was closed due to a crash, forced close or a normal "exit game". <br><br>

## **How it works:**
The directories and .log files created by the plugin are located in the User Data folder under `user://logs/x_Gologs/x.log`. This folder location is different on every OS but can be accessed through Godot and can be accessed through `Project > Open User Data Folder`. Because they are stored externally from the project, your players/users can therefore access these logs files and can share them when investigating bugs and issues. The directory can be changed.
GoLogger will create and manage two .log files by default(can be changed) for two category of logs, named 'game.log' and 'player.log'. Two file categories was included to showcase how and what's required to add additional files. Modifying the plugin to have more or less files or use different file names is a simple process and steps are detailed in "Modifying the log names, adding or removing the number of logs" paragraph of the "How to Use" section. Note that the "game" and "player" logs are just suggestions of names and a way to categorize/separate logs into multiple files. If you just want to consolidate all logs into one file, you don't need to change anything. Calling `Log.entry("Your log entry here")` without any secondary parameter will always log into "game.log" file, effectively achieving the same result.<br><br>


### GoLogger Controller & Settings:
The plugin comes with a "controller" which is why we autoload the scene rather than the script. This affords us the option to make changes in the inspector using the export variables too. The controller allows you to stop and start sessions, print log contents, shows the character count and the session timer during gameplay and can be shown/hidden using F9.

GoLogger has optional settings that change the way it behaves which all are located on the "GoLogger.tscn" or its script if you intend to change the default values. Documentation has been added to the entire scripts, including the export variables to describe what they do. Meaning you can hover over options in the inspector and you can use "Search Help" to find documentation pages for the scripts.<br>
![options](https://github.com/user-attachments/assets/52e7fa13-836e-4c3e-9675-1a3b3a563bdf)

## Managing .log file size:
There's one potential pitfall one should be mindful of when loading and storing ever increasing data. In order to write log entries into an external file, `FileAccess.WRITE` is used which truncates the file every time. In short terms, first the old entries are stored before the file is truncated and adding the old entries before writing the new. Meaning we load and unload potentially very large strings which are prone to performance issues if the file gets excessively long and may lead to issues. To combat this, two methods of managing the file size was added to GoLogger.<br>
#### **Entry count limit** *(Recommended)*:
In the Gologger inspector(and script), `entry_count_limit` sets the max number of lines allowed in any one file. When starting a new session, the log entries are added until they hit the limit. Afterwards, the oldest entry will be removed when adding a new one. This is a very reliable method which simply keeps the files from becoming too long.
#### **Session Timer:** 
A timer is started in tandem with the session. Upon timeout, the session will stop and restart by default. The action taken upon timeout can be changed with `session_timeout_action` which allows you to either stop and start a session or just stop. This method can be reliable but is inherently flawed. If you had several systems logging several entries continually, it has the potential of writing large files. However, there are use cases for such a timer outside of file size management which is why it was included. I found that stress testing a system for short bursts was helpful to setup to sync with the session timer(which is why there's a `session_timer_started` signal).
*Note using "Stop session only" requires a new session to be started manually using GoLoggerController or if you've added a `start_session()` trigger in your code yourself.* <br>

You can choose to use Entry count limit, Session Timer, both or none using `log_manage_method`. It is **Highly Recommended** that you use one or both of these options, especially if you intend on using GoLogger in your released product. Objectively speaking, Entry Count Limit is the better solution and should be used but it's always good to have options. Regardless, if you experience performance issue and suspect GoLogger to be the cause. Consider using one or both of these options and setting the entry limit to something smaller and decrease the wait time on the session timer. <br><br>

## How to use GoLogger:<br>
### **Starting & stopping log sessions:**<br>
This plugin uses "sessions" to indicate when its logging entries or not. Each session will create and log to a brand new .log file. Starting and stopping sessions are as simple as calling `Log.start_session()` and `Log.stop_session()` If you intend on starting and stopping during gameplay. It is recommended that you add a 'cooldown' of at least 1 second before starting the next session. You can find an example of how this can be implemented in GoLoggerController.gd within the `_on_session_button_toggled()` signal receiver. The reason for this is to prevent the possibility from two or more sessions to be created within the same second timestamp which can cause some reliability issues when sorting the files to identify the oldest file.<br><br>

### **Creating log entries and include data:**<br>
Simply installing GoLogger will not generate any log entries for your project. You still need to add `Log.entry()` calls to your code, add a string message to the entry and any data you wish to include in the entry. Any data that can be converted into a string is able to be added into an entry(which can be done using `str()`). Be mindful though that converting to string might not format the data into a human legible format. Here's a simple example of how to create a log entry with some formatting to make it more legible. 

	func _on_damage_taken(entity: CharacterBody2D, damage : float):
		current_health -= damage
 		if current_health <= 0:
			death()
  			Log.entry(str("Player died @", get_position(), ", killed by ", entity.get_name(), ". Final blow dealt ", damage, " damage.", 1)
     			# Resulting log entry:  [21:42:18] Player died @(918, 2103), killed by Swamp Monster. Final blow dealt 68 damage. 

The `entry()` function has one mandatory and optional parameters: `entry(category : int, log_entry : String, date_time_flag : int = 0, utc : bool = true, space : bool = true)`
Only the first parameter mandatory and needs to be defined when calling the function while the rest are optional and allow you to customize the formatting of your log entry to your liking.
1. `entry` - *Mandatory* -This is the string that makes up your entry. Data can be added as long as it is able to be converted to a string.
2. `file` - *Optional* - This denotes which log file the entry will be stored in. 0 = "game.log", 2 = "player.log". Not specifying the file will make it log into "game.log" by default.
3. `include_timestamp` - *Optional* -  Flags whether to include time or not. Log entries are always added sequentially so timestamps just helps you to measure the time between events. The date is added to the filename.
4. `utc` - *Optional* -  UTC is a standardized date and time. Using false, the will use the user's local system time. [More info can be found in the doc page.](https://docs.godotengine.org/en/stable/classes/class_time.html#class-time-method-get-time-string-from-system)

You can call function this from any script in your project. The string message can contain almost any data, but you may need to convert that data into a string format using `str()`. Godot allows you to format the strings in many ways. [See this documentation page for more information](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html) <br><br>


### **Modifying log names, adding or removing the number of log files:**
Unique directories and a game.log and a player.log file are created upon running your project the first time. Changing the name of the files and directories is not hard but can be tedious and cause issues if you miss a typo, which is why I plan on making a tutorial on the subject(either text based or video). The "player.log" file was added to showcase how and what is required to add more files and directories. **Be aware** that changing the default files will certainly break the controller and will require code and scene changes to accommodate your changes. There are however helper functions to make this process easier and shouldn't be difficult to add the required buttons and labels for your changes. A step-by-step tutorial will be made on how to add files, adding the controller elements to include the new files as well as how and what is required to connect the proper signals for it all to work.
