![GoLogger_Icon_Title](https://github.com/user-attachments/assets/2856b4fb-8d18-49b5-bd60-8a8015b6723a)

GoLogger is a simple yet flexible logging framework for Godot 4, designed to log game events and data to external .log files accessible by both developers and players. With minimal setup required, GoLogger can be integrated quickly and easily into any project. GoLogger runs in the background, capturing the data you define with timestamps, providing a snapshot of events leading up to crashes, bugs, or other issues, making it easier for users to share logs and investigate problems.

Log entries are as simple as calling `Log.entry()`(similar and as easy to use as `print()`) and can include any data that can be converted into a string. The framework is fully customizable, allowing you to log as much or as little information as you require.

	Log.entry("Player picked up", item, " x", item.amount, ".")	     # Result: [14:44:44] Player picked up MedKit x3. 

## **Contents**
1. Installation and setup
2. How to use GoLogger
   * Example usage of the main functions
   * Creating log entries with data
   * Managing log categories
4. Managing .log files
   * Entry count limit
   * Sesssion timer
   * File count limit

## Installation and setup:
![Install Errors](https://github.com/user-attachments/assets/7edcdc5d-9d10-4e39-83fa-e31a9f2a49c3)<br>

**Note: Godot will print several errors upon importing the plugin and is expected!** *GoLogger requires an autoload, which isn't added until the plugin is enabled.*

* **Importing the plugin:** Only import the "addons" into your project's root directory. The folder structure should look like `res://addons/GoLogger`.

* **Enable the plugin:** Navigate to `Project > Project Settings > Plugins`, and check "GoLogger" in the list of available plugins to enable it.<br>
*If errors persist, ensure "GoLogger.tscn" was added properly as an autoload and then restart Godot.*<br>

![enable_plugin](https://github.com/user-attachments/assets/6d201a57-638d-48a6-a9c0-fc8719beff37)


You're all set! Next time you run your project, folders and .log files will be created. It’s recommended to add `Log.stop_session()` before calling `get_tree().quit()` in your exit game function. While not stopping a session before closing the game won’t break the plugin, but it’s good practice. This can help differentiate between normal exits, crashes, or forced closures, depending on whether the log file ends with "Stopped session."<br><br>


## How to use GoLogger:<br>
GoLogger uses 'sessions' to indicate when its logging or not. Each session creates a new log file with the date- and timestamp of when the session was started. Sessions are also **global**, meaning that stopping a session will stop logging and starting a new session creates a new file for all categories to log to. There are three main ways to start and stop sessions. 
* **Using the `autostart` setting** which starts a session when you run your project.
* **Hotkeys** can perform the three main functions of the plugin(start, copy and stop)
* **Calling the functions though code**. You can call the functions through code as well and since the script is an autoload. You can call them from any script.

### **Example usage of the main functions:**<br>
```gdscript

# General use, simply starts the session. 
Log.start_session() # In-game hotkey:  Ctrl + Shift + O
# Starts session 1.2 seconds after the call.
await Log.start_session(1.2)

# No category_index defined > defaults to category 0("game" category by default).
Log.entry(str("Current game time: ", time_of_day))
# Resulting entry : [2024-11-11 19:17:27] Current game time: 16.30

# Logs into category 1("player" category by default).
Log.entry(str("Player's current health: ", current_health, "(", max_health, ")"), 1)
# Resulting entry: [2024-11-11 19:17:27] Player's current health: 94(100)

# Initiates the "copy session" operation by showing the name prompt popup.
Log.save_copy() # In-game hotkey:  Ctrl + Shift + U

# Stops an active session.
Log.stop_session() # In-game hotkey:  Ctrl + Shift + P
```

*The parameter `start_delay` provides the option to delay the start of a session by the specified time in seconds*


### **Creating log entries with data:**<br>
Simply installing GoLogger does not log any entries. You still need to define `Log.entry()` in your code, including any string message and any data you want to log. Any data that can be converted to a string by using `str()` can be added to an entry..<br>

The `entry()` function has two parameters: `entry(log_entry : String, category_index : int)`
Only the first parameter mandatory and needs to be defined when calling the function while the rest are optional and allow you to customize the formatting of your log entry to your liking.
* `log_entry` - *Mandatory* - The string that makes up your log entry. Include any data that can be converted to a string can be logged.
* `category_index` - *Optional* - This parameter specifies the category or file where the entry is logged. For example, with the default categories "game" and "player," the game category is index 0, and player is index 1. Each category’s index is shown in the "Categories" tab of the dock at the top left of each category.<br>

*Calling this function without defining an index will make it default to log into the category with index 0.* <br><br>

## Managing log categories:
GoLogger will create directories for each category in the dock's "category" tab. By default, a "game" and a "player" category is added for you but you can add, remove or rename them to fit your project's need. When a category name is applied, folders are created with the name of each category within the `base_directory` and once a session is started, the folders for all categories with applied names are created(if they don't already exist) and a .log file are saved inside. The number at the top left of each category is the `category_index` of that category. Meaning if you want to log an entry into the "player" category, use the index as the last parameter when calling the function. Example `Log.entry("My player entry", 1)`.<br> 
![GoLoggerCategoryDock](https://github.com/user-attachments/assets/f4346da0-a9b5-4b00-83ba-147bcfdd3481)

*Notes:*
* *The lock button disables the the text field, delete and apply button but doesn't protect against using the Reset button.*
* *Category folders aren't deleted when you delete a category in the dock. This is to prevent accidental deletion of log files. Open the directory using the "Open" button and manually delete the corresponding folder of the category you've deleted.*

## Managing .log file size:
A potential pitfall to consider when logging large or growing amounts of data is how Godot's `FileAccess` handles file writing. The `FileAccess.WRITE` mode truncates(deletes) the file's content, so the plugin first reads and stores old entries with `FileAccess.READ`, then re-enters them before appending a new entry. This process can cause performance issues when files become excessively large, leading to stuttering or slowdowns, especially during long sessions or with multiple systems logging to the same category. To address this, GoLogger provides two methods to limit log file sizes:

#### Entry Count Limit(recommended):
Just as the name suggests. The number of entries are counted and if they exceed the limit, you can either stop the session, stop and start a new session or you can remove the oldest entries to make space for the new ones. Objectively, this is the better method to this potential issue which is why it is recommended to use this regardless of whether you're experiencing issues or not.
*Note that using stop/restart session with entry count stops logging for all categories. For example, if CategoryA hits a 200 entry count limit while CategoryB only has 10 entries. This stops the session and stops logging to both files.*

#### Session Timer:
Whenever a session is started, a Timer is started using the `session_duration` setting as the wait time. This timer will stop the active session upon timing out and a new session can be started aftewards. The downside of this method is that there's still the potential of logging tons of entries within the session duration. However, the Session Timer still has other uses, stress testing a new system or you simply need to log for a specific time window and dont need continuous logging. The signals `session_timer_started` and `session_timer_stopped` were added to sync up a system or feature with the logging session.
```GDScript
# Can be added to any script since Log.gd is an autoload
Log.session_timer_started.connect(_on_stress_test_start)
Log.session_timer_stopped.connect(_on_stress_test_stopped)
```

#### Both Entry Count Limit and Session Timer:
You can use also use both as well and GoLogger will still use both "Entry Count Action" and "Session Timer Action" settings to independently set the actions taken. That way, you can remove old entries with Entry Count and restart or stop a session entirely once the Session Timer times-out. 

#### File count limit:
Despite .log files taking minimal storage space, generating an endless amount of files is never a good idea. Therefore, GoLogger has an adjustable `file count limit` setting. By default, this limit is set to 10 and will delete the log file with the oldest date- and timestamp. Of course, this means it only deletes files in that directory, meaning you can move a log out of the folder to save it. It's possible to turn this off by setting the value to 0 but it is **NOT** recommended!
