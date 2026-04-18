# GoLogger Release Checklist

This checklist is intended for final pre-release verification of the GoLogger plugin. It covers startup behavior, session lifecycle, category persistence, dock behavior, settings application, and help content quality.

## General Verification

Before testing individual features, confirm that the dock opens in the expected default state. The `CATEGORIES` tab should be active, and all `FoldableContainer`s in both the `Settings` and `Help` tabs should start collapsed. Also verify that `gologger_data.ini` is automatically created when the plugin loads and the file does not already exist.

## Session Verification

### Session Start

Confirm that a session starts whenever the plugin state allows it to start. At the beginning of a session, verify that `gologger_data.ini` exists and includes a `[categories.category_name]` section for the active category. Check that the section updates `file_name`, `file_path`, `category_name`, `file_count`, `is_locked`, and `entry_count` correctly.

In the log directory, confirm that a new `.log` file is created with the expected date and timestamp naming pattern. Verify that the configured `log_header` is written into the file and that file-cap behavior removes the oldest file when necessary while preserving the correct total number of log files.

For instance ID behavior, verify that a unique `session_id` is generated, that the overlay displays the correct `instance_id`, and that its visual presentation matches the current settings.

### Session Runtime

During an active session, verify that the session timer uses the configured `session_duration` value and that timeout behavior stops or restarts the session correctly. Confirm that `entry_count` limits are enforced at the correct threshold and that the configured action is applied when the limit is reached, including overwrite, restart, or stop behavior. If overwrite mode is enabled, ensure the oldest entry is the one that gets removed.

Also verify that `msg()` writes entries correctly, that `entry_format` is applied consistently, and that the session ID is inserted whenever the format includes the relevant tag. Confirm that no entries are written if no session is active.

### Session End

When a session ends, verify that `file_name`, `file_path`, and `entry_count` are cleared in `gologger_data.ini`.

## Category Verification

### Persistence and Config State

Any category change made in the dock should immediately be reflected in `gologger_data.ini`. Confirm that `[categories][category_names]` and `[categories][default_category]` stay accurate after adding, renaming, moving, locking, unlocking, defaulting, and deleting categories. Each `[categories.category_name]` section should keep `file_name`, `file_path`, `category_name`, `file_count`, `is_locked`, and `entry_count` in sync with actual state.

When categories are reordered, ensure the saved category list matches the dock order. When categories are removed, ensure the correct category is removed from the saved list. When a new category is created, ensure its section is initialized with blank values where expected. Also confirm that stray or clobbered settings are removed and that settings validation behaves correctly.

### Dock Interactions

In the dock UI, verify that the `Apply` button and `DefaultCategory` checkbox respond correctly when the category name changes. The `Apply` button should disable when the current category name is invalid. The `Reset` button should appear while editing and should restore the last applied category name. The `Lock` button should disable both the category name `LineEdit` and the `Delete` button.

Only one category should behave as the default at a time, so confirm that `DefaultCategory` toggling updates all `LogCategory` instances correctly. Also verify that category move buttons reorder categories correctly and disable appropriately at the far left and far right edges. Finally, confirm that deleting a category properly frees the expected `LogCategory` node.

## Dock Verification

### Category Tab

Verify that the `Add` button creates a blank `LogCategory` and immediately focuses its `CategoryName[LineEdit]`. Verify that `OpenDirectory` opens the currently configured `base_directory`. Confirm that the column slider updates the category container column count correctly.

### Settings Tab

Verify that the dock theme stays consistent with the editor's `base_color`, `accent_color`, and `contrast` settings, and that the dock updates correctly when the editor theme changes between light and dark. For each setting, confirm that the label highlight is triggered both by hovering the control itself and by hovering the containing UI row.

Each setting should load the correct persisted value, save the correct updated value, and apply that value to runtime behavior. In particular, verify that `BaseDirectory`, `LogHeaderFormat`, and `EntryFormat` expose their `Apply` buttons when a valid value is entered. Also confirm that the hotkey inspector module loads and renders properly.

Tooltip behavior should remain consistent across the settings UI. Where a setting is represented by both a container and a control, both nodes should expose the same tooltip text.

### Help Tab

Perform a full spelling and grammar pass on the help content, then confirm that the written guidance matches the current plugin version and behavior.