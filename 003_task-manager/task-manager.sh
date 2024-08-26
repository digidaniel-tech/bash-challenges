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

ui_print_tasks () {
  clear
  action_cleanup_taskfile
  mapfile -t tasks < "${taskfile}"
  local show_index=${1:-false}

  if [[ ${#tasks} -eq 0 ]]; then
    echo "There is not tasks to be shown, add a task to get going"
  else
    for (( i = 0; i < "${#tasks[@]}"; i++ )); do
      if [[ ${show_index} == true ]]; then
        printf "$((i + 1))) "
      fi

      echo "${tasks[$i]}"
    done
  fi
}

action_cleanup_taskfile () {
  sed -i '/^[[:space:]]*$/d' "$taskfile"
}


action_log_to_file () {
  local message="${1}"
  local datetime_now=$(date +"%Y-%m-%d %H:%M:%S")

  echo "[${datetime_now}] ${message}" >> "${logfile}"
}

action_mark_task_as_completed () {
  action_load_all_tasks
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

  while true;
  do
    read -p "Enter a deadline for task or empty to quit (format: 12/31/2024): " deadline

    if [[ -z "${deadline}" ]]; then
      return
    fi

    if [[ ! "${deadline}" =~ ^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$ ]]; then
      echo "Date ${deadline} is not a valid datetime format, try again"
      continue
    fi

    # Validate date that the date input is an valid date
    date -d "${deadline}" 2> /dev/null
    local result=$?

    if [[ ${result} -gt 0 ]]; then
      echo "Date ${deadline} is not a valid date"
      continue
    else
      echo "${task} | ${deadline} | Pending" >> "${taskfile}"
      return
    fi
  done
}

action_view_all_tasks () {
  ui_print_tasks false
  read -p "Press any key to continue.."
}

action_mark_task_as_completed () {
  action_manipulate_task "complete" complete_task
}

action_remove_task () {
  action_manipulate_task "remove" remove_task
}

action_manipulate_task () {
  local action=${1}
  local operation=${2}

  ui_print_tasks true
  mapfile -t tasks < "${taskfile}"

  while true
  do
    read -p "Select task to ${action}: " selected_task
    if [[ ${selected_task} -gt ${#tasks[@]} || ${selected_task} -le 0 ]]; then
      echo "${selected_task} is not a valid selection"
      continue
    else
      $operation "${selected_task}"
      local result=$?

      local task=${tasks[$selected_task-1]}
      local task_name=$(extract_task_name ${task})

      if [[ ${result} -gt 0 ]]; then
        echo "Task ${task_name} failed to be ${action}ed"
        action_log_to_file "Task ${task_name} failed to be ${action}ed"
        ui_ask_to_try_again
        
        local tryagain=$?
      
        if [[ "${tryagain}" -eq 0 ]]; then
          return
        else
          continue
        fi
      fi

      clear
      echo "Task ${task_name} was ${action}ed"
      action_log_to_file "Task ${task_name} was ${action}ed"
      read -p "Press any key to continue.."
      return
    fi
  done
}

complete_task () {
  sed -i "${1}s/Pending/Completed/" "${taskfile}"
}

remove_task () {
  sed -i "${1}s/.*//" "${taskfile}"
}

extract_task_name () {
  local task=$1
  local task_split=(${task//|/ })
  local task_name=${task_split[0]}
  echo $task_name
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
    action_mark_task_as_completed
    ;;
  4)
    action_remove_task
    ;;
  5)
    exit 0
    ;;
  *)
    echo "Invalid selection. Please try again!"
    read -p "Press any key to continue..."
    ;;
  esac
}

while true; do
  action_make_sure_tasks_file_exists
  main_menu
done
