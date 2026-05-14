#!/bin/bash

#=====================================
# Directory and File Checker
# Usage: ./check_file.sh
#=====================================

get_input() {
  echo -e "Enter the directory path to check: "
  read -rp "    Directory: " DIR_PATH

  if [[ -z "$DIR_PATH" ]]; then
    echo -e "No directory provided. Exiting."
    exit 1
  fi

  echo ""
  echo -e "Enter the filename to check for inside the provided directory:"
  read -rp "    Filename: " FILE_NAME

  if [[ -z "$FILE_NAME" ]]; then
    echo -e "No filename provided. Exiting"
    exit 1
  fi

  FULL_PATH="$DIR_PATH/$FILE_NAME"
}

check_directory() {
  echo ""
  echo "====================================="
  echo "Directory Check"
  echo "====================================="

  if [[ -d "$DIR_PATH" ]]; then
    echo -e "Directory exits: $DIR_PATH"
    DIR_EXISTS=true

  else
    echo -e "Directory does NOT exits: $DIR_PATH"
    DIR_EXISTS=false
    create_directory

  fi
}

create_directory() {
  echo ""
  echo -e "====================================="
  echo -e "Creating Directory"
  echo -e "====================================="

  mkdir -p "$DIR_PATH"

  if [[ $? -eq 0 ]]; then
    echo -e "Directory created successfully: $DIR_PATH"
    DIR_EXISTS=true

  else
    echo -e "Failed to create directory: $DIR_PATH"
    echo -e "Check permissions on the path."
    DIR_EXISTS=false
  fi
}

check_file() {
  echo ""
  echo -e "====================================="
  echo -e "Checking file"
  echo -e "====================================="

  if [[ "$DIR_EXISTS" == false ]]; then
    echo -e "Cannot check file - directory does not exist."
    return
  fi

  if [[ -f "$FULL_PATH" ]]; then
    echo -e "File exists: $FULL_PATH"
  else
    echo -e "File does NOT exists: $FULL_PATH"
    create_file
  fi
}

create_file() {
  echo ""
  echo -e "====================================="
  echo -e "Creating file"
  echo -e "====================================="

  touch "$FULL_PATH"

  if [[ $? -eq 0 ]]; then
    echo -e "File created successfully: $FULL_PATH"
  else
    echo -e "Failed to create file: $FULL_PATH"
    echo -e "Check permission on the path"
  fi
}

final() {
  echo ""
  echo -e "====================================="
  echo -e "Final Summary"
  echo -e "====================================="

  if [[ -d "$DIR_PATH" ]]; then
    echo -e "Directory status: Exists"
  else
    echo -e "Directory status: Does not exists"
  fi

  if [[ -f "$FULL_PATH" ]]; then
    echo -e "File status: Exists"
  else
    echo -e "File status: Does not exists"
  fi

}
get_input
check_directory
check_file
final
