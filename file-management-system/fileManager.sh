#!/bin/bash

readonly log_file="log.txt"
readonly trash_path="/tmp/trash/"

###############################################
#                 Actions                     #
###############################################

# Action to make sure path exists
action_make_sure_path_exists() {
  if [ ! -d "${1}" ]; then
    # Create path if it doesn't exist
    mkdir -p "${1}"
  fi
}

# Action to restore file from trash
action_restore_from_trash() {
  local selected_file="${1}"
  clear

  while true
  do
    action_make_sure_path_exists "${folder_path}"
    mv "${selected_file}" "${folder_path}"
    local result=$?

    if [ $result -eq 0 ]; then
      action_log_to_file "${selected_file} restored"
      return
    else
      action_log_to_file "Failed to restore ${selected_file}, Error: ${result}"
      read -p "Failed to restore file from trash, do you want to try again? (Y/N)" try_again
      if [[ ${try_again} == "N" || ${try_again} == "n" ]]; then
        return
      fi
    fi
  done
}

# Action to show files in trash
action_show_files_in_trash() {
  action_make_sure_path_exists "${trash_path}"
  action_list_files "${trash_path}"
}

# Action to zip selected file
action_zip_file() {
  local selected_file="${1}"
  local zip_file="${selected_file}.zip"

  if [ -e "${zip_file}" ]; then
    read -p "Archive already exists. Overwrite? (Y/N): " overwrite
    if [[ ${overwrite} != "Y" && ${overwrite} != "y" ]]; then
      return
    fi
  fi

  while true
  do
    zip "${zip_file}" "${selected_file}"
    local result=$?

    if [ ${result} -eq 0 ]; then
      echo "${selected_file} compressed into ${zip_file}"
      action_log_to_file "${selected_file} compressed into ${zip_file}"
      ask_for_keypress  
      return
    else
      action_log_to_file "Failed to compress ${selected_file}, Error: ${result}"
      read -p "Failed to compress ${selected_file}, do you want to try again (Y/N)?" try_again

      if [[ ${try_again} == "n" || ${try_again} == "N" ]]; then
        return
      fi
    fi
  done
}

# Action to copy file to a specified file path
action_copy_file() {
  local selected_file="${1}"
  clear

  while true
  do
    read -p "Enter fullpath to where you want to copy file or q/Q to quit: " target_path

    if [[ ${target_path} == "q" || ${target_path} == "Q" ]]; then
      return
    fi

    if [[ ! -d "${target_path}" ]]; then
      echo "Invalid path. Please enter a valid directory."
      continue
    fi

    if [[ -e "${target_path}/$(basename "${selected_file}")" ]]; then
      read -p "File already exists at target location. Overwrite? (Y/N): " overwrite
      if [[ ${overwrite} != "Y" && ${overwrite} != "y" ]]; then
        continue
      fi
    fi

    cp "${selected_file}" "${target_path}"
    local result=$?

    if [ ${result} -eq 0 ]; then
      action_log_to_file "${selected_file} copied to ${target_path}"
      return
    fi

    clear
    echo "Failed to copy file, please try again!"
    action_log_to_file "Failed to copy ${selected_file} to ${target_path}, Error: ${result}"
  done
}

# Action to move file to a specified file path
action_move_file() {
  local selected_file="${1}"
  clear

  while true
  do
    read -p "Enter fullpath to where you want to move file or q/Q to quit: " target_path

    if [[ ${target_path} == "q" || ${target_path} == "Q" ]]; then
      return
    fi

    if [[ ! -d "${target_path}" ]]; then
      echo "Invalid path. Please enter a valid directory."
      continue
    fi

    if [[ -e "${target_path}/$(basename "${selected_file}")" ]]; then
      read -p "File already exists at target location. Overwrite? (Y/N): " overwrite
      if [[ ${overwrite} != "Y" && ${overwrite} != "y" ]]; then
        continue
      fi
    fi

    mv "${selected_file}" "${target_path}"
    local result=$?

    if [ ${result} -eq 0 ]; then
      action_log_to_file "${selected_file} moved to ${target_path}"
      return
    fi

    clear
    echo "Failed to move file, please try again!"
    action_log_to_file "Failed to move ${selected_file} to ${target_path}, Error: ${result}"
  done
}

# Action to delete file
action_delete_file() {
  local selected_file="${1}"
  clear
  
  while true
  do
    action_make_sure_path_exists "${folder_path}"
    mv "${selected_file}" "${trash_path}"
    local result=$?

    if [ ${result} -eq 0 ]; then
      action_log_to_file "${selected_file} removed"
      return
    fi

    clear
    read -p "Failed to remove file, do you want to try again? (Y/N): " try_again
    action_log_to_file "Failed to move ${selected_file}, Error: ${result}"

    if [ ${try_again} == "n" || ${try_again} == "N" ]; then
      return
    fi
  done
}

# Action to ask what to do with a selected file
action_ask_for_file_action() {
  local selected_file="${1}"

  if [[ "${selected_file}" == ${trash_path}* ]]; then
    action_handle_deleted_file "${selected_file}"
  else
    action_handle_existing_file "${selected_file}"
  fi
}

# Action to handle files in trash
action_handle_deleted_file () {
  local selected_file="${1}"

  while true
  do
    echo "R) Restore file"
    echo "Q) Quit"
    print_separator
    read -p "What do you want to do with the file?: " prompt_input

    case ${prompt_input} in
      "r"|"R")
        action_restore_from_trash "${selected_file}"
        return
        ;;
      "q"|"Q")
        return
        ;;
      *)
        echo "Incorrect input, try again!"
        ;;
    esac
  done
}

