# ![GoLogger.svg](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/GoLoggerIcon.png) GoLogger
GoLogger is a simple framework for logging game events and data to external .log files in Godot 4. Designed for easy integration, GoLogger requires minimal setup, allowing you to start logging quickly. Logging entries are as straightforward as using `print()`, like `Log.entry(str("Your log entry: ", data))`.
<br><br>
GoLogger runs in the background but includes a controller(toggle with F9) for monitoring and managing the current log session.

https://github.com/user-attachments/assets/d49a569a-0702-433a-bc66-45c5253d543d

*Note: The file count limitation and deletion code was improved and works a lot better than what's seen in this video.*

## **Contents**
1. Introduction
2. Installation and setup
3. How to use GoLogger
   * Starting & Stopping Log Sessions
   * Creating log entries and include data
4. Accessing the .log files, the plugin settings and GoLoggerController
5. GoLogger Controller & Settings
6. Current issues and bugs

## Introduction
GoLogger is a standalone logging framework that creates external .log files accessible to both developers and players. It stores whatever game events and data you define with timestamps, offering a snapshot of events leading up to crashes, bugs, or issues which your players/users can share to aid in investigating issues.

Designed as a minimalistic foundation, GoLogger is flexible and scalable. Log entries can include any message or data (as long as they can be converted to strings). Although GoLogger doesn't generate log entries automatically upon installation, adding them to your code is as easy as using `print()` which you can make as simple or detailed as you decide:
	
 	Log.entry("Player picked up", item, " x", item.amount, ".")	     # Result: [14:44:44] Player picked up MedKit x3. 

