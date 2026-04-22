# GoLogger Release Checklist

This file should be deleted if it was installed with the plugin. Please only install the `addons\GoLogger`

## General

- [ ] Ensure the `CATEGORIES` tab is active.
- [ ] Ensure all `FoldableContainer`s are collapsed in both the `Settings` and `Help` tabs.
- [ ] Ensure `gologger_data.ini` is created if it is not present when loading the plugin.
- [ ] Ensure hotkeys all work as intended (as well as rebinding).

## Code
- [ ] Remove any comments made throughout the code aside from relevant documentation comments
- [ ] Remove debugging `print()` calls
- [ ] At bottom of `_input(event: InputEvent)`, comment out the three debug `msg()` lines for keys `,.-`
- [ ] Go through code and make it uniform. For example, in `for` loops where category names are iterated through. Make all `for` loops have same naming conventions.

## Sessions

### Start of Session

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

### During Sessions

- [ ] Verify session timer wait time is set correctly from `session_duration`.
- [ ] Ensure the session stops or restarts correctly on timeout.
- [ ] Verify `entry_count` is enforced at the correct limit.
- [ ] Ensure the session stops, restarts, or overwrites entries when the limit is reached.
- [ ] Ensure the oldest entry is the one removed.
- [ ] Verify `msg()` logs entries correctly.
- [ ] Verify `entry_format` is applied to each entry.
- [ ] Verify the session ID is added if the tag is present.
- [ ] Verify entries are not logged when a session has not started.

### End of Session

- [ ] Ensure `file_name`, `file_path`, and `entry_count` are reset to blank values in `gologger_data.ini`.

## Categories

### In `gologger_data.ini`

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
- [ ] Ensure clobbered or stray settings are removed.

### In the Dock

- [ ] Ensure `Apply` and `DefaultCategory` toggle correctly when modifying a category name.
- [ ] Ensure `Apply` is disabled when the current `LineEdit` value is invalid.
- [ ] Ensure `Reset` appears when `CategoryName[LineEdit]` is being edited.
- [ ] Ensure `Reset` restores the last applied `category_name`.
- [ ] Ensure `Lock` disables `CategoryName[LineEdit]` and `Delete`.
- [ ] Ensure `DefaultCategory` toggles correctly across all `LogCategory` instances.
- [ ] Ensure move buttons reposition `LogCategory` items correctly.
- [ ] Ensure leftmost and rightmost move buttons disable correctly.
- [ ] Ensure `Delete` properly `queue_free()`s the target `LogCategory`.

## Dock

### Category Tab

- [ ] Ensure `Add` creates a blank `LogCategory`.
- [ ] Ensure focus moves to the new `CategoryName[LineEdit]`.
- [ ] Ensure `OpenDirectory` opens the current `base_directory`.
- [ ] Ensure the column slider updates the category container column count correctly.

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