# ![GoLoggerTitleBase-export2x](https://github.com/user-attachments/assets/df721f9e-4d14-48bb-ae60-1fafcd03745a)
GoLogger is a simple yet flexible logging framework for Godot 4, designed to log game events and data to external .log files accessible by both developers and players. With minimal setup required, GoLogger can be integrated quickly and easily into any project. GoLogger runs in the background, capturing the data you define with timestamps, providing a snapshot of events leading up to crashes, bugs, or other issues, making it easier for users to share logs and investigate problems.


Log entries are as simple as calling `Log.entry()`(similar and as easy to use as `print()`) and can include any data that can be converted into a string. The framework is fully customizable, allowing you to log as much or as little information as needed. There are many ways to format strings but ![you can find more information on how you can format strings here](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html).

You can log into a single log file for all your needs but GoLogger allows for you to add as many categories as needed. When logging entries, by adding the integer corresponding to the category, your entries are logged into different files. 

	Log.entry(str("Player picked up", item, " x", item.amount, ".")) # Resulting entry: [14:44:44] Player picked up MedKit x3. 
![Showcase](https://github.com/user-attachments/assets/68750dca-e25c-4390-a398-d1afddf65edb)


## **Contents**
1. Installation and setup
2. How to use GoLogger
   * Starting & Stopping Log Sessions
   * Creating log entries and include data
   * Accessing the .log files and GoLoggerController
3. Managing .log file size
   * Entry count limit
   * Sesssion timer
4. Credit and Permission

## Installation and setup:
![Install Errors](https://github.com/user-attachments/assets/7edcdc5d-9d10-4e39-83fa-e31a9f2a49c3)<br>

**Note: Godot will print several errors upon importing the plugin and is expected!** GoLogger requires an autoload, which isn't added until the plugin is enabled.

* **Importing the plugin:** Only import the "addons" into your project's root directory. The folder structure should look like `res://addons/GoLogger`.

* **Enable the plugin:** Navigate to `Project > Project Settings > Plugins`, and check "GoLogger" in the list of available plugins to enable it.
*If errors persist, ensure "GoLogger.tscn" was added properly as an autoload and then restart Godot.*<br>

![enable_plugin](https://github.com/user-attachments/assets/6d201a57-638d-48a6-a9c0-fc8719beff37)

*Everything required to add log categories and change settings can be found in the bottom dock panel. You can change the hotkey bindings in `res://addons/GoLogger/`. It’s recommended to add `Log.stop_session()` before calling `get_tree().quit()` in your exit game function. This can help differentiate between normal exits, crashes or forced closures, depending on whether the log file ends with "Stopped session*".<br><br>


## How to use GoLogger:<br>
### **Starting & stopping log sessions:**<br>
GoLogger uses sessions to indicate when it’s actively logging or not, and each session creates a new .log file with the time- and datestamp of when the session was started. There are three main ways to start and stop a session. You can use the `autostart` setting(on by default) which starts a session when you run the project. Hotkeys Ctrl + Shift + O to start or P to stop. Lastly, you can open the GoLoggerController with Ctrl + Shift + K and press the start button. Of course you can also start a session through code by simply calling `Log.start_session()` anywhere in your code. If you want to sync up some system or stress test some feature with a logging session, the signals `session_start` and `session_stopped` was added to the autoload to make this easy. The plugin also has a .log file limit of 10 by default(can be changed) and once the limit has been hit, the file with the oldest timestamp is deleted. But you can also save a copy of the active session(Ctrl + Shift + U) in case something noteworthy like a bug occured. When you do, a prompt popup appears for you to name the copy log file. These copies are saved in a subfolder of the normal log category folder.<br>

Managing the log sessions at runtime can be done in four ways:
1. Using the `autostart` setting which starts a session in the Log.gd `_ready()` function. Meaning it'll start a session when you run your project.
2. Hotkeys - <br>	Ctrl + Shift + O to start a session.<br>	Ctrl + Shift + P to stop a session<br>	Ctrl + Shift + U to create a copy of the current session and save the logs in a subfolder called "saved_logs". 
3. Controller - The plugin comes with a simple controller for those who prefer a visual controller which you can toggle its visibility with Ctrl + Shift + K. 
4. Code - Calling the functions `Log.start_session()`, `Log.stop_session()` and `Log.save_copy()` which can be added anywhere in your projects code.

![image](https://github.com/user-attachments/assets/66acca4b-86b5-40f4-9703-04549824fe7f)

### **Creating log entries and include data:**<br>
Simply installing GoLogger will not generate any log entries. You still need to define `Log.entry()` in your code, including a string message and any data you want to log. Any data that can be converted to a string by using `str()` can be added to an entry. However, be mindful that converting to a string may not always format the data in a human-readable way. Example of ways to format these entries:<br>
![Example](https://github.com/user-attachments/assets/e2b81bd7-648f-4fe2-8608-bc58c1e1fde3)

The `entry()` function has one mandatory and optional parameters: `entry(log_entry : String, category_index : int = 0)`
Only the first parameter mandatory and needs to be defined when calling the function while the rest are optional and allow you to customize the formatting of your log entry to your liking.
1. `log_entry` - *Mandatory* - The string that makes up your log entry. Include any data that can be converted to a string can be logged.
2. `category_index` - *Optional* - Specifies which log category the entry will be stored in. Category index can be found in the category tab of the dock panel.
You can call this function from any script in your project. The string message can include almost any data, but you may need to convert that data into a string using `str()`. Godot also offers various methods of formatting strings. [See this documentation page for more information](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html) <br><br>

### **Accessing the .log files and GoLoggerController:**
You can access the base directory in the bottom dock panel. Logs are stored in folders named after the categories. By default, the log files are stored in the `user://GoLogger/category_name/` folder. This path is different depending on your OS but you can find information about where that is on this ![documentation page](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#accessing-persistent-user-data-user). The GoLoggerController can be toggled in-game with `Ctrl + Shift + K`. <br><br>


## Managing .log file size:
One potential pitfall to be aware of when logging large or ever-increasing amounts of data is how Godot's `FileAccess.WRITE` handles writing to files. To write log entries, `FileAccess.WRITE` is used which truncates the file when used. Therefore, old entries are temporarily stored with `FileAccess.READ` before the file is truncated, They're then added back, while appending the new entry. This may result in stuttering issues when files grow excessively large as loading and unloading large arrays can slow down the system. This is a concern during long sessions or if several systems log into one file. To mitigate this, GoLogger features a 'category' system that in addition of separating log entries into different files to make the data easier to digest but also has the added benefit of splitting up the log entries. Thereby limiting the size of each log file. Additionally, there are two methods you can use to automatically manage the log sizes. With the setting `Limit Method`, you determine the method to use, while the setting `Limit Action` sets what action is taken when the method's condition is met. 
#### Methods:
* **Entry Count Limit(recommended) - In the inspector of "Log.tscn"(where you find all plugin settings), `entry_count_limit` sets the maximum number of entries/lines allowed in a file. Once the limit is reached, the oldest entry is removed as new ones are added. This method is highly reliable for preventing files from becoming too large.
* **Session Timer** - A timer is started with each session, and when it expires, the session will stop and restart by default. Settings allow you to set what action is taken u allows you to either stop the session entrirely or stop and start a new one. While this can be helpful and can be useful in certain situation, it is less reliable for file size management because it's still possible to log too many entries in a short amount of time. However, the timer can be useful for other purposes, such as stress testing. A `session_timer_started` signal is available to help sync with this timer.

#### Actions:
* **Stop & start session* - Stops a session and starts a new one. Starting a new session will create another .log file.
* **Stop only** - Stops the active session only. Requiring you to start a new session using the hotkey controls, the GoLoggerController or by calling `start_session()` in your code to start another session.


## Credit and Permission:
Everything in this plugin/repo(code, resources, images, text etc) is entirely free to use in commercial and non-commercial products and projects. No credit is required.