## Installation and setup:
![InstallErrors](https://github.com/user-attachments/assets/8875e569-7cd3-4517-8d7c-e51412f8cafd)<br>

**Note: Godot will print several errors upon first installing the plugin and is expected!** GoLogger requires an autoload, which isn't added until the plugin is enabled.

* **Importing the plugin:** Only import the "addons" into your project's root directory. The folder structure should look like `res://addons/GoLogger`.

* **Enable the plugin:** Navigate to `Project > Project Settings > Plugins`, and check "GoLogger" in the list of available plugins to enable it.
*If errors persist, ensure "GoLogger.tscn" was added properly as an autoload and then restart Godot.*<br>

![enable_plugin](https://github.com/user-attachments/assets/f6eecd64-16ca-4158-815b-70eda5ad6fab)

* *Optional:* Intantiate the GoLoggerController into your UI. **Beware!** Currently, GoLoggerController is partially broken and will be fixed in the next update.

You're all set! It’s recommended to add `Log.stop_session()` before calling `get_tree().quit()` in your exit game function. While not stopping a session before closing the game won’t break the plugin, it’s good practice. This can help differentiate between normal exits, crashes, or forced closures, depending on whether the log file ends with "Stopped session."<br><br>


## How to use GoLogger:<br>
### **Starting & stopping log sessions:**<br>
GoLogger uses "sessions" to indicate when it’s actively logging. Each session creates a new .log file with the time- and datestamp of creation. Starting and stopping sessions is as simple as calling `Log.start_session()` and `Log.stop_session()`. If you plan to start and stop sessions during gameplay, it’s recommended to use the `start_delay` parameter with 1 or more seconds using `Log.start_session(1.2)`, which will delay the session start by 1.2 seconds. This helps prevent multiple log files from being created with the same timestamp, which can cause sorting issues. This delay is especially useful if you accidentally add session start/stop calls in multiple scripts.<br><br>


### **Creating log entries and include data:**<br>
Simply installing GoLogger will not generate any log entries. You still need to define `Log.entry()` to your code, including a string message and any data you want to log. Any data that can be converted to a string by using `str()` can be added to an entry. However, be mindful that converting to a string may not always format the data in a human-readable way. Here's an example of how to create a log entry with some formatting for readability. 

	func _on_damage_taken(entity: CharacterBody2D, damage : float):
		current_health -= damage
 		if current_health <= 0:
			death()
  			Log.entry(str("Player died @", get_position(), ", killed by ", entity.get_name(), ". Final blow dealt ", damage, " damage."), 1)
     			# Resulting log entry:  [21:42:18] Player died @(918, 2103), killed by Swamp Monster. Final blow dealt 68 damage. 

The `entry()` function has one mandatory and optional parameters: `entry(category : int, log_entry : String, date_time_flag : int = 0, utc : bool = true, space : bool = true)`
Only the first parameter mandatory and needs to be defined when calling the function while the rest are optional and allow you to customize the formatting of your log entry to your liking.
1. `log_entry` - *Mandatory* - The string that makes up your log entry. Include any data that can be converted to a string can be logged.
2. `file` - *Optional* - Specifies which log file the entry will be stored in. 0 = "game.log", 1 = "player.log". If not specified, entries will be logged to "game.log" by default.
3. `include_timestamp` - *Optional* -  Flags whether to include a timestamp with the entry inside the .log file. Log entries are always added sequentially, but timestamps help measure the time between events.
4. `utc` - *Optional* -  Uses UTC as a standardized time. Set to `false` to use the user's local system time. [More info can be found in the doc page.](https://docs.godotengine.org/en/stable/classes/class_time.html#class-time-method-get-time-string-from-system)

You can call this function from any script in your project. The string message can include almost any data, but you may need to convert that data into a string using `str()`. Godot also offers various ways to format strings. [See this documentation page for more information](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html) <br><br>

## **Accessing the .log files, the plugin settings and GoLoggerController:**
### Accessing the .log files:
The directories where the .log files are created are located in the User Data folder under `user://logs/x_Gologs/x.log`. The User Data folder location is different on every OS but can be accessed through Godot and can be accessed through `Project > Open User Data Folder`.
### Plugin settings:
To access the settings, you open "GoLogger.tscn" and find the settings in the Inspector. ![options](https://github.com/user-attachments/assets/52e7fa13-836e-4c3e-9675-1a3b3a563bdf)
### GoLogger Controller:
This plugin comes with a controller that provides information about the current session and can stop and start sessions. To use it, just instantiate it into your existing UI and you can toggle its visibility using F9. Binding can be changed in "Log.tscn". <br><br>


## Managing .log file size:
One potential pitfall to be aware of when logging large or ever-increasing amounts of data is how Godot's `FileAccess` handles writing to files. To write log entries, `FileAccess.WRITE` is used which truncates the file when used. Therefore, the plugin first stores the old entries with `FileAccess.READ`, truncates the file with `FileAccess.WRITE`, adds them back, and then appends the new entry. This can result in performance issues when files grow excessively large, as loading and unloading large strings/arrays can slow down the system. This is especially a concern during long game sessions or if multiple systems are logging to the same file. To mitigate this, GoLogger offers two methods for limiting log length:
### Entry Count Limit(recommended):
In the inspector of "Log.tscn"(where you find all plugin settings), `entry_count_limit` sets the maximum number of entries/lines allowed in a file. Once the limit is reached, the oldest entry is removed as new ones are added. This method is highly reliable for preventing files from becoming too large.
### Session Timer:
A timer starts with each session, and when it expires, the session will stop and restart by default. The `session_timeout_action` allows you to either stop the session entrirely or stop and start a new one. While this can be helpful and can be useful in certain situation, it is less reliable for file size management because it's still possible to log too many entries in a short amount of time. However, the timer can be useful for other purposes, such as stress testing. A `session_timer_started` signal is available to help sync with this timer.
*Note: If `stop_session_only` is used, you'll need to manually start a new session either via the GoLoggerController or by calling `start_session()` in your code.*
<br>
You can use Entry Count Limit, Session Timer, or both via the `log_manage_method` setting. It is highly recommended to use one or both methods, especially for released projects. Objectively, Entry Count Limit is the more efficient solution, but both options offer flexibility. If you experience performance issues and suspect GoLogger is the cause, try reducing the entry limit or shortening the session timer.





