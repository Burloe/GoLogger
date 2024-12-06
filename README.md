![GoLogger_Icon_Title](https://github.com/user-attachments/assets/2856b4fb-8d18-49b5-bd60-8a8015b6723a)

GoLogger is a simple yet flexible logging framework for Godot 4, designed to log game events and data to external .log files accessible by both developers and players. With minimal setup required, GoLogger can be integrated quickly and easily into any project. GoLogger runs in the background, capturing the data you define with timestamps, providing a snapshot of events leading up to crashes, bugs, or other issues, making it easier for users to share logs and investigate problems.

Whether you need a logger to run in the background at all times, or log at specific times while testing certain features or systems. GoLogger can be customized to run in any way you need for your project, all accessible in the editor through the bottom dock panel. 

Log entries are as simple as calling `Log.entry()`(similar and as easy to use as `print()`) and can include any data that can be converted into a string. The framework is fully customizable, allowing you to log as much or as little information as you require. Format strings in whichever way you prefer. 
```gdscript
Log.entry("Current Player health is %s/%s." % (current_health, max_health))
Log.entry(str("Current Player health is", current_health, "/", max_health, "."))
# Resulting entry: [14:44:44] Current Player health is 85/100.
```



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
**Godot will print several errors upon importing the plugin and is expected!** GoLogger simply requires an autoload, which isn't added until the plugin is enabled.

* **Importing the plugin:** Only import the "addons" into your project's root directory. The folder structure should look like `res://addons/GoLogger`.

* **Enable the plugin:** Navigate to `Project > Project Settings > Plugins`, and check "GoLogger" in the list of available plugins to enable it.<br>
*If errors persist, ensure "GoLogger.tscn" was added properly as an autoload and then restart Godot.*<br>
![enable_plugin](https://github.com/user-attachments/assets/6d201a57-638d-48a6-a9c0-fc8719beff37)

You're all set! Next time you run your project, directories and .log files will be created according to the settings and categories you've setup in the dock. It’s recommended to add `Log.stop_session()` before calling `get_tree().quit()` in your exit game function to help differentiate between normal exits, crashes, or forced closures, since the log file will end with a "Stopped session" entry.<br><br>


## How to use GoLogger:<br>
GoLogger uses 'sessions' to indicate when its logging or not. Each session creates a new log file with the timestamp of when the session was started. Sessions are also **global**, meaning that stopping a session will start and stop logging for all categories simultaneously. There are three main ways to start and stop sessions. 
* **Using the `autostart` setting** will start a session when you run your project.
* **Hotkeys** can perform the three main functions of the plugin(start, copy and stop)
* **Calling the functions though code**. You can call the functions through code as well and since the script is an autoload. You can call them from any script.

`Save Session Copy` feature was introduced in v1.2, allowing users to saves the logs of the current session into each respective category's `saved_logs` subfolder. All copies are saved into these folders and the ability to name the copies allow for easy identifiers. This feature serves two key purposes:
* **Prevent Deletion:** Oldest logs are automatically deleted when the file limit is reached. Saving a copy protects specific logs from being removed. *Simply moving a log file out of the category folder will of course also prevent deletion.*
* **Preserve Important Data:** When using the **Entry Count Limit** + **Remove Old Entries** options, older entries are deleted to make room for new ones. If a bug or unexpected event occurs during playtesting, you can use this feature to save the log without stopping the session or your game without the risk of overwriting the important log entries.

### **Example usage of the main functions:**<br>
In Godot, strings can be formatted in many ways. All of which can be done when creating log entries. Use any 
```gdscript
# General use, simply starts the session. Hotkey:  Ctrl + Shift + O
Log.start_session()
# Starts session 1.2 seconds after the call. Requires the use of 'await'.
await Log.start_session(1.2)

# No category_index defined > defaults to category 0("game" category by default).
Log.entry(str("Current game time: ", time_of_day))
# Resulting entry : [2024-11-11 19:17:27] Current game time: 16.30

# Logs into category 1("player" category by default).
Log.entry(str("Player's current health: %s/%s" % current_health, max_health), 1)
Log.entry(str("Player's current health: ", current_health, "(", max_health, ")"), 1)
# Resulting entry: [19:17:27] Player's current health: 94(100)

# Initiates the "copy session" operation by showing the name prompt popup. Hotkey:  Ctrl + Shift + U
Log.save_copy()

# Stops an active session. Hotkey:  Ctrl + Shift + P
Log.stop_session() 
```


### **Creating log entries with data:**<br>
**Simply installing GoLogger does not log any entries**. This plugin is a frame work for you to define your own log entries in your code, including any string message and any data you want to log. Any data that can be converted to a string by using `str(data)` can be added to an entry.<br>

The `entry()` function has two parameters: `entry(log_entry : String, category_index : int)`
Only the first parameter mandatory and needs to be defined when calling the function while the rest are optional and allow you to customize the formatting of your log entry to your liking.
* `log_entry` - *Mandatory* - The string that makes up your log entry. Include any data that can be converted to a string can be logged.
* `category_index` - *Optional* - This parameter specifies the category or file where the entry is logged. The index of every category is shown in the "Categories" tab of the dock at the top left of each category.<br>

*Calling this function without defining an index will make it default to log into the category with index 0 which is why it's recommended to have your "base" category(like "game") as the 0 indexed category.* <br><br>

## Managing log categories:
GoLogger will create directories for each category in the dock's "category" tab. By default, a "game" and a "player" category is added for you but you can add, remove or rename them to fit your project's need. When a category name is applied, folders are created with the name of each category within the `base_directory` and once a session is started, the folders for all categories with applied names are created(if they don't already exist) and a .log file are saved inside. The number at the top left of each category is the `category_index` of that category. Meaning if you want to log an entry into the "player" category, use the index as the last parameter when calling the function. Example `Log.entry("My player entry", 1)`.<br> 
![GoLoggerCategoryDock](https://github.com/user-attachments/assets/f4346da0-a9b5-4b00-83ba-147bcfdd3481)

*Notes:*
* *Locked categories are deleted when using the Reset button. The lock button just disables the text field, apply and delete buttons.*
* *Folders for categories created by the plugin aren't deleted when you delete a category in the dock. This is to prevent accidental deletion of log files. It's best to open the directory using the "Open" button and manually delete the corresponding folder of any deleted category.*

## Managing .log file size:
A potential pitfall to consider when logging large/growing data is how Godot's `FileAccess` API handles file writing. The `FileAccess.WRITE` mode truncates(deletes) the file's content, meaning we can't simply add a new entry to a file. The plugin first reads the file and stores each entry in an array. The entries are then re-entered sequentially before appending a new entry. **This process can cause performance issues** as the number of entries in any log file grows, potentially leading to stuttering and/or slowdowns. It is therefore vital to have limiters in place to prevent log files from becoming too large. GoLogger has a setting that you can change in the editor dock under the name `Limit Method`. Each method has it's own `Action` setting which dictates the action taken once the method condition is fullfilled.<br><br>

#### Entry Count Limit(recommended):
As the name suggests, the number of entries are counted and is used in conjunction with the settings `entry cap`. When the entry count exceeds the `entry cap`, the `Entry Count Action` is triggered. Actions available for this method:<br>
* `Remove old entries` removes the oldest entries as new ones are written. This is the safest and objectively better option to use. **However**, this will potentially delete entries. So be mindful that you should either stop the session or quit the game so your log entries aren't overwritten.
* `Stop session` will of course stop the session once the cap is hit. Requires you to start the session either manually or through code to log again.
* `Stop & start session` restarts a session, creating a new log file.<br>

#### Session Timer:
As any session is started, a timer is started alongside it that triggers the `Session Timer Action` upon timeout. The session timer has uses not limited to solve this problem. If you don't want to log at all times, only when testing or performing a stress test that requires you to log for X amount of time. The session timer allows you to sync up the session and a test with the `session_timer_started` and `session_timer_stopped` signals. Actions available for this method:<br>
* `Stop session` will of course stop the session once the cap is hit. Requires you to start the session either manually or through code to log again.
* `Stop & start session` restarts a session, creating a new log file.

*You can also use both Entry Count Limit and Session Timer simultaneously!*<br>

#### None(beware):
You can also choose to use none of the `Limit Method` options. This is useful if you don't have logging sessions running in the background at all times. For example, if you use GoLogger only when you want to test a specific feature or system and you're manually stopping and starting the sessions as you need them. This is **NOT RECOMMENDED** unless you're aware of the problems that can occur. Use at your own risk!<br><br>


### File count limit:
Despite .log files taking minimal storage space, generating an endless amount of files is never a good idea. Therefore, GoLogger has an adjustable `file count limit` setting that limits the number of .log files allowed in the category folders. By default, this limit is set to 10 and will overwrite the log file with the oldest date- and timestamp. Moving a .log file out of the folder saves it from this overwrite action.<br>
*It's possible to turn this off by setting the value to 0 but it is **NOT recommended**!*
