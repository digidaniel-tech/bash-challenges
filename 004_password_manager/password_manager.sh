#!/bin/bash

readonly password_file="passwords.txt"
readonly log_file="password_log.txt"

ui_ask_to_try_again () {
  while true
  do
    read -p "Do you want to try again (Y/N)?: " try_again
    if [[ "${try_again}" =~ ^nN$ ]]; then
      return 0
    elif [[ "${try_again}" =~ ^yY$ ]]; then
      return 1
    fi

    echo "Invalid input, try again."
  done
}

action_log_to_file () {
  local datetime_now=$(date +"%Y-%m-%d %H:%M:%S")
  local log=${1}

  echo "[${datetime_now}] ${log}" > "$log_file"
}

ui_add_password () {
  while true
  do
    clear

    read -p "Enter service or empty to exit: " service
    if [[ -z "${service}" ]]; then
      return
    fi

    read -p "Enter password for service or empty to generate one: " password
    if [[ -z "${password}" ]]; then
      local password=$(action_generate_password)
      echo "Your password is: ${password}"
    fi

    read -p "Enter your master password or empty to exit: " master_password
    if [[ -z "${master_password}" ]]; then
      return
    fi

    action_add_password
    local result=$?

    if [[ "${result}" -gt 0 ]]; then
      echo "Password added!"
      action_log_to_file "Password added to file"
    fi

    read -p "Press any key to continue..."
    return
  done
}

ui_generate_password () {
  clear
  local generated_password=$(action_generate_password)
  echo "Your password is: ${generated_password}"
  read -p "Press any key to continue..."
}

action_add_password () {
  while true
  do
    local encrypted_password=$(echo -n "$password" | openssl enc -pbkdf2 -a -salt -pass pass:"$master_password" -p)
    local result=$?

    if [[ ${result} -gt 0 ]]; then
      echo "Failed to add password.."
      action_log_to_file "Failed to encrypt password"

      ui_ask_to_try_again
      local try_again=$?
      if [[ ${try_again} -eq 0 ]]; then
        return 1
      else
        continue
      fi
    fi

    echo "${service} | ${encrypted_password} | Encrypted" > "${password_file}"
    return 0
  done
}

action_generate_password () {
  local random_password=$(openssl rand -base64 16)
  echo "${random_password::-2}"
}

main_menu () {
  while true
  do
    clear
    echo "1) Add New Password"
    echo "2) View Password"
    echo "3) Delete Password"
    echo "4) Generate Strong Password"
    echo "5) Exit"
    read -p "What du you want to do?: " menu_selection

    case ${menu_selection} in
      1) ui_add_password ;;
      2) ;;
      3) ;;
      4) ui_generate_password ;;
      5) exit 0;;
      *)
        echo "Invalid selection, please try again!"
        read -p "Press any key to continue..."
        ;;
    esac
  done
}

main_menu
