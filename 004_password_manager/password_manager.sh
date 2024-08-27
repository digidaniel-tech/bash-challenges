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

  echo "[${datetime_now}] ${log}" >> "$log_file"
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

    action_add_password "${service}" "${password}" "${master_password}"
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

action_show_password () {
  while true
  do
    local password_item=${1}
    local encrypted_password=$(action_get_password_property "${password_item}" "password")

    read -p "Enter your master password or empty to exit: " master_password
    if [[ -z "${master_password}" ]]; then
      return
    fi

    local decrypted_password=$(action_decrypt_password "${encrypted_password}" "${master_password}")
    
    if [[ "${decrypted_password}" == "" ]]; then
      local service=$(action_get_password_property "${password_item}" "service")
      echo "Failed to decrypt your password"
      action_log_to_file "Failed to decrypt password for ${service}"

      ui_ask_to_try_again
      local try_again=$?
      if [[ ${try_again} -eq 0 ]]; then
        return
      else
        continue
      fi
    else
      echo "Your password is: ${decrypted_password}"
      action_log_to_file "Password for ${service} decrypted"
      read -p "Press any key to continue..."
      return
    fi
  done
}

ui_list_passwords () {
  local action=${1}
  local action_command=${2}

  mapfile -t < "${password_file}" passwords

  for ((i = 0; i < ${#passwords[@]}; ++i)) {
    local password_item=${passwords[$i]}
    local service=$(action_get_password_property "${password_item}" "service")
    echo "$((i+1))) ${service}"
  }

  while true
  do
    read -p "Select the password you want to ${action}: " selected_password_index

    if [[ -z "${selected_password_index}" ]]; then
      echo "Incorrect selection, try again."
      continue
    elif [[ ${selected_password_index} -gt ${#passwords[@]} ]]; then
      echo "Incorrect selection, try again."
      continue
    elif [[ ${selected_password_index} -le 0 ]]; then
      echo "Incorrect selection, try again."
      continue
    elif [[ ! ${selected_password_index} =~ ^[0-9]*$ ]]; then
      echo "Incorrect selection, try again."
      continue
    fi

    break
  done

  local password_item=${passwords[(($selected_password_index-1))]}
  $action_command "${password_item}"
}

action_get_password_property () {
  local password=${1}
  local property=${2}
  local password_splited=(${password//|/})

  case ${property} in
    "service")
      echo ${password_splited[0]}
      return 0
      ;;
    "password")
      echo ${password_splited[1]}
      return 0
      ;;
    *)
      echo "Invalid property"
      return 1
  esac
}

action_add_password () {
  local service=${1}
  local password=${2}
  local master_password=${3}

  while true
  do
    local encrypted_password=$(action_encrypt_password "${password}" "${master_password}")
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

    echo "${service} | ${encrypted_password} | Encrypted" >> "${password_file}"
    return 0
  done
}

action_encrypt_password () {
  local password=${1}
  local master_password=${2}
  local encrypted_password=$(echo "${password}" | openssl enc \
    -aes-256-cbc -pbkdf2 \
    -a \
    -salt \
    -pass pass:"${master_password}")

  echo "${encrypted_password}"
  return $?
}

action_decrypt_password () {
  local encrypted_password=${1}
  local master_password=${2}
  local decrypted_password=$(echo "${encrypted_password}" | openssl enc \
    -aes-256-cbc -pbkdf2 \
    -d \
    -a \
    -salt \
    -pass pass:"${master_password}" 2> /dev/null)

  echo "${decrypted_password}"
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
      2) ui_list_passwords "show" action_show_password;;
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
