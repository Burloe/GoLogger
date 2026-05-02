# GoLogger Release Checklist

This file should be deleted if it was installed with the plugin. Please only install the `addons\GoLogger\`

## General

- [ ] Ensure the `CATEGORIES` tab is active.
- [ ] Ensure all `FoldableContainer`s are collapsed in both the `Settings` and `Help` tabs.
- [ ] Ensure `gologger_data.ini` is created if it is not present when loading the plugin.
- [ ] Ensure hotkeys all work as intended (and after rebinding).

## Code
- [ ] Remove any comments made throughout the code aside from relevant documentation comments
- [ ] Remove debugging `print()` calls
- [ ] At bottom of `_input(event: InputEvent)`, comment out the three debug `msg()` lines for keys `,.-`
- [ ] Go through code and make it uniform. For example, in `for` loops where category names are iterated through. Make all `for` loops have same naming conventions.

## Settings task list
- [x] `category_names`:
  - [x] New category names are appended to array at end.
  - [x] Rename is applied to it's existing array entry.
  - [x] Moving categories in Dock moves the array order.
  - [x] Array entry is removed when LogCategory is queue freed.
- [x] `default_category`:
  - [x] Category name is saved to file appropriately.
  - [x] (In Dock) Existing default category's CheckBox is unchecked when another is checked.
  - [x] Unchecking clears setting to "".

- [x] `base_directory`:
  - [x] New directory is created when change.
  - [x] Directories for all the categories are created when running the game if,
  - [x] Checks directory is valid before applying and reverting if not.
- [x] `log_header_format`:
  - [x] New log header is used when starting a session.
  - [x] Check all tags work properly.
- [x] `entry_format`:
  - [x] Proper format is applied to entries.
  - [x] Check all tags work properly.
- [x] `autostart_session`:
  - [x] Session is started automatically or not.
- [x] `use_utc`:
	- [x] UTC time used for .log file name, log header and entry format.
- [ ] `id_toggle`:
  - [x] ID visibility is toggled.
- [ ] `id_startup_state`:
	- [ ] ID overlay is shown when true / off when false. Only applicable if `id_toggle` is true.
- [x] `id_print`:
  - [x] ID visible when `id_toggle` is false and hotkey is held.
  - [x] ID is shown on startup if `id_toggle` and `id_startup_state`.
  - [x] ID is printed on hotkey released.
  - [x] ID is printed when the hotkey if released / on toggle if `id_toggle` is true.
- [ ] `id_align`:
	- [ ] Check label aligns to all nine positions properly.
	- [ ] Check label fills viewport for different resolutions.
- [ ] `limit_method`:
	- [ ] Ensure correct limit method.
- [ ] `entry_count_action`:
	- [ ] Ensure action is enforced for the count / timer. i.e. the action is triggered at the count cap and the session timer wait time is set properly.
- [ ] `session_timer_action`:
	- [ ] Ensure that the proper action is used and works
- [ ] `file_cap`:
	- [ ] Ensure file cap is enforced when value is hit.
- [ ] `entry_cap`:
	- [ ] Ensure entry count action is triggered when this value is hit.
- [ ] `session_duration`:
	- [ ] Ensure session timer wait time is set to this value
- [ ] `error_reporting`:
	- [ ] Check warnings and errors are pushed/printed properly according to setting.
- [ ] `columns`:
	- [ ] Check CategoryGridContainer is working with HSlider, and that the value is saved to file


## Sessions

- [ ] Start Session:
  - [ ] Verify a session starts when it should.
  - [ ] Ensure `gologger_data.ini` is created if missing.
  - [ ] Ensure `[categories.category_name]` exists in `gologger_data.ini`.
  - [ ] Ensure `[categories.category_name].file_name` contains the current file name, for example `game(260417_020435).log`.
  - [ ] Ensure `[categories.category_name].file_path` contains the absolute file path of the current file.
  - [ ] Ensure `[categories.category_name].category_name` is updated correctly.
  - [ ] Ensure `[categories.category_name].file_count` matches the number of `.log` files in the directory.
  - [ ] Ensure `[categories.category_name].is_locked` reflects the `LogCategory` lock state.
  - [ ] Ensure `[categories.category_name].entry_count` matches the number of entries in the current `.log` file.
  - [ ] Ensure a `.log` file is created with the current date and timestamp.
  - [ ] Ensure `log_header` is written into the file.
  - [ ] Ensure file count limiting removes the oldest file and preserves the correct number of files.
  - [ ] Verify a unique `session_id` is generated.
  - [ ] Verify the ID overlay displays the correct `instance_id`.
  - [ ] Verify ID overlay visuals are applied according to settings.

- [ ] During Session:
  - [ ] Verify session timer wait time is set correctly from `session_duration`.
  - [ ] Ensure the session stops or restarts correctly on timeout.
  - [ ] Verify `entry_count` is enforced at the correct limit.
  - [ ] Ensure the session stops, restarts, or overwrites entries when the limit is reached.
  - [ ] Ensure the oldest entry is the one removed.
  - [ ] Verify `msg()` logs entries correctly.
  - [ ] Verify `entry_format` is applied to each entry.
  - [ ] Verify the session ID is added if the tag is present.
  - [ ] Verify entries are not logged when a session has not started.

- [ ] End of Session:
  - [ ] Ensure `file_name`, `file_path`, and `entry_count` are reset to blank values in `gologger_data.ini`.

### Hotkeys

- [ ] Check `start_session` hotkey
- [ ] Check `stop_session` hotkey
- [ ] Check `display_instance_id` hotkey

### `gologger_data.ini`

- [ ] Ensure `[categories][category_names]` updates whenever any category change is made in the dock.
- [ ] Ensure `[categories][default_category]` updates whenever any category change is made in the dock.
- [ ] Ensure each `[categories.category_name]` section updates its `file_name`, `file_path`, `category_name`, `file_count`, `is_locked`, and `entry_count` values correctly.
- [ ] Ensure `[categories][category_names]` matches the dock order.
- [ ] Ensure `[categories][category_names]` reorders correctly when categories are moved.
- [ ] Ensure `[categories][category_names]` deletes the correct category when one is removed.
- [ ] Ensure `[categories][default_category]` assigns and reassigns correctly.
- [ ] Ensure `[categories][default_category]` clears correctly when unticked.
- [ ] Ensure new category sections are initialized with blank values.
- [ ] Ensure category session fields update correctly during sessions.
- [ ] Ensure settings are validated properly.
- [ ] Ensure

## Dock

### Categories

- [ ] Ensure `Apply` and `DefaultCategory` toggle correctly when modifying a category name.
- [ ] Ensure `Apply` is disabled when the current `LineEdit` value is invalid.
- [ ] Ensure `Reset` appears when `CategoryName[LineEdit]` is being edited.
- [ ] Ensure `Reset` restores the last applied `category_name`.
- [ ] Ensure `Lock` disables `CategoryName[LineEdit]` and `Delete`.
- [ ] Ensure `DefaultCategory` toggles correctly across all `LogCategory` instances.
- [ ] Ensure move buttons reposition `LogCategory` items correctly.
- [ ] Ensure left- and right-most move buttons disable correctly. Including after a `LogCategory` deletion.
- [ ] Ensure `Delete` properly `queue_free()`s the target `LogCategory`.
- [ ] Apply and Revert buttons for LineEdits:
  - [ ] `base_directory`, `log_header_format` and `entry_format` Revert buttons.
  - [ ] `base_directory`, `log_header_format` and `entry_format` Apply buttons and Enter keypress applies the values.
  - [ ] `base_directory`, `log_header_format` and `entry_format` Revert buttons reverts to the last applied value.

### Log Browser
- [ ] Ensure categories are loaded and that the tabs in the TabContainer are named appropriately.
- [ ] Ensure log files are properly refreshed and loaded when pressing `ReloadButton`.
- [ ] Check that `VSlider`indeed changes the font size of the content label.
- [ ] Ensure files that can't open displays the error.
- [ ] R-Click closes an open log file, ONLY WHEN CLICKED INSIDE THE CONTENTS CONTAINER.

### Settings Tab

- [ ] Ensure theme uniformity follows `EditorSettings` `base_color`, `accent_color`, and `contrast`.
- [ ] Ensure theme colors update correctly between light and dark editor themes.
- [ ] Ensure each setting label highlights when either the setting control or its container is hovered.
- [ ] Ensure each setting loads the correct value from the `.ini` file.
- [ ] Ensure each setting saves the correct value to the `.ini` file.
- [ ] Ensure each setting applies its behavior correctly.
- [ ] Ensure `BaseDirectory`, `LogHeaderFormat`, and `EntryFormat` show the `Apply` button when a valid value is present.
- [ ] Ensure the inspector module for hotkeys loads and displays correctly.
- [ ] Ensure each setting control and its container show the same tooltip text.

### Help Tab

- [ ] Spellcheck and grammar check all help content.
- [ ] Ensure all help text matches the latest version.