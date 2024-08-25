#!/bin/bash

readonly log_file="log.txt"

###############################################
#                 Actions                     #
###############################################

# Action to copy file to a specified file path
action_copy_file() {
  local selected_file=${1}
  clear

  while true
  do
    read -p "Enter fullpath to where you want to copy file or e/E to exit: " target_path

    if [[ ${target_path} == "e" || ${target_path} == "E" ]]; then
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
  local selected_file=${1}
  clear

  while true
  do
    read -p "Enter fullpath to where you want to move file or e/E to exit: " target_path

    if [[ ${target_path} == "e" || ${target_path} == "E" ]]; then
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

action_delete_file() {
  local selected_file=${1}
  clear
  
  while true
  do
    rm "${selected_file}"
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
  local selected_file=${1}

  while true
  do
    printf "C) Copy\n"
    printf "M) Move\n"
    printf "D) Delete file\n"
    printf "E) Exit\n"

    echo
    read -p "What do you want to do with the file?: " prompt_input

    case ${prompt_input} in
      "c"|"C")
        action_copy_file ${selected_file}
        return
        ;;
      "m"|"M")
        action_move_file ${selected_file}
        return
        ;;
      "d"|"D")
        action_delete_file ${selected_file}
        return
        ;;
      "e"|"E")
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
  local selected_file=${1}

  clear
  echo "Content of [${selected_file}]"
  print_separator
  local content=$(cat ${selected_file})

  echo ${content}
  print_separator
  action_ask_for_file_action $selected_file
}

# Action to handle image files
action_handle_image_file () {
  local selected_file=${1}

  clear
  echo "This is an image, preview is not possible"

  print_separator
  action_ask_for_file_action $selected_file
}

# Action to select a file from the file list
action_select_file () {
  local files=("$@")

  while true
  do
    read -p "Select file to work with, or e/E to exit: " file_input

    if [[ ${file_input} == "e" || ${file_input} == "E" ]]; then
      return
    fi

    if [[ ${file_input} -ge 1 && ${file_input} -le ${#files[@]} ]]; then
      local selected_file=${files[$file_input - 1]}

      echo $selected_file
      local filename=$(basename -- "${selected_file}")
      local extension="${filename##*.}"

      case ${extension} in
        "txt")
          action_handle_txt_file $selected_file
          return
          ;;
        "png"|"jpg"|"jpeg")
          action_handle_image_file $selected_file
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
  local folder_path="$(echo "$1" | sed 's:/*$::')"
  mapfile -t files < <(find "${folder_path}/" -maxdepth 1 -type f -name "*${filter}" | sort -V)
  # Informs users in what folder we are searching
  echo "File in [${folder_path}/]:"
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
    read -p "Enter file type or e/E to exit: " file_input

    # Makes it possible to exit without enter file type
    if [[ ${file_input} == "e" || ${file_input} == "E" ]]; then
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
  echo "[${datetime_now}] ${1}" >> ${log_file}
}

###############################################
#                   UI                        #
###############################################

print_ui () {
  for selection in "${@}"; do
    echo "${selection}"
  done
}

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

  print_ui "1) List all files" \
"2) Filter on file type" \
"3) Exit" \
"What do you want to do?"

  read selection_input

  case ${selection_input} in
    1)
      action_list_files ${folder_path}
      ;;
    2)
      action_list_files_with_filter ${folder_path}
      ;;
    3)
      exit 0
      ;;
  esac

  printf "\n\n"
}

folder_path=${1}

#####################################################
#                 Main program                      #
#####################################################

if [[ -z ${folder_path} ]]; then
  echo "No folder path specified, please enter an existing folder path."
  exit 2
fi

while true;
do
  print_main_menu
done
