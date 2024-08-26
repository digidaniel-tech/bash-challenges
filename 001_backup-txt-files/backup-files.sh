  #!/bin/bash

  FOLDER_PATH=$1
  LOG_FILE="backup_log.txt"

  # Function used to write to log
  write_log () {
    local DATETIME_NOW=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[${DATETIME_NOW}] ${1}" >> ${LOG_FILE}
  }

  # Function used to print output to console
  print_console () {
    for arg in "$@"; do
      echo ":: ${arg}"
    done
  }

  # Function to create backup folder if not already exists
  generate_backup_folder () {
    local DATE_NOW=$(date "+%Y%m%d")
    local BACKUP_FOLDER="backup_${DATE_NOW}"

    if [[ ! -d ${BACKUP_FOLDER} ]]; then
      mkdir ${BACKUP_FOLDER}
    fi

    echo ${BACKUP_FOLDER}
  }

  # Check so folder path is entered as argument
  if [[ -z ${FOLDER_PATH} ]]; then
    print_console "[ERROR] No folder is specified as argument, \
  please enter folder to backup"

    exit 2
  fi

  # Load backup folder to backup files to
  BACKUP_FOLDER=$(generate_backup_folder)

  # Check if folder is empty then do not try to backup anything
  if [ -z "$(ls -A "${FOLDER_PATH}")" ]; then
    write_log "No files found in ${FOLDER_PATH} to backup."
    exit 0
  fi

  # Trim end slashes 
  FOLDER_PATH="$(echo "${FOLDER_PATH}" | sed 's:/*$::')"

  # Loop trough files and back them up
  for FILE in "${FOLDER_PATH}"/*; do
    # Make sure it is a file and not a directory
    if [[ ! -f "${FILE}" ]]; then
      continue
    fi

    # Normalize filepath to stripout trailing slashes (ex. example-files/)
    FILE_NAME=$(basename "${FILE}")

    # Copy file to backup folder
    if cp "${FILE}" "${BACKUP_FOLDER}/${FILE_NAME}"; then
      # Write to log that the file has been backed up
      write_log "Backup of ${FILE} done."
    else
      # Write to log that the file has failed to be backed up
      write_log "[ERROR] Failed to backup ${FILE}."
    fi
  done

  # Search for backups older than 7 days and removes them 
  find . -maxdepth 1 -type d -name "backup_*" -mtime +7 -delete
