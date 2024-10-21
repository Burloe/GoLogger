# ![GoLoggerTitleBase-export2x](https://github.com/user-attachments/assets/df721f9e-4d14-48bb-ae60-1fafcd03745a)
GoLogger is a simple yet flexible logging framework for Godot 4, designed to log game events and data to external .log files accessible by both developers and players. With minimal setup required, GoLogger can be integrated quickly and easily into your project. It runs in the background, capturing the data you define with timestamps, providing a snapshot of events leading up to crashes, bugs, or other issues, making it easier for users to share logs and investigate problems.


Log entries are as simple as calling `Log.entry()`(similar and as easy to use as `print()`) and can include any data that can be converted into a string. The framework is fully customizable, allowing you to log as much or as little information as needed. For convenience, GoLogger includes an optional controller (toggleable with F9) for managing the current session directly within the game.

	Log.entry("Player picked up", item, " x", item.amount, ".")	     # Result: [14:44:44] Player picked up MedKit x3. 
![Showcase](https://github.com/user-attachments/assets/68750dca-e25c-4390-a398-d1afddf65edb)


## **Contents**
1. Installation and setup
2. How to use GoLogger
   * Starting & Stopping Log Sessions
   * Creating log entries and include data
3. Accessing the .log files, the plugin settings and GoLoggerController
4. GoLogger Controller & Settings

## Installation and setup:
![Install Errors](https://github.com/user-attachments/assets/7edcdc5d-9d10-4e39-83fa-e31a9f2a49c3)<br>

**Note: Godot will print several errors upon importing the plugin and is expected!** GoLogger requires an autoload, which isn't added until the plugin is enabled.

* **Importing the plugin:** Only import the "addons" into your project's root directory. The folder structure should look like `res://addons/GoLogger`.

* **Enable the plugin:** Navigate to `Project > Project Settings > Plugins`, and check "GoLogger" in the list of available plugins to enable it.
*If errors persist, ensure "GoLogger.tscn" was added properly as an autoload and then restart Godot.*<br>

![enable_plugin](https://github.com/user-attachments/assets/6d201a57-638d-48a6-a9c0-fc8719beff37)

* *Optional:* Intantiate "GoLoggerController.tscn" into your UI. 

You're all set! Next time you run your project, folders and .log files will be created. It’s recommended to add `Log.stop_session()` before calling `get_tree().quit()` in your exit game function. While not stopping a session before closing the game won’t break the plugin, it’s good practice. This can help differentiate between normal exits, crashes, or forced closures, depending on whether the log file ends with "Stopped session."<br><br>


## How to use GoLogger:<br>
### **Starting & stopping log sessions:**<br>
GoLogger uses sessions to indicate when it’s actively logging or not, and each session creates a new .log file with the time- and datestamp of creation. The plugin has a .log file limit of 10 by default(can be changed) and once the limit has been hit, the file with the oldest timestamp is deleted. 
![image](https://github.com/user-attachments/assets/75ee6dc9-8cfe-472f-b037-86f2f1cf8f7f)
Starting and stopping sessions is as simple as calling `Log.start_session()` and `Log.stop_session()`. The parameter `start_delay` was implemented to add a 1-second delay before starting a new session. This was added to prevent .log files from being created with the same timestamp(if you accidentally add `start_sessions()` in multiple scripts) which can cause sorting issues when deleting the oldest log. Use only if this is affecting you!<br><br>


### **Creating log entries and include data:**<br>
Simply installing GoLogger will not generate any log entries. You still need to define `Log.entry()` in your code, including a string message and any data you want to log. Any data that can be converted to a string by using `str()` can be added to an entry. However, be mindful that converting to a string may not always format the data in a human-readable way. Example of ways to format these entries:<br>
![Example](https://github.com/user-attachments/assets/e2b81bd7-648f-4fe2-8608-bc58c1e1fde3)

The `entry()` function has one mandatory and optional parameters: `entry(category : int, log_entry : String, date_time_flag : int = 0, utc : bool = true, space : bool = true)`
Only the first parameter mandatory and needs to be defined when calling the function while the rest are optional and allow you to customize the formatting of your log entry to your liking.
1. `log_entry` - *Mandatory* - The string that makes up your log entry. Include any data that can be converted to a string can be logged.
2. `file` - *Optional* - Specifies which log file the entry will be stored in. 0 = "game.log", 1 = "player.log". If not specified, entries will be logged to "game.log" by default.
3. `include_timestamp` - *Optional* -  Flags whether to include a timestamp with the entry inside the .log file. Log entries are always added sequentially, but timestamps help measure the time between events.
4. `utc` - *Optional* -  Uses UTC as a standardized time. Set to `false` to use the user's local system time.

You can call this function from any script in your project. The string message can include almost any data, but you may need to convert that data into a string using `str()`. Godot also offers various methods of formatting strings. [See this documentation page for more information](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html) <br><br>

## **Accessing the .log files, the plugin settings and GoLoggerController:**
### Accessing the .log files:
The directories where the .log files are created are located in the User Data folder under `user://logs/x_Gologs/x.log`. The User Data folder location is different on every OS but can be accessed through Godot and can be accessed through `Project > Open User Data Folder`.
### Plugin settings:
To access the settings, you open "GoLogger.tscn" and find the settings in the Inspector.
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
