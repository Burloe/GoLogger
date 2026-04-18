# GoLogger QA Test Plan

## Goal

Run a short manual regression pass before release to confirm session flow, category persistence, dock interactions, settings application, and help text quality.

## Core Smoke Tests

### 1. Plugin Startup

- Verify the dock opens on the `CATEGORIES` tab.
- Verify all `FoldableContainer`s in `Settings` and `Help` start collapsed.
- Delete `gologger_data.ini`, reload the plugin, and verify the file is recreated.

### 2. Session Start and Logging

- Start a session and verify a log file is created.
- Verify the file name uses the expected timestamp format.
- Verify `log_header` is written to the file.
- Verify the active category section in `gologger_data.ini` updates `file_name`, `file_path`, `file_count`, and `entry_count`.
- Send a test `msg()` entry and verify it is written correctly.

### 3. Limiters

- Test `ENTRY_COUNT` mode and verify the configured action occurs at the correct threshold.
- Test `SESSION_TIMER` mode and verify timeout behavior is correct.
- Test `BOTH` mode and verify both limiter UIs and behaviors work together.
- Test `NONE` mode and verify both limiter-specific UI sections are hidden.

### 4. Category Management

- Add a category and verify focus moves to its name field.
- Rename a category and verify `Apply` and `Reset` behavior.
- Set a default category and verify only one category is marked default.
- Lock a category and verify rename and delete controls are disabled.
- Move categories left and right and verify saved order matches the dock order.
- Delete a category and verify it is removed from both the dock and `gologger_data.ini`.

### 5. Settings

- Change `BaseDirectory` and verify the path is saved and can be opened.
- Change `LogHeaderFormat` and verify the new value is saved.
- Change `EntryFormat` and verify invalid values are rejected and valid values are applied.
- Change `file_cap`, `entry_cap`, and `session_duration` and verify persistence.
- Change ID overlay settings and verify the example preview updates.
- Toggle `id_toggle` and verify `id_startup_state` visibility follows it.

### 6. Theme and UI Behavior

- Change editor theme settings and verify dock colors update correctly.
- Hover both a settings control and its container and verify the same label highlight behavior.
- Verify related controls and containers expose matching tooltip text.

### 7. Session End

- Stop a session and verify `file_name`, `file_path`, and `entry_count` are cleared.

### 8. Help Content

- Do a quick spelling and grammar pass.
- Verify help text still matches current plugin behavior.

## Exit Criteria

- No broken startup behavior.
- No incorrect category persistence.
- No broken limiter behavior.
- No invalid settings persistence.
- No obvious UI regressions in dock interactions or theming.
- No outdated or obviously incorrect help content.