#!/bin/bash

###
# Options and Usage
###

# Defaults.
s_flag=false
p_flag=false
b_flag=false

# Colors
BLUE='\033[1;34m'
NC='\033[0m'

# Use plans in the current directory if not specified.
PLANS="./plans.yml"

function help {
    echo "Usage: generate.sh [OPTION]"
    echo "Generate a Cloud Foundry manifest."
    echo " "
    echo "-s            secrets file"
    echo "-p            plans file"
    echo "-b            print broker create/update commands"
}

while getopts 's:p:b' flag

do
    case $flag in
        s  ) SECRETS=$OPTARG; s_flag=true;;
        p  ) PLANS=$OPTARG; p_flag=true;;
        b  ) b_flag=true;;
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
if [ "$b_flag" = false ]; then
spiff merge \
  general.yml \
  <(perl -p -e s,PROJECT_NAME,$PROJECT_NAME,g $PLANS) \
  <(perl -p -e s,PROJECT_NAME,$PROJECT_NAME,g $SECRETS)
else
  # Optionally print broker connection commands.
  BROKER_CREDENTIALS=$(spiff merge secrets.yml | grep "^_creds" | cut -d" " -f2-)
  BROKER_URL=$(spiff merge secrets.yml | grep "^_url" | cut -d" " -f2-)

  echo ""
  echo -e "${BLUE}Create a broker:${NC}"
  echo ""
  echo "cf create-service-broker \\"
  echo "  $BROKER_CREDENTIALS \\"
  echo "  $BROKER_URL"
  echo ""
  echo -e "${BLUE}Update a broker:${NC}"
  echo ""
  echo "cf update-service-broker \\"
  echo "  $BROKER_CREDENTIALS \\"
  echo "  $BROKER_URL"
  echo ""
fi
