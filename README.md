# Reminders Extractor

A Swift command-line tool that extracts reminders from the "Today" smart list in Apple Reminders and exports them to a markdown file.

## Features

- Uses the official EventKit framework for reliable access to the Reminders database
- Extracts all reminders from the "Today" smart list, including:
  - Reminders due today
  - Overdue reminders
- Creates a clean, readable markdown file with:
  - Simple bulleted list format
  - Proper line wrapping for long items
  - Timestamped filenames for easy tracking

## Requirements

- macOS (tested on macOS Sonoma 24.2.0)
- Swift 5.9 or later
- Xcode Command Line Tools

## Installation

1. Make sure you have Xcode Command Line Tools installed:
   ```bash
   xcode-select --install
   ```

2. Clone this repository:
   ```bash
   git clone [repository-url]
   cd RemindersExtractor
   ```

3. Build the project:
   ```bash
   swift build
   ```

## Usage

Run the program:
```bash
swift run
```

The first time you run the tool, macOS will ask for permission to access your reminders. After granting access, the tool will:
1. Connect to your Reminders database
2. Extract all items from your Today list
3. Create a markdown file in the current directory with the format: `today_reminders_YYYYMMDD_HHMMSS.md`

## Output Format

The generated markdown file will look like this:
```markdown
# Today's Reminders

- First reminder
- Second reminder
- A longer reminder that wraps nicely to the next line
  continuing here with proper indentation
```

## Permissions

The tool requires permission to:
- Access your reminders (via EventKit)

This permission is requested once and remembered for future runs. 