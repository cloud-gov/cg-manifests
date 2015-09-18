#!/bin/bash

# Quick script to generate GUIDs and random keys in manifests. Is there a simple
# templating language available everywhere that would be easier?

###
# Options and Usage
###

# Defaults.
s_flag=false

function help {
    echo "Usage: randomize.sh [OPTION]"
    echo "Generate random keys for a Cloud Foundry manifest."
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

# Perl to replace in place.
function replace_in_place  () {
  perl -pi -e '$a=1 if(!$a && s/'$1'/'$2'/);' $3
  if [ $? -ne 0 ]; then
    return 1
  fi
  return 0
}

# Random string generator with a long and short option.
function random_string  () {
  if [ "$1" == "SHORT" ]; then
    RANDOM_STRING=$(openssl rand -base64 8 | tr -d /=+ | cut -c -8)
  else
    RANDOM_STRING=$(openssl rand -base64 48 | tr -d /=+ | cut -c -48)
  fi
  if [ $? -ne 0 ]; then
    return 1
  fi
  return 0
}

# Use uuidgen for GUIDs.
function random_guid  () {
  RANDOM_GUID=$(uuidgen | tr [:upper:] [:lower:])
  if [ $? -ne 0 ]; then
    return 1
  fi
  return 0
}

###
# Vars.
###

RANDOM_STRING_COUNT=$(grep "RANDOM_STRING" $SECRETS | wc -l)
RANDOM_SHORT_STRING_COUNT=$(grep "RANDOM_SHORT_STRING" $SECRETS | wc -l)
RANDOM_GUID_COUNT=$(grep "RANDOM_GUID" $SECRETS | wc -l)

###
# Action.
###

echo "Strings found:" $RANDOM_STRING_COUNT
echo "Short Strings found:" $RANDOM_SHORT_STRING_COUNT
echo "GUIDs found:" $RANDOM_GUID_COUNT

# Should probably have a function to DRY this out.
if [ $RANDOM_STRING_COUNT -gt 0 ]; then
  for i in `seq 1 $RANDOM_STRING_COUNT`; do
    random_string "LONG"
    echo "Replacing with: $RANDOM_STRING"
    replace_in_place "RANDOM_STRING" "$RANDOM_STRING" "$SECRETS"
  done
fi

if [ $RANDOM_GUID_COUNT -gt 0 ]; then
  for i in `seq 1 $RANDOM_GUID_COUNT`; do
    random_guid
    echo "Replacing with: $RANDOM_GUID"
    replace_in_place "RANDOM_GUID" "$RANDOM_GUID" "$SECRETS"
  done
fi

if [ $RANDOM_SHORT_STRING_COUNT -gt 0 ]; then
  for i in `seq 1 $RANDOM_SHORT_STRING_COUNT`; do
    random_string "SHORT"
    echo "Replacing with: $RANDOM_STRING"
    replace_in_place "RANDOM_SHORT_STRING" "$RANDOM_STRING" "$SECRETS"
  done
fi
