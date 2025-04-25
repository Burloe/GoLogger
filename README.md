<h1>
  <img src="https://github.com/user-attachments/assets/2856b4fb-8d18-49b5-bd60-8a8015b6723a" alt="GoLogger Icon" height="80">
  <img src="https://img.shields.io/static/v1?label=Godot&message=4.3&color=blue&logo=godotengine" alt="Godot 4.3">
  <img src="https://img.shields.io/static/v1?label=Godot&message=4.4&color=blue&logo=godotengine" alt="Godot 4.4">
  <a href="https://github.com/Burloe/GoLogger/archive/refs/tags/1.3.zip">
  <img alt="Download" src="https://img.shields.io/badge/Download-29903b?style=plastic&color=limegreen">
  </a>
</object>

</h1>

<br>

<p><strong>GoLogger</strong> is a simple yet flexible logging framework for <em>Godot 4.3+</em>, which captures and stores game events (and data) into external <code>.log</code> files accessible by both developers and players to aid in development and maintenance of your projects. With minimal setup, it can be quickly integrated into any project to run in the background at all times or log specific events during testing. GoLogger allows you to customize its settings to suit your needs, providing timestamped log entries that make debugging and investigating issues easier.</p>

<p><img src="https://github.com/user-attachments/assets/a2b43670-e2ff-4450-a6d1-373ee9df3658" alt="GoLogger Screenshot"></p>

<p>Defining log entries is simple and only requires a string, which can include any data (that can be converted into a string). Formatting strings to include data can be done in multiple ways and is no different than normal. Here are 3 examples that result in the same log entry:</p>

<pre><code>Log.entry("Player's current health: " + str(current_health) + " / " + str(max_health), 1)

Log.entry(str("Player's current health: ", current_health, " / ", max_health), 1)

Log.entry(str("Player's current health: %s / %s" % current_health, max_health), 1)

# Resulting entry: [19:17:27] Player's current health: 74 / 100
</code></pre>

<p><em>The integer identifier <code>category_index</code> defined after the log entry string dictates which log category (or log file) the entry should be stored in. Each category respectively has their own integer identifier at the top in the dock's Categories tab.</em></p>

<p><img src="https://github.com/user-attachments/assets/5ca86c2b-326b-4897-b954-1df829f986ca" alt="Category Index Showcase"></p>

<h2>Wiki for more information</h2>
<p>See the <a href="https://github.com/Burloe/GoLogger/wiki/">Wiki</a> for more information on 
  <a href="https://github.com/Burloe/GoLogger/wiki/Installation-&-Setup">Installation &amp; Setup</a>, 
  <a href="https://github.com/Burloe/GoLogger/wiki/Getting-Started">How to use GoLogger</a> and 
  <a href="https://github.com/Burloe/GoLogger/wiki#how-gologger-works">How it works</a>.
</p>

<h2>Latest Patch Notes - 1.3:</h2>
<p>See the <a href="https://github.com/Burloe/GoLogger/releases/tag/1.3">release page</a> for more info</p>
<ul>
  <li>Cleaner visuals and theme.</li>
  <li>'Unsaved changes' problem fixed.</li>
  <li>You can now call <code>Log.save_copy("my_copy")</code> in your code. Bypassing the popup and giving you control to setup save copy automatically.</li>
  <li>The category index can be manually changed in the 'Categories' tab! The index is also numerically ordered automatically.</li>
  <li>Column slider allows you to set the number of columns visible in the GridContainer holding the categories.</li>
  <li>Proper tooltips have been added that show on mouse over which de-clutters the dock massively.</li>
  <li>Removed excessive settings.</li>
  <li>More!</li>
</ul>
