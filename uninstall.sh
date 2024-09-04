

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# VARS
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'

e
echo ""

INSTALL_DIR=/usr/share/metacy

echo -e "$OKRED[>]$RESET This script will uninstall metacy and remove ALL files under $INSTALL_DIR. Are you sure you want to continue?$RESET"
read answer

rm -Rf /usr/share/metacy/
rm -f /usr/bin/metacy

echo -e "$OKBLUE[*]$RESET Done!$RESET"