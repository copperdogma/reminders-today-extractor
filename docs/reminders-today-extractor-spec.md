# Reminders Today Extractor

20250109: Created by Claude with Claude 3.5 Sonnet

## Core Purpose
Extract and format journal-related reminders from Apple's Reminders app into a structured markdown document for personal knowledge management.

## Fundamental Principles

1. **Single Responsibility**
   - Tool does one thing: extract and format journal-related reminders
   - Maintains focus on journaling workflow specifically
   - No feature creep into general reminder management

2. **Minimal Text Modification**
   - Preserve original reminder text as much as possible
   - Only modify for formatting consistency
   - Respect the original thought process and dictation style

3. **Structured Output**
   - Consistent markdown bullet point format
   - Optional succinct titles for entries
   - Clean, readable formatting for knowledge management

4. **Privacy First**
   - Local processing only
   - Uses system frameworks (EventKit) for secure reminder access
   - No external dependencies for core functionality

## Output Format
1. **Document Structure**
   - Bullet point format
   - Preserves multi-line entries
   - Maintains readability with proper line breaks

## Technical Requirements
1. **System Integration**
   - macOS compatibility
   - EventKit framework for reminder access
   - System-level permissions handling

2. **Performance**
   - Quick processing for daily use
   - Efficient text processing
   - Minimal system resource usage 