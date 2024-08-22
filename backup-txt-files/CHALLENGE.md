# Challenge: File Management Script

## Description

In this challenge I will write a script that takes in an path to a folder as an 
argument where it contains multiple .txt files to backup, the backup files
should be saved in a separate folders, each file should be logged and old
backups should be removed.

## Tasks

1. Create a backup of all .txt files in a directory:
    * The script should take a directory as an argument and then create a backup
    of all .txt files in that directory.
    * The backup should be saved in a new directory named backup_YYYYMMDD where 
    YYYYMMDD represents the current date.

2. Log all copied files:
    * The script should log the name of each file that is copied into a log file
    named backup_log.txt.
    * The log file should also include a timestamp of when each file was copied.

3. Clean up old backups:
    * If there are any backups older than 7 days, the script should delete them.
