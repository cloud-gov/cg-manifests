#!/bin/bash

###
# Options and Usage
###

# Defaults.
s_flag=false

function help {
    echo "Usage: generate.sh [OPTION]"
    echo "Generate a Cloud Foundry manifest."
    echo " "
    echo "-s            secrets file"
}

while getopts 's:' flag

do
    case $flag in
        s  ) SECRETS=$OPTARG; s_flag=true;;
        h  ) help; exit 0;;
        \? ) help; exit 2;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

if ! $s_flag; then
  echo "****"
  echo "Error: Option -s SECRETS_FILE is required."
  echo "****"
  exit 1
fi

###
# Prepare
###

# Seems like there should be a way to make this template completely generic but,
# I haven't been able to shake hardcoding the 'name' key in plans.yml.
# The in-place replace below is a workaround.

# Get the project name from meta in secrets.
PROJECT_NAME=$(awk '/^  project:/ {print $2}' $SECRETS)

###
# Merge
###
spiff merge \
  general.yml \
  <(perl -p -e s,PROJECT_NAME,$PROJECT_NAME,g plans.yml) \
  $SECRETS