# Action to handle files that not in trash
action_handle_existing_file () {
  local selected_file="${1}"

  while true
  do
    echo "C) Copy"
    echo "M) Move"
    echo "D) Delete file"
    echo "Z) Compress file"
    echo "Q) Quit"
    print_separator
    read -p "What do you want to do with the file?: " prompt_input

    case ${prompt_input} in
      "c"|"C")
        action_copy_file "${selected_file}"
        return
        ;;
      "m"|"M")
        action_move_file "${selected_file}"
        return
        ;;
      "d"|"D")
        action_delete_file "${selected_file}"
        return
        ;;
      "z"|"Z")
        action_zip_file "${selected_file}"
        return
        ;;
      "q"|"Q")
        return
        ;;
      *)
        echo "Incorrect input, try again!"
        ;;
    esac
  done
}

# Action to handle txt file
action_handle_txt_file () {
  local selected_file="${1}"

  clear
  echo "Content of [${selected_file}]"
  print_separator
  local content=$(cat "${selected_file}")

  echo ${content}
  print_separator
  action_ask_for_file_action "$selected_file"
}

# Action to handle image files
action_handle_image_file () {
  local selected_file="${1}"

  clear
  echo "This is an image, preview is not possible"

  print_separator
  action_ask_for_file_action "$selected_file"
}

# Action to handle compressed files
action_handle_zip_file() {
  local selected_file="${1}"

  clear
  echo "This is an compressed file, preview is not possible"

  print_separator
  action_ask_for_file_action "$selected_file"
}

# Action to select a file from the file list
action_select_file () {
  local files=("$@")

  while true
  do
    read -p "Select file to work with, or q/Q to quit: " file_input

    if [[ ${file_input} == "q" || ${file_input} == "Q" ]]; then
      return
    fi

    if [[ ${file_input} -ge 1 && ${file_input} -le ${#files[@]} ]]; then
      local selected_file=${files[$file_input - 1]}

      echo "$selected_file"
      local filename=$(basename -- "${selected_file}")
      local extension="${filename##*.}"

      case ${extension} in
        "txt")
          action_handle_txt_file "$selected_file"
          return
          ;;
        "png"|"jpg"|"jpeg")
          action_handle_image_file "$selected_file"
          return
          ;;
        "zip")
          action_handle_zip_file "$selected_file"
          return
          ;;
        *)
          echo "Unsupported file type, try again!"
          ;;
      esac
    else
      echo "Invalid selection, try again!"
    fi
  done

  ask_for_keypress
}

# Action to list all or filtered files
action_list_files () {
  # Clear screen to prevent cluter
  clear

  # Read filter and remove dot in beginning to support both with and without
  # dots ex (.txt and txt)
  local filter="$(echo "${2}" | sed 's:\.*$::')"
  if [[ -z ${filter} ]]; then
    filter=""
  fi

  # Read folder path and removed trailing slashes
  local path_to_files="$(echo "$1" | sed 's:/*$::')"
  mapfile -t files < <(find "${path_to_files}/" -maxdepth 1 -type f -name "*${filter}" | sort -V)
  # Informs users in what folder we are searching
  echo "File in [${path_to_files}/]:"
  print_separator

   # Check if folder is empty
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No files found"
    ask_for_keypress
    return
  fi

  for ((i = 0; i < ${#files[@]}; ++i)); do
    local position=$(( $i + 1 ))
    echo "${position}) $(basename "${files[$i]}")"
  done

  print_separator
  action_select_file ${files[@]}
}

# Action to filter list based on file type
action_list_files_with_filter () {
  clear

  while true
  do
    echo "Filter file list based on file type (ex. .txt, .png, .jpg)"
    echo
    read -p "Enter file type or q/Q to quit: " file_input

    # Makes it possible to exit without enter file type
    if [[ ${file_input} == "q" || ${file_input} == "Q" ]]; then
      return
    fi

    # Validate selected file type
    case ${file_input} in
      ".txt"|"txt")
        action_list_files ${1} ".txt"
        return
        ;;
      ".png"|"png")
        action_list_files ${1} ".png"
        return
        ;;
      ".jpg"|"jpg")
        action_list_files ${1} ".jpg"
        return
        ;;
      *)
        clear
        printf "${file_input} is not a supported file type, try again!\n"
        ;;
    esac
  done
}

action_log_to_file() {
  local datetime_now=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[${datetime_now}] ${1}" >> "${log_file}"
}

###############################################
#                   UI                        #
###############################################

print_separator () {
  local length=${1}
  printf "=%.0s" $(seq 1 ${length:-45})
  echo # Print newline
}

ask_for_keypress () {
  echo # Print newline
  read -p "Press Enter to continue" </dev/tty
}

print_main_menu () {
  # Clear screen to prevent cluter
  clear

  echo "Main menu"
  print_separator
  echo "L) List all files"
  echo "F) Filter on file type"
  echo "T) Show files in trash"
  echo "Q) Quit"
  print_separator
  read -p "What do you want to do?: " selection_input

  case ${selection_input} in
    "l"|"L")
      action_list_files "${folder_path}"
      ;;
    "f"|"F")
      action_list_files_with_filter "${folder_path}"
      ;;
    "t"|"T")
      action_show_files_in_trash
      ;;
    "q"|"Q")
      exit 0
      ;;
  esac

  printf "\n\n"
}

readonly folder_path="${1}"

#####################################################
#                 Main program                      #
#####################################################

if [[ -z "${folder_path}" ]]; then
  echo "No folder path specified, please enter an existing folder path."
  exit 2
fi

while true;
do
  print_main_menu
done
