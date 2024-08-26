# File Management System

## Description

Create a Bash script that functions as a simple file management system.

## Tasks

1. **List all files in a selected directory.**
   - The user should be able to filter the file listing, such as showing only
   text files (`*.txt`), only images (`*.jpg, *.png`), or all files.

2. **Allow the user to choose a file to view its contents.**
   - If the file is a text file, display its content using `cat`. If the file is
   an image, print a note indicating it is an image (you don’t need to display
   the image in the terminal).

3. **Provide options to copy, move, or delete a selected file.**
   - The user should be able to specify the new location for copying/moving or
   confirm deletion.

4. **Log all actions to a log file.**
   - Log which file was viewed, copied, moved, or deleted, along with the
   timestamp of the action.

## Example Challenges:
- Implement a simple text-based user interface to select files and actions.
- Handle errors such as trying to copy a file to a location where a file with
the same name already exists or trying to delete a file that doesn’t exist.
- Keep the script user-friendly and robust.

## Bonus Challenge:
- Add a feature to compress a selected file into a `.zip` archive.
- Implement support for restoring a file from the trash if it’s deleted (move
the file to a "trash" folder instead of permanently deleting it).
