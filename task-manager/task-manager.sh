#!/bin/bash

readonly taskfile="tasks.txt"
readonly logfile="task_log.txt"

ui_ask_to_try_again () {
  while true
  do
    read -p "Do you want to try again? (Y/N): " try_again

    if [[ "${try_again}" =~ ^[Nn]$ ]]; then
      return 0
    elif [[ "${try_again}" =~ ^[Yy]$ ]]; then
      return 1
    fi

    echo "Invalid input."
  done
}

action_log_to_file () {
  local message="${1}"
  local datetime_now=$(date +"%Y-%m-%d %H:%M:%S")

  echo "[${datetime_now}] ${message}" >> "${logfile}"
}

action_make_sure_tasks_file_exists () {
  while true
  do
    if [[ -f "${taskfile}" ]]; then
      return 0
    elif [[ -d "${taskfile}" ]]; then
      local message="${taskfile} is a directory, please remove the directory and try again"
      echo "${message}"
      action_log_to_file "${message}"
      read -p "Press any key to continue.."
      continue
    fi

    # Create file if it doesn't exists
    touch "${taskfile}"
    local result=$?

    # Informs user that it failed to create file and ask to try again
    if [[ ! "${result}" -eq 0 ]]; then
      local message="Failed to create ${taskfile}, Error code: ${result}"
      echo "${message}"
      action_log_to_file "${message}"

      ui_ask_to_try_again
      local tryagain=$?
      
      if [[ "${tryagain}" -eq 0 ]]; then
        return
      else
        continue
      fi
    fi

    return
  done
}

action_add_new_task () {
  clear
  read -p "Enter a task to add (or empty to quit): " task

  if [[ -z "${task}" ]]; then
    return
  fi

  local date=$(date +"%Y-%m-%d")
  local status="Pending"

  echo "${task} | ${date} | ${status}" >> "${taskfile}"
}

action_view_all_tasks () {
  clear

  # Load content from task file and using xargs to trim whitespaces and newlines
  local content=$(cat "${taskfile}" | xargs)

  if [[ ${#content} -eq 0 ]]; then
    echo "There is not tasks to be shown, add a task to get going"
  else
    echo "${content}"
  fi

  read -p "Press any key to continue.."
}

main_menu () {
  clear
  echo "1) Add Task"
  echo "2) View Tasks"
  echo "3) Mark Task as completed"
  echo "4) Delete Task"
  echo "5) Exit"
  read -p "Select: " selection

  case "${selection}" in
  1)
    action_add_new_task
    ;;
  2)
    action_view_all_tasks
    ;;
  3)
    ;;
  4)
    ;;
  5)
    exit 0
    ;;
  esac
}

while true; do
  action_make_sure_tasks_file_exists
  main_menu
done
