# ![GoLogger_Icon_Title](https://github.com/user-attachments/assets/2856b4fb-8d18-49b5-bd60-8a8015b6723a)<br>
**GoLogger** is a simple yet flexible logging framework for *Godot 4.3+*, which captures and store game events(and data) into external `.log` files accessible and by both developers and players to aid in development and maintenence of your projects. With minimal setup, it can be quickly integrated into any project to run in the background at all times or log specific events during testing. GoLogger allows you to customize its settings to suit your needs, providing timestamped logs entries that make debugging and investigating issues easier. 

Defining log entries are simple and only requires a string, which can include any data(that can be converted into a string). Formatting strings to include/convert data can be done in multiple ways and is done no differently than normal. Here are 3 examples which both results in the same log entry:
```gdscript
Log.entry("Player's current health: " + str(current_health) + " / " + str(max_health), 1)

Log.entry(str("Player's current health: ", current_health, " / ", max_health), 1)

Log.entry(str("Player's current health: %s / %s" % current_health, max_health), 1)

# Resulting entry: [19:17:27] Player's current health: 74 / 100
```
*The integer at the end dictates which log category(log file) the entry should be stored in.*

## **Contents**
1. Installation and setup
2. How to use GoLogger
   * Example usage of the main functions
   * Creating log entries with data
   * Managing log categories
4. Managing .log files
   * Entry count limit
   * Sesssion timer
   * None
   * File count limit

## Installation and setup:
**Godot will print several errors upon importing the plugin and is expected!** GoLogger simply requires an autoload, which isn't added until the plugin is enabled.

* **Importing the plugin:** Only import the "addons" into your project's root directory. The folder structure should look like `res://addons/GoLogger`.

