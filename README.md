# ![GoLogger_Icon_Title](https://github.com/user-attachments/assets/2856b4fb-8d18-49b5-bd60-8a8015b6723a)![](https://img.shields.io/static/v1?label=Godot&message=4.3&color=blue&logo=godotengine)   ![](https://img.shields.io/static/v1?label=Godot&message=4.4&color=blue&logo=godotengine)<br>

**GoLogger** is a simple yet flexible logging framework for *Godot 4.3+*, which captures and store game events(and data) into external `.log` files accessible by both developers and players to aid in development and maintenence of your projects. With minimal setup, it can be quickly integrated into any project to run in the background at all times or log specific events during testing. GoLogger allows you to customize its settings to suit your needs, providing timestamped logs entries that make debugging and investigating issues easier. 

Defining log entries are simple and only requires a string, which can include any data(that can be converted into a string). Formatting strings to include data can be done in multiple ways and is no different than normal. Here are 3 examples that results in the same log entry:
```gdscript
Log.entry("Player's current health: " + str(current_health) + " / " + str(max_health), 1)

Log.entry(str("Player's current health: ", current_health, " / ", max_health), 1)

Log.entry(str("Player's current health: %s / %s" % current_health, max_health), 1)

# Resulting entry: [19:17:27] Player's current health: 74 / 100
```
*The integer value defined after the log entry string dictates which log category(or log file) the entry should be stored in. Each category respectively has their own number at the top-left hand corner in the dock's Category tab.*
![GoLoggerCategoryDock](https://github.com/user-attachments/assets/f4346da0-a9b5-4b00-83ba-147bcfdd3481)<br><br>

## Wiki for more information
See the [Wiki](https://github.com/Burloe/GoLogger/wiki/) for more information on [Installation % Setup](https://github.com/Burloe/GoLogger/wiki/Installation-&-Setup), [How to use GoLogger](https://github.com/Burloe/GoLogger/wiki/Getting-Started) and [How it works](https://github.com/Burloe/GoLogger/wiki#how-gologger-works)
