# ![GoLogger_Icon_Title](https://github.com/user-attachments/assets/2856b4fb-8d18-49b5-bd60-8a8015b6723a)![](https://img.shields.io/static/v1?label=Godot&message=4.3&color=blue&logo=godotengine)   ![](https://img.shields.io/static/v1?label=Godot&message=4.4&color=blue&logo=godotengine)<br>

**GoLogger** is a simple yet flexible logging framework for *Godot 4.3+*, which captures and store game events(and data) into external `.log` files accessible by both developers and players to aid in development and maintenence of your projects. With minimal setup, it can be quickly integrated into any project to run in the background at all times or log specific events during testing. GoLogger allows you to customize its settings to suit your needs, providing timestamped logs entries that make debugging and investigating issues easier.
![image](https://github.com/user-attachments/assets/a2b43670-e2ff-4450-a6d1-373ee9df3658)



Defining log entries are simple and only requires a string, which can include any data(that can be converted into a string). Formatting strings to include data can be done in multiple ways and is no different than normal. Here are 3 examples that results in the same log entry:
```gdscript
Log.entry("Player's current health: " + str(current_health) + " / " + str(max_health), 1)

Log.entry(str("Player's current health: ", current_health, " / ", max_health), 1)

Log.entry(str("Player's current health: %s / %s" % current_health, max_health), 1)

# Resulting entry: [19:17:27] Player's current health: 74 / 100
```
*The integer identifier `category_index` defined after the log entry string dictates which log category(or log file) the entry should be stored in. Each category respectively has their own integer identifier at the top in the dock's Categories tab.*
![CatIndexShowcase](https://github.com/user-attachments/assets/5ca86c2b-326b-4897-b954-1df829f986ca)<br><br>

## Wiki for more information
See the [Wiki](https://github.com/Burloe/GoLogger/wiki/) for more information on [Installation & Setup](https://github.com/Burloe/GoLogger/wiki/Installation-&-Setup), [How to use GoLogger](https://github.com/Burloe/GoLogger/wiki/Getting-Started) and [How it works](https://github.com/Burloe/GoLogger/wiki#how-gologger-works)
<br><br><br><br>




## Latest Patch Notes - 1.3:
See ![release page](https://github.com/Burloe/GoLogger/releases/tag/1.3) for more info
* Cleaner visuals and theme.
* #20 'Unsaved changes' problem fixed.
* #19 You can now call `Log.save_copy("my_copy")` in your code. Bypassing the popup and giving you control to setup save copy automatically. 
* #18 The category index can be manually changed in the 'Categories' tab! The index is also numerically ordered automatically.
* Column slider allows you to set the number of columns visible in the GridContainer holding the categories. 
* Proper tooltips have been added that shows on mouse over which de-clutters the dock massively.
* Removed excessive settings.
* More!