* **Enable the plugin:** Navigate to `Project > Project Settings > Plugins`, and check "GoLogger" in the list of available plugins to enable it.<br>
*If errors persist, ensure "GoLogger.tscn" was added properly as an autoload and then restart Godot.*<br>
![enable_plugin](https://github.com/user-attachments/assets/6d201a57-638d-48a6-a9c0-fc8719beff37)

You're all set! Next time you run your project, directories and .log files will be created according to the settings and categories in the dock. It’s recommended to add `Log.stop_session()` before calling `get_tree().quit()` to help differentiate between normal exits, crashes, or forced closures, since the log file will end with a "Stopped session" entry.<br><br>


## How to use GoLogger:<br>
GoLogger uses 'sessions' to indicate when its logging or not. Each session creates a new log file with the timestamp of when the session was started. Sessions are also **global**, meaning that stopping a session will start and stop logging for all categories simultaneously. There are three main ways to start and stop sessions. 
* **Using the `autostart` setting** will start a session when you run your project.
* **Hotkeys** can perform the three main functions of the plugin(start, copy and stop)
* **Calling the functions though code**. You can call the functions through code as well and since the script is an autoload. You can call them from any script.

`Save Session Copy` feature was introduced in v1.2, allowing users to saves the logs of the current session into each respective category's `saved_logs` subfolder. All copies are saved into these folders and the ability to name the copies allow for easy identifiers. This feature serves two key purposes:
* **Prevent Deletion:** Oldest logs are automatically deleted when the file limit is reached. Saving a copy protects specific logs from being removed. *Simply moving a log file out of the category folder will of course also prevent deletion.*
* **Preserve Important Data:** When using the **Entry Count Limit** + **Remove Old Entries** options, older entries are deleted to make room for new ones. If a bug or unexpected event occurs during playtesting, you can use this feature to save the log without stopping the session or your game without the risk of overwriting the important log entries.

### **Example usage of the main functions:**<br>
There are many ways to include data in strings and it's no different when creating strings for log entries. Use the method you're most comfortable with. Below are some examples of how to call the main methods of this framework, including a examples of how to format log entries.
```gdscript
# General use, simply starts the session. Hotkey:  Ctrl + Shift + O
Log.start_session()
# Starts session 1.2 seconds after the call. Requires the use of 'await'.
await Log.start_session(1.2)

# No category_index defined > defaults to category 0("game" category by default).
Log.entry(str("Current game time: ", time_of_day))
# Resulting entry : [19:17:27] Current game time: 16.30

# Logs into category 1("player" category by default). 3 ways to format the same string.
Log.entry("Current Player health: " + str(current_health) + "/" + str(max_health), 1)
Log.entry(str("Current Player health: ", current_health, "/", max_health), 1)
Log.entry(str("Current Player health: %s/%s" % current_health, max_health), 1)
# Resulting entry: [19:17:27] Current Player health: 74/100

# Initiates the create copy operation. Hotkey:  Ctrl + Shift + U
Log.save_copy()

# Stops an active session. Hotkey:  Ctrl + Shift + P
Log.stop_session() 
```
*The index of every category is shown in the "Categories" tab of the dock at the top left of each category.* <br>


### **Creating log entries with data:**<br>
**Simply installing GoLogger will not log any entries or data**. This plugin is a framework for you to define your own log entries in your code as you develop your project. Entries are simple strings, meaning any data that can be converted to a string by using `str(data)` can be added to an entry.<br>

When creating a log entry, you only need to create a string and concatenate any data you need. The only need to be mindful of specifying the `category_index` which depends on the categories you use. If you for example want to log the current time in your game and the players current position in two separate entries when you've loaded your game(also assuming you have the default categories). See the `Example Usage of the main functions` paragraph for real world examples of how entries can be made.<br><br>
*Without defining a `category_index` when creating log entries(i.e. `Log.entry("This is a log entry.")`). Entries are logged into the category with the index 0.*<br><br>

## Managing log categories:
GoLogger will create directories for each category in the dock's "category" tab. By default, a "game" and a "player" category is added for you but you can add, remove or rename them to fit your needs. The number at the  top left of each category is the `category_index` which dictates which category each entry is logged into. When your project runs, folders are created with the name of each category within the `base_directory` and ones a session is started. A .log file is created for each category and is stored in the category's folder.<br> 
![GoLoggerCategoryDock](https://github.com/user-attachments/assets/f4346da0-a9b5-4b00-83ba-147bcfdd3481)

*Notes:*
* *Locked categories are deleted when using the Reset button. The lock button just disables the text field, apply and delete buttons.*
* *Folders for categories created by the plugin aren't deleted when you delete a category in the dock. This is to prevent accidental deletion of log files. It's best to open the directory using the "Open" button and manually delete the corresponding folder of any deleted category.*

## Managing .log file size:
A potential pitfall to consider when logging large/growing data is how Godot's `FileAccess` API handles file writing. The `FileAccess.WRITE` mode truncates(deletes) the file's content, meaning we can't simply add new entries to a file. The plugin first reads the file and stores each entry in an array which are then re-entered sequentially before appending a new entry. **This process can cause performance issues as the entry count grows, thereby creating larger arrays that are prone to performance issues**. 

It is therefore vital to put limitations in place, which GoLogger offers a couple of options. In the settings tab of the dock, you can find `Limit Method`, each method has its own `Action` to determine the action taken once the condition of the method is fullfilled.<br><br>

#### Entry Count Limit(recommended):
As the name suggests, the number of entries are counted and is used in conjunction with the settings `entry cap`. When the entry count exceeds the `entry cap`, the `Entry Count Action` is triggered. Actions available for this method:<br>
* `Overwrite entries` removes the oldest entries as new ones are written. This is the safest and objectively better option to use. **However**, this potentially deletes important logs. So be mindful that you should either stop the session manually, copy the session or quit your game to prevent any entry loss.
* `Stop session` will of course stop the session once the cap is hit. Requires you to start the session either manually or through code to log again.
* `Restart session` restarts a session, creating a new log file.<br>

#### Session Timer:
A timer is started alongside sessions and the `Action` is triggered upon timeout. The session timer has uses outside of solving the file size issue. For example, if you don't want to log at all times, only when testing or stress testing that requires you to log during certain times. The session timer features signals that allows you to sync up the session and a test with `session_timer_started` and `session_timer_stopped`. Actions available for this method:<br>
* `Stop session` will stops sessions on session timer timeout. Requires you to start the session either manually or through code to log again.
* `Restart session` restarts sessions, creating a new log file.

*You can also use both Entry Count Limit and Session Timer simultaneously!*<br>

#### None(beware):
You can also choose to use none of the `Limit Method` options. This is useful if you don't have logging sessions running in the background at all times. For example, if you use GoLogger only when you want to test a specific feature or system and you're manually stopping and starting the sessions as you need them. This is **NOT RECOMMENDED** unless you're aware of the problems that can occur. Use at your own risk!<br><br>


#### File count limit:
Despite .log files taking minimal storage space, generating an endless amount of files is never a good idea. Therefore, GoLogger has an adjustable `file count limit` setting that limits the number of .log files allowed in the category folders. By default, this limit is set to 10 and will overwrite the log file with the oldest date- and timestamp. Moving a .log file out of the folder saves it from this overwrite action.<br>
*It's possible to turn this off by setting the value to 0 but it is **NOT recommended**!*
