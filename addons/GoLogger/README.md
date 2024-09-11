# <img src="GoLogger.svg" width="131" height="153"> GoLogger
 A basic logging system for game events in into a .log file for Godot 4.

## Introduction
 Have you found yourself working on either several new features/systems or a big one involving several scripts where you've added a ton of print statements in order to debug. Littering the Output, making the info hard to decipher and even harder to manage? Maybe you want to your game to record events to help you debug issues your players are facing where you can't access their instance. Then you might want to look into creating a way for your game to log events in your game in order to provide a sort or snapshot of the history of events led to a bug or crash.

 This is a basic logging system meant to serve as a base for you to build upon and as such, is very barebones by design. That also means it's very flexible and scalable. With some minor changes, you can make it categorize events into separate files. The system can log whatever game event and/or data in a .log file but it won't magically generate log entries for you, meaning you will need to add 'GameLog.log()' calls to your code for it to actually log anything. <u>This system is only as comprehensive and complicated as you make it</u>.

## .log files
 The system in it's current state uses two possible log files. A "DEVFILE" created/located in the project file under "res://GameLog/game.log" which is meant to be used during development because it's easily accessible. While the "FILE" is the one intended for use for release, located in "user://logs/game.log" amongst the other log files Godot generates. The idea being that when a player encounters a bug or crash and they want to report it to the developer(you), you can ask them to include the log file to hopefully give you some insights as to what led to the issue.


## Installation and setup:
Download either on GitHub(!https://github.com/Burloe/GoLogger) or through the Asset Library. After importing it into your project, some files are added which are not strictly necessary that are added for the sake of making the installation simplified. But I highly recommend doing the complicated installation because it will be easier to manage and build upon the system if that's what you're looking for.
<u>### Simple setup:</u>
	1. Find the "Log.gd" file in the addon folder and specify the desired location of the log inside your project by altering this line: "const DEVFILE = ´res://GoLogger/game.log"` 
	2. In order to swap between saving logs in the project file and the User Data folder. You find the "GoLogger.gd" in the addons folder and set "log_in_devfile" to `false` in order to save logs in User Data and `true` to save logs in your project. 
	3. The plugin will add a new autoload script called GoLogger to your project. This handles autoload only handles telling the plugin whether or not it's currently logging by using a signal and the setting which handles the log location(see step 2). Everything involved with the actual logging is handled in the `Log.gd` script. 
	
<u>### Elaborate setup:</u>
	In order to make this an easy installation to quickly get the plugin running with as little setup as possible, additional scripts were required. They are GoLogger.gd, plugin.gd and plugin.cfg. Only GoLogger is required but can be easily merged into one of your existing autoloads. It's required to be an autoload due to the nature of static functions. How to do that:
		1. Copy the code in GoLogger.gd and put it in any existing autoload(I put it in my Global.gd script), then delete GoLogger.gd
		2. In Log.gd, use Find and Replace to replace any code referencing GoLogger with your own autoload.
			2(sidenote). The example scene script also references the GoLogger.gd script so this will break that but you can just use Find and Replace there too and it's fixed. That has no bearing on the logging system since that's just example/showcase of what the plugin does.
		3. Optional! At this point, you can delete the plugin.gd and plugin.cfg and use the scripts as is. 


## How to use:
	Simply installing this plugin wont magically generate log entries when you run your game. To do that, you need to add entries into your existing code. This is very simple to do by using something like "Log.entry("Hello, world")". But chances are that you want more information that a simple "Hello, world" message, so here are some examples of how to effectively add information to the entry. 
	
	
