#!/bin/bash

# Bash script for Magento 2 Command Line Tool
# @FCMPT JA1719-S22S v5
# @LCMPT MY1019-S11S
# @VCMPT JN1319-S24S
# @version: 5.5.20190624
# @SignatureDeployReindexV5
###############################################################################
## UPDATING THIS SCRIPT:
## To update the script follow these steps:-
##
## 1. Download the updater script in the same folder where this file is, with
##    "wget" or whatever method you want to use:
##    $ wget http://devcorder.com/scripts/DeployReindex/updaterDI.sh
## 2. Make the downloaded "updaterDI.sh" file executable:
##    $ chmod u+rx updaterDI.sh
## 3. Run the "updaterDI.sh" to update this script to the latest version as:
##    $ ./updaterDI.sh
###############################################################################
## INSTRUCTIONS:
##
## Make this script executable; Run command as:- chmod u+rx <this_file>
## and run the script as:- ./<this_file> -{option} {argument}
## Or use "bash" command to execute, as:- bash <this_file> -{option} {argument}
###############################################################################
## GETTING ERROR "/bin/bash^M: bad interpreter: No such file or directory"?:
##
## Editing this script in "Windows" or "Mac" or in "Netbeans editor" may cause
## errors like so while running the script. There are some command line tools
## available in linux like "dos2unix" to resolve the issue or you can resolve
## it by saving the file in "Vim editor" as ":set ff=unix".
###############################################################################
## "LANGUAGES" Directive:
##
## This script automatically detects the installed language/s in your Magento
## store but it is better to define them here, because sometimes detecting
## langauages automatically might cause errors while running the command.
##
## Also you can run the script putting space seperated ISO-639 language codes
## as arguments with "-d" or "--deploy" option. In this case the value of 
## "LANGUAGES" will be ignored and the arguments given by you in command line
## will be in use during running the command.
##
## Put all of the installed language/s of your store here (space seperated
## ISO-639 language codes).
LANGUAGES=""
#LANGUAGES="fr_FR de_DE"
###############################################################################
## If you are getting "php memory limit" errors, this section may help. You can
## increase "memory_limit" value from here-
## Note:- Sometimes it doesn't work.
##        This extends "memory_limit" till the command ends.
MEMORY_LIMIT=""
#MEMORY_LIMIT="2048M"
#MEMORY_LIMIT="2G"
###############################################################################
## Change the "PHP" variable's value with your supported php binary file if 
## simple 'php' command does not work. Here are some examples of most common
## php binaries:-
##
PHP=php
#PHP=php54
#PHP=/usr/local/bin/ea-php56
#PHP=/opt/cpanel/ea-php7.0/root/usr/bin/php
#PHP=/opt/plesk/php/7.1/bin/php
#PHP=/opt/alt/php72/usr/bin/php
#PHP=/usr/bin/php7.0
#PHP=/opt/imh/imh-php56/root/usr/bin/php
###############################################################################
## Magento 2 CLI file location:
M2CLI="bin/magento"
###############################################################################
## Manage Ownerships: (1|on|true or 0|off|false)
## You must be root to change the ownerships.
ISACTIVE_OWNERS=0
## You must define ownership directives if have enabled "ISACTIVE_OWNERS"
## Ownership Directives: (work only if "ISACTIVE_OWNERS" directive is set to 
## either of  "1, on, true").
## Define your magento directory's owner and group:
OWNER=""
GROUP=""
###############################################################################
## Manage permissions: (1|on|true or 0|off|false)
## This directive works only if "ISACTIVE_OWNERS" is disabled.
## By default permission commands do not run.
## Change its value to either of "1, on, true" if you want to set permissions.
ISACTIVE_PERMS=0
## Permission Directives: (work only if "ISACTIVE_PERMS" directive is set to 
## either of  "1, on, true").
## What permissions you want to give, define here: (default is "644" for files
## and "755" for directories)
## "F_PERM" for file permissions, "D_PERM" for directory permissions.
F_PERM=""
D_PERM=""
###############################################################################
## Debug Mode: For developers, (1|on|true or 0|off|false)
DEBUG_MODE=0
###############################################################################
## Exit On Errors: (1|on|true or 0|off|false)
## If enabled, script will stop on any error occurs.
## This directive will not work if "DEBUG_MODE" is enabled.
ISEXIT=0
###############################################################################
## Clean and Flush Cache: (1|on|true or 0|off|false)
## To run the commands "bin/magento cache:clean" and "bin/magento cache:flush"
## with some set of magento commands, set this directive to either of 
## "1, on, true", default value is "1".
FLUSH_CACHE=1
###############################################################################
## Older "bash" compatibility:
## Leave this uncomment if your bash is lower than 4.x version.
shopt -s extglob
###############################################################################
###############################################################################
## CORE FUNCTIONS AHEAD, DO NOT CHANGE
###############################################################################

setEnable() {
   if [[ "$DEBUG_MODE" = @(1|on|On|ON|true|True|TRUE) ]]; then
      set -x
   elif [[ "$ISEXIT" = @(1|on|On|ON|true|True|TRUE) ]]; then
      set -e
   else
      :
   fi
}

setDisable() {
   if [[ "$DEBUG_MODE" = @(1|on|On|ON|true|True|TRUE) ]]; then
      set +x
   elif [[ "$ISEXIT" = @(1|on|On|ON|true|True|TRUE) ]]; then
      set +e
   else
      :
   fi
}

flushCache() {
   if [[ "$FLUSH_CACHE" = @(1|on|On|ON|true|True|TRUE) ]]; then
      $PHP $ML $M2CLI cache:clean
      $PHP $ML $M2CLI cache:flush
   fi
}

isExistCLI() {
   if [[ ! -f "$M2CLI" ]]; then
      echo "${_RED}Error: File \"$M2CLI\" not found.${_RESET}"; exit 1
   fi
}

defineDirectory() {
   isExistCLI
   if [[ $M2CLI = "magento" ]]; then
      _DIR=".."
   elif [[ $M2CLI = "bin/magento" ]]; then
      _DIR="."
   elif [[ $M2CLI = "/bin/magento" ]]; then  #<-- This condition is deprecated though and may never happens.
      _DIR="/"
   else
      _DIR=$(echo $M2CLI | rev | cut -c 13- | rev)
   fi
}

defineMemoryLimit() {
   if [[ -z "$MEMORY_LIMIT" ]]; then
      ML=""
   else
      ML="-d memory_limit=$MEMORY_LIMIT"
   fi
}

defineLanguage() {
   defineDirectory
   if [[ -n "$2" ]]; then
      _CONDITION=1
      LANGUAGES=""
      while [ -n "$2" ]; do
         LANGUAGES="$LANGUAGES $2"
         shift
      done
   elif [[ ! -n "$LANGUAGES" || -z "$LANGUAGES" ]]; then
      _CONDITION=2
      if [[ -d "$_DIR/pub/static/frontend" && -d "$_DIR/pub/static/adminhtml" ]]; then
         FRONT_OR_ADMIN=1
         LANGUAGES1=$(ls -lA $_DIR/pub/static/frontend/*/*/ |  awk '{print $9}' | sort | uniq | awk NF | tr '\r\n' ' ')
         LANGUAGES2=$(ls -lA $_DIR/pub/static/adminhtml/*/*/ |  awk '{print $9}' | sort | uniq | awk NF | tr '\r\n' ' ')
         LANGUAGES=$(echo "$LANGUAGES1 $LANGUAGES2" | tr ' ' '\n' | sort | uniq | xargs)
      elif [[ -d "$_DIR/pub/static/frontend" && ! -d "$_DIR/pub/static/adminhtml" ]]; then
         LANGUAGES=$(ls -lA $_DIR/pub/static/frontend/*/*/ |  awk '{print $9}' | sort | uniq | awk NF | tr '\r\n' ' ')
      elif [[ ! -d "$_DIR/pub/static/frontend" && -d "$_DIR/pub/static/adminhtml" ]]; then
         LANGUAGES=$(ls -lA $_DIR/pub/static/adminhtml/*/*/ |  awk '{print $9}' | sort | uniq | awk NF | tr '\r\n' ' ')
      else
         LANGUAGES="en_US"
      fi
   else
      :
   fi
}

definePermissionDirectives() {
   if [[ -n "$F_PERM" && -n "$D_PERM" ]]; then
      if [[ ! -z "$F_PERM" && -z "$D_PERM" ]]; then
         D_PERM=$F_PERM
      elif [[ -z "$F_PERM" && ! -z "$D_PERM" ]]; then
         F_PERM=$D_PERM
      elif [[ -z "$F_PERM" && -z "$D_PERM" ]]; then
         F_PERM=644
         D_PERM=755
      else
         :
      fi
   elif [[ -n "$F_PERM" && ! -n "$D_PERM" ]]; then
      if [[ ! -z "$F_PERM" ]]; then
         D_PERM=$F_PERM
      else
         F_PERM=644
         D_PERM=755
      fi
   elif [[ ! -n "$F_PERM" && -n "$D_PERM" ]]; then
      if [[ ! -z "$D_PERM" ]]; then
         F_PERM=$D_PERM
      else
         F_PERM=644
         D_PERM=755
      fi
   else
      F_PERM=644
      D_PERM=755
   fi
}

ownerships() {
   WHOAMI=$(whoami)
   if [[ "$WHOAMI" != "root" ]]; then
      echo; echo "${_ORANGE}Warning: In order to change the \"ownerships\" you must become \"root\".
The operation of changing \"ownerships\" has not been performed.${_RESET}" >&2
      exit 1
   fi
   if [[ "$1" = @(-O|--set-ownerships|--set-ownership) && -n "$2" ]]; then
      ERR_COUNT=0
      while [ -n "$2" ]; do
         if [[ -d "$2" || -f "$2" ]]; then
            if [[ ! -z "$OWNER" && ! -z "$GROUP" ]]; then
               chown -R $OWNER:$GROUP $2
            elif [[ -z "$OWNER" && ! -z "$GROUP" ]]; then
               chown -R :$GROUP $2
            elif [[ ! -z "$OWNER" && -z "$GROUP" ]]; then
               chown -R $OWNER $2
            else
               echo "${_RED}Error: You haven't defined ownership directives.${_RESET}" >&2
               exit 1
            fi
         else
            echo "${_RED}Error: Directory or File \"$2\" doesn't exist${_RESET}" >&2
            ERR_COUNT=$(($ERR_COUNT + 1))
         fi
         shift
      done
      [[ "$ERR_COUNT" -gt 0 ]] && exit 1
   else
      if [[ ! -z "$OWNER" && ! -z "$GROUP" ]]; then
         if [[ -d "$_DIR/generated" ]]; then
            chown -R $OWNER:$GROUP $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/pub/static/ $_DIR/generated/
         else
            chown -R $OWNER:$GROUP $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/var/generation/ $_DIR/var/di/ $_DIR/pub/static/
         fi
      elif [[ -z "$OWNER" && ! -z "$GROUP" ]]; then
         if [[ -d "$_DIR/generated" ]]; then
            chown -R :$GROUP $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/pub/static/ $_DIR/generated/
         else
            chown -R :$GROUP $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/var/generation/ $_DIR/var/di/ $_DIR/pub/static/
         fi
      elif [[ ! -z "$OWNER" && -z "$GROUP" ]]; then
         if [[ -d "$_DIR/generated" ]]; then
            chown -R $OWNER $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/pub/static/ $_DIR/generated/
         else
            chown -R $OWNER $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/var/generation/ $_DIR/var/di/ $_DIR/pub/static/
         fi
      else
         echo "${_RED}Error: You haven't defined ownership directives.${_RESET}" >&2
         exit 1
      fi
   fi
}

permissions() {
   if [[ "$1" = @(-P|--set-permissions|--set-permission) && -n "$2" ]]; then
      ERR_COUNT=0
      while [ -n "$2" ]; do
         if [[ -d "$2" || -f "$2" ]]; then
            if [[ $F_PERM = $D_PERM ]]; then
               chmod -R $F_PERM $2
            else
               find $2 -type f -exec chmod $F_PERM {} \;
               find $2 -type d -exec chmod $D_PERM {} \;
            fi
         else
            echo "${_RED}Error: Directory or File \"$2\" doesn't exist${_RESET}" >&2
            ERR_COUNT=$(($ERR_COUNT + 1))
         fi
      shift
      done
      [[ "$ERR_COUNT" -gt 0 ]] && exit 1
   else
      if [[ $F_PERM = $D_PERM ]]; then
         if [[ -d "$_DIR/generated" ]]; then
            chmod -R $F_PERM $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/pub/static/ $_DIR/generated/
         else
           chmod -R $F_PERM $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/var/generation/ $_DIR/var/di/ $_DIR/pub/static/
         fi
      else
         if [[ -d "$_DIR/generated" ]]; then
            find $_DIR/var/cache/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/cache/ -type d -exec chmod $D_PERM {} \;
            find $_DIR/var/page_cache/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/page_cache/ -type d -exec chmod $D_PERM {} \;
            find $_DIR/pub/static/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/pub/static/ -type d -exec chmod $D_PERM {} \;
            find $_DIR/generated/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/generated/ -type d -exec chmod $D_PERM {} \;
         else 
            find $_DIR/var/cache/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/cache/ -type d -exec chmod $D_PERM {} \;
            find $_DIR/var/page_cache/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/page_cache/ -type d -exec chmod $D_PERM {} \;
            find $_DIR/var/generation/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/generation/ -type d -exec chmod $D_PERM {} \;
            find $_DIR/var/di/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/di/ -type d -exec chmod $D_PERM {} \;
            find $_DIR/pub/static/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/pub/static/ -type d -exec chmod $D_PERM {} \;
         fi
      fi
   fi
}

permissionAndOwnership1() {
   if [[ "$ISACTIVE_OWNERS" = @(1|on|On|oN|ON|true|True|TRUE) ]]; then
      ownerships
   elif [[ "$ISACTIVE_PERMS" = @(1|on|On|oN|ON|true|True|TRUE) ]]; then
      definePermissionDirectives
      permissions
   else
      :
   fi
}

permissionAndOwnership2() {
   if [[ "$ISACTIVE_OWNERS" = @(1|on|On|oN|ON|true|True|TRUE) ]]; then
      WHOAMI=$(whoami)
      if [[ "$WHOAMI" != "root" ]]; then
          echo; echo "${_ORANGE}Warning: In order to change the \"ownerships\" you must become \"root\".
The operation of changing \"ownerships\" has not been performed.${_RESET}" >&2
      exit 1
      fi
      if [[ -d "$_DIR/generated" ]]; then
         if [[ ! -z "$OWNER" && ! -z "$GROUP" ]]; then
            chown -R $OWNER:$GROUP $_DIR/var/cache/ $_DIR/var/page_cache/
         elif [[ -z "$OWNER" && ! -z "$GROUP" ]]; then
            chown -R :$GROUP $_DIR/var/cache/ $_DIR/var/page_cache/
         elif [[ ! -z "$OWNER" && -z "$GROUP" ]]; then
            chown -R $OWNER $_DIR/var/cache/ $_DIR/var/page_cache/
         else
            echo "${_RED}Error: You haven't defined ownership directives.${_RESET}" >&2
            exit 1
         fi
      else
         if [[ ! -z "$OWNER" && ! -z "$GROUP" ]]; then
            chown -R $OWNER:$GROUP $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/var/generation/ $_DIR/var/di/
         elif [[ -z "$OWNER" && ! -z "$GROUP" ]]; then
            chown -R :$GROUP $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/var/generation/ $_DIR/var/di/
         elif [[ ! -z "$OWNER" && -z "$GROUP" ]]; then
            chown -R $OWNER $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/var/generation/ $_DIR/var/di/
         else
            echo "${_RED}Error: You haven't defined ownership directives.${_RESET}" >&2
            exit 1
         fi
      fi
   elif [[ "$ISACTIVE_PERMS" = @(1|on|On|oN|ON|true|True|TRUE) ]]; then
      definePermissionDirectives
      if [[ $F_PERM = $D_PERM ]]; then
         if [[ -d "$_DIR/generated" ]]; then
            chmod -R $F_PERM $_DIR/var/cache/ $_DIR/var/page_cache/
         else
            chmod -R $F_PERM $_DIR/var/cache/ $_DIR/var/page_cache/ $_DIR/var/generation/ $_DIR/var/di/
         fi
      else
         if [[ -d "$_DIR/generated" ]]; then
            find $_DIR/var/cache/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/cache/ -type d -exec chmod $D_PERM {} \;
            find $_DIR/var/page_cache/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/page_cache/ -type d -exec chmod $D_PERM {} \;
         else
            find $_DIR/var/cache/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/cache/ -type d -exec chmod $D_PERM {} \;
            find $_DIR/var/page_cache/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/page_cache/ -type d -exec chmod $D_PERM {} \;
            find $_DIR/var/generation/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/generation/ -type d -exec chmod $D_PERM {} \;
            find $_DIR/var/di/ -type f -exec chmod $F_PERM {} \;
            find $_DIR/var/di/ -type d -exec chmod $D_PERM {} \;
         fi
      fi
   else
      :
   fi
}

deployer() {
   if [[ -d "$_DIR/generated" ]]; then
      _FORCE="-f"
   else
      _FORCE=""
   fi
   
   if [[ "$_CONDITION" = 1 ]]; then
      $PHP $ML $M2CLI setup:static-content:deploy $LANGUAGES $_FORCE
   elif [[ "$_CONDITION" = 2 ]]; then
      if [[ "$FRONT_OR_ADMIN" = 1 ]]; then
         $PHP $ML $M2CLI setup:static-content:deploy $LANGUAGES1 $_FORCE --area frontend
         $PHP $ML $M2CLI setup:static-content:deploy $LANGUAGES2 $_FORCE --area adminhtml
      else
         $PHP $ML $M2CLI setup:static-content:deploy $LANGUAGES $_FORCE
      fi
   else
      $PHP $ML $M2CLI setup:static-content:deploy $LANGUAGES $_FORCE
   fi
}

adminUri() {
   isExistCLI
   defineMemoryLimit
   $PHP $ML $M2CLI info:adminuri
}

setMode() {
   isExistCLI
   defineMemoryLimit
   if [[ ! -n "$2" ]]; then
      $PHP $ML $M2CLI deploy:mode:show
   elif [[ "$2" = @(developer|dev) ]]; then
      $PHP $ML $M2CLI deploy:mode:set developer
   elif [[ "$2" = @(production|pro|prod) ]]; then
      $PHP $ML $M2CLI deploy:mode:set production
   elif [[ "$2" = @(default|def) ]]; then
      $PHP $ML $M2CLI deploy:mode:set default
   else
      echo "${_RED}Error: Unknown Argument.${_RESET}" >&2
      echo "${_BLUE_GREEN}Use one of (developer|production|default).${_RESET}"; exit 1
   fi
}

createAdmin() {
   isExistCLI
   defineMemoryLimit
   read -p "${_GREEN}First Name : ${_RESET}" FIRSTNAME
   read -p "${_GREEN}Last Name : ${_RESET}" LASTNAME
   read -p "${_GREEN}E-mail address : ${_RESET}" EMAIL
   read -p "${_GREEN}Choose your Username : ${_RESET}" USERNAME
   read -p "${_GREEN}Choose your Password (HIDDEN) : ${_RESET}" -s PASSWORD1
   echo; read -p "${_GREEN}Re-Enter Password (HIDDEN) : ${_RESET}" -s PASSWORD2
   echo;

   if [[ -z "$FIRSTNAME" || -z "$LASTNAME" || -z "$EMAIL" || -z "$USERNAME" || -z "$PASSWORD1" ]]; then
      echo; echo "${_RED}Error: Cannot use empty field${_RESET}" >&2
      exit 1
   fi
   if [[ "$PASSWORD1" != "$PASSWORD2" ]]; then
      echo; echo "${_RED}Error: Password does not match${_RESET}" >&2
      exit 1
   fi

   echo; echo "${_GREEN}All seems OK!${_RESET}"
   read -p "${_GREEN}Want to continue [Y/n] : ${_RESET}" ANS
   if [[ "$ANS" != @(n|N|no|NO|No|nO) ]]; then
      $PHP $ML $M2CLI admin:user:create --admin-user="$USERNAME" --admin-password=$PASSWORD2 --admin-email="$EMAIL" --admin-firstname="$FIRSTNAME" --admin-lastname="$LASTNAME"
      if [[ "$?" = "0" ]]; then
         read -p "${_GREEN}Want to display your \"Username\" and \"Password\" [y|N] : ${_RESET}" ANS
         if [[ "$ANS" = @(y|Y|yes|Yes|yEs|yeS|YEs|yES|YeS|YES) ]]; then
            echo; echo "${_GREEN}Username :${_RESET} $USERNAME
${_GREEN}Password :${_RESET} $PASSWORD2"
         else
            exit
         fi
      fi
   else
      exit
   fi
}

createBackup() {
   isExistCLI
   defineMemoryLimit
   if [[ -n "$2" && "$2" = @(a|all) ]]; then
      $PHP $ML $M2CLI setup:backup --code --media --db
   elif [[ -n "$2" && "$2" = @(c|code|codebase) ]]; then
      if [[ -n "$3" && "$3" = @(d|db|data|database) ]]; then
         if [[ -n "$4" && "$4" = @(m|media) ]]; then
            $PHP $ML $M2CLI setup:backup --code --db --media
         else
            $PHP $ML $M2CLI setup:backup --code --db
         fi
      elif [[ -n "$3" && "$3" = @(m|media) ]]; then
         if [[ -n "$4" && "$4" = @(d|db|data|database) ]]; then
            $PHP $ML $M2CLI setup:backup --code --media --db
         else
            $PHP $ML $M2CLI setup:backup --code --media
         fi
      else
         $PHP $ML $M2CLI setup:backup --code
      fi
   elif [[ -n "$2" && "$2" = @(d|db|data|database) ]]; then
      if [[ -n "$3" && "$3" = @(c|code|codebase) ]]; then
         if [[ -n "$4" && "$4" = @(m|media) ]]; then
            $PHP $ML $M2CLI setup:backup --db --code --media
         else
            $PHP $ML $M2CLI setup:backup --db --code
         fi
      elif [[ -n "$3" && "$3" = @(m|media) ]]; then
         if [[ -n "$4" && "$4" = @(c|code|codebase) ]]; then
            $PHP $ML $M2CLI setup:backup --db --media --code
         else
            $PHP $ML $M2CLI setup:backup --db --media
         fi
      else
         $PHP $ML $M2CLI setup:backup --db
      fi
   elif [[ -n "$2" && "$2" = @(m|media) ]]; then
      if [[ -n "$3" && "$3" = @(c|code|codebase) ]]; then
         if [[ -n "$4" && "$4" = @(d|db|data|database) ]]; then
            $PHP $ML $M2CLI setup:backup --media --code --db
         else
            $PHP $ML $M2CLI setup:backup --media --code
         fi
      elif [[ -n "$3" && "$3" = @(d|db|data|database) ]]; then
         if [[ -n "$4" && "$4" = @(c|code|codebase) ]]; then
            $PHP $ML $M2CLI setup:backup --media --db --code
         else
            $PHP $ML $M2CLI setup:backup --media --db
         fi
      else
         $PHP $ML $M2CLI setup:backup --media
      fi
   elif [[ ! -n "$2" ]]; then
      echo "${_RED}Error: Argument Required.${_RESET}" >&2
      echo "${_BLUE_GREEN}Use one or some of (db|code|media|all).${_RESET}"; exit 1
   else
      echo "${_RED}Error: Unknown Argument.${_RESET}" >&2
      echo "${_BLUE_GREEN}Use one or some of (db|code|media|all).${_RESET}"; exit 1
   fi
}

_cron() {
   defineDirectory
   defineMemoryLimit
   if [[ ! -n "$2" ]]; then
      echo "1. cron:run"
      $PHP $ML $M2CLI cron:run | grep -v "Ran jobs by schedule."
      echo "2. cron.php"
      $PHP $ML $_DIR/update/cron.php
      echo "3. setup:cron:run"
      $PHP $ML $M2CLI setup:cron:run
   elif [[ "$2" = @(install|Install|INSTALL) ]]; then
      IS_AVAIL=$($PHP $ML $M2CLI list | grep "cron:install")
      if [[ ! -z "$IS_AVAIL" ]]; then
         $PHP $ML $M2CLI cron:install
      else
         echo "${_ORANGE}This option is not available for your Magento Version.${_RESET}"; exit 1
      fi
   elif [[ "$2" = @(remove|Remove|REMOVE) ]]; then
      IS_AVAIL=$($PHP $ML $M2CLI list | grep "cron:remove")
      if [[ ! -z "$IS_AVAIL" ]]; then
         $PHP $ML $M2CLI cron:remove
      else
         echo "${_ORANGE}This option is not available for your Magento Version.${_RESET}"; exit 1
      fi
   else
      echo "${_RED}Error: Unknown Argument.${_RESET}" >&2
      echo "${_BLUE_GREEN}Use one of (install|remove).${_RESET}"; exit 1
   fi
}

_status() {
   isExistCLI
   defineMemoryLimit
   if [[ ! -n "$2" ]]; then
      echo "${_RED}Error: Argument Required.${_RESET}" >&2
      exit 1
   elif [[ "$2" = @(cache|Cache|CACHE) ]]; then
      $PHP $ML $M2CLI cache:status
   elif [[ "$2" = @(maintenence|Maintenance|MAINTENANCE|main|Main|MAIN) ]]; then
      $PHP $ML $M2CLI maintenance:status
   elif [[ "$2" = @(module|Module|MODULE|modules|Modules|MODULES) ]]; then
      $PHP $ML $M2CLI module:status
   else
      echo "${_RED}Error: Unknown Argument.${_RESET}" >&2
      echo "${_BLUE_GREEN}Use one of (cache|maintenance|module).${_RESET}"; exit 1
   fi
}

_enable() {
   isExistCLI
   defineMemoryLimit
   if [[ ! -n "$2" ]]; then
      echo "${_RED}Error: Argument Required.${_RESET}" >&2
      exit 1
   elif [[ "$2" = @(cache|Cache|CACHE) ]]; then
      $PHP $ML $M2CLI cache:enable
   elif [[ "$2" = @(maintenance|Maintenance|MAINTENANCE|main|Main|MAIN) ]]; then
      if [[ -n "$3" ]]; then
         _IP=""
         while [ -n "$3" ]; do
            _IP="$_IP $3"
            shift
         done
         $PHP $ML $M2CLI maintenance:enable
         $PHP $ML $M2CLI maintenance:allow-ips $_IP
      else
         $PHP $ML $M2CLI maintenance:enable
      fi
   else
      $PHP $ML $M2CLI module:enable $2
   fi
}

_disable() {
   isExistCLI
   defineMemoryLimit
   if [[ ! -n "$2" ]]; then
      echo "${_RED}Error: Argument Required.${_RESET}" >&2
      exit 1
   elif [[ "$2" = @(cache|Cache|CACHE) ]]; then
      $PHP $ML $M2CLI cache:disable
   elif [[ "$2" = @(maintenance|Maintenance|MAINTENANCE|main|Main|MAIN) ]]; then
      $PHP $ML $M2CLI maintenance:disable
   else
      $PHP $ML $M2CLI module:disable $2
   fi
}

listCommands() {
   isExistCLI
   defineMemoryLimit
   $PHP $ML $M2CLI list
}

howToUpdate() {
   echo "${_GREEN}To update the script follow these steps:-

 1. Download the updater script in the same folder where this file is, with
    \"wget\" or whatever method you want to use:
    $ wget http://devcorder.com/scripts/DeployReindex/updaterDI.sh
 2. Make the downloaded \"updaterDI.sh\" file executable:
    $ chmod u+rx updaterDI.sh
 3. Run the \"updaterDI.sh\" to update this script to the latest version as:
    $ ./updaterDI.sh${_RESET}"
}

listStoreAndWebsite() {
   isExistCLI
   defineMemoryLimit
   if [[ "$1" = "--store" ]]; then
      IS_AVAIL=$($PHP $ML $M2CLI list | grep "store:list")
      if [[ ! -z "$IS_AVAIL" ]]; then
         $PHP $ML $M2CLI store:list
      else
         echo "${_ORANGE}This option is not available for your Magento Version.${_RESET}"; exit
      fi
   else
      IS_AVAIL=$($PHP $ML $M2CLI list | grep "store:website:list")
      if [[ ! -z "$IS_AVAIL" ]]; then
         $PHP $ML $M2CLI store:website:list
      else
         echo "${_ORANGE}This option is not available for your Magento Version.${_RESET}"; exit
      fi
   fi
}

indexerAll() {
   isExistCLI
   defineMemoryLimit
   if [[ ! -n "$2" ]]; then
      echo "${_RED}Error: Argument Required.${_RESET}" >&2
      exit 1
   elif [[ "$2" = "info" ]]; then
      $PHP $ML $M2CLI indexer:info
   elif [[ "$2" = "reset" ]]; then
      if [[ -n "$3" ]]; then
         $PHP $ML $M2CLI indexer:reset $3
      else
         $PHP $ML $M2CLI indexer:reset
      fi
   elif [[ "$2" = "status" ]]; then
      if [[ -n "$3" ]]; then
         $PHP $ML $M2CLI indexer:status $3
      else
         $PHP $ML $M2CLI indexer:status
      fi
   elif [[ "$2" = "show-mode" ]]; then
      if [[ -n "$3" ]]; then
         $PHP $ML $M2CLI indexer:show-mode $3
      else
         $PHP $ML $M2CLI indexer:show-mode
      fi
   elif [[ "$2" = "realtime" ]]; then
      if [[ -n "$3" ]]; then
         $PHP $ML $M2CLI indexer:set-mode realtime $3
      else
         $PHP $ML $M2CLI indexer:set-mode realtime
      fi
   elif [[ "$2" = "schedule" ]]; then
      if [[ -n "$3" ]]; then
         $PHP $ML $M2CLI indexer:set-mode schedule $3
      else
         $PHP $ML $M2CLI indexer:set-mode schedule
      fi
   else
      echo "${_RED}Error: Unknown Argument.${_RESET}" >&2
      echo "${_BLUE_GREEN}Use one of (info|reset|status|show-mode|realtime|schedule).${_RESET}"; exit 1
   fi
}

printDirectives() {
   echo "LANGUAGES=${_GREEN}$LANGUAGES${_RESET}
MEMORY_LIMIT=${_GREEN}$MEMORY_LIMIT${_RESET}
PHP=${_GREEN}$PHP${_RESET}
M2CLI=${_GREEN}$M2CLI${_RESET}
ISACTIVE_OWNERS=${_GREEN}$ISACTIVE_OWNERS${_RESET}
   OWNER=${_GREEN}$OWNER${_RESET}
   GROUP=${_GREEN}$GROUP${_RESET}
ISACTIVE_PERMS=${_GREEN}$ISACTIVE_PERMS${_RESET}
   F_PERM=${_GREEN}$F_PERM${_RESET}
   D_PERM=${_GREEN}$D_PERM${_RESET}
DEBUG_MODE=${_GREEN}$DEBUG_MODE${_RESET}
ISEXIT=${_GREEN}$ISEXIT${_RESET}
FLUSH_CACHE=${_GREEN}$FLUSH_CACHE${_RESET}"
}

## FUNCTIONS FOR AVAILABLE OPTIONS:

printHelp() {
   echo "${_GREEN}Usage:
   ./$(basename "$0") -<option> <argument>

All options to use:

   -A, --admin-uri                Displays the Magento's admin URI
   -B, --backup <code|data|media|all>
                                  Makes backup of Magento codebase, database, media
                                  or all of them, Can use more than one space seprated 
                                  options as arguments
   -C, --compile                  Runs setup:di:compile
   -c, -f, --clean, --flush       Flushes caches
   --create-admin                 Creates admin user for backend
   -D, --disable <cache|maintenance|\"module_name\">
                                  Disables Module, Cache, Maintenance Mode
   -d, --deploy <language>        Runs setup:static-content:deploy with setup:upgrade
   -do, --deploy-only <language>  Runs setup:static-content:deploy only
   -E, --enable <cache|maintenance|\"module_name\">
                                  Enables Module, Cache, Maintenance Mode
                                  For maintenance, put space seperated IPs to allow
   -h, --help                     Prints this message
   -i, --reindex <indexer>        Reindexes the indexer (indexer:reindex)
                                  Without indexer argument (reindexes all tables)
   --indexer <info|reset|status|show-mode> <indexer>
                                  Performs various functions for the indexer
                                  Without argument performs for all indexers
   -L, --list                     Lists all magento commands
   -l, --language                 Prints the language pack/s you have installed in your
                                  magento store
   -m, --mode <mode>              Sets magento mode either developer or production
                                  Using without argument shows current mode
   -O, --set-ownerships <dir>     Sets ownerships recursively
   -P, --set-permissions <dir>    Sets permissions recursively
   -p, --print-directives         Prints directive values of this script
   -S, --status <cache|maintenance|module>
                                  Shows status of Module, Cache, Maintenance Mode
   -s, --cron <install|remove>    Installs and removes Magento cron jobs
                                  Without argument runs Magento cron jobs
   --store                        Lists all configured stores
   -U, --update-di                Prints the method to update this file to the latest
                                  version
   -u, --upgrade                  Runs setup:upgrade
   -V, --magento-version          Prints Magento version
   -v, --version                  Prints version
   --website                      Lists all configured websites


e.g. Run command for indexing and deployment of static contents with 
     Arabic and German languages:
     ~$ ./$(basename "$0") -di ar_SA de_DE

     If you don't have any language pack installed, skip the language option.${_RESET}"
}

proc1FC() {
   local PROC_NAME="Flush-Cache"
   defineDirectory
   defineMemoryLimit
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Starts${_RESET}"
   $PHP $ML $M2CLI cache:clean
   $PHP $ML $M2CLI cache:flush
   permissionAndOwnership2
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Ends${_RESET}"
}

proc2C() {
   local PROC_NAME="Compile"
   isExistCLI
   defineMemoryLimit
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Starts${_RESET}"
   $PHP $ML $M2CLI setup:di:compile
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Ends${_RESET}"
}

proc3D() {
   local PROC_NAME="Deploy"
   defineMemoryLimit
   defineLanguage "$@"
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Starts${_RESET}"
   $PHP $ML $M2CLI setup:upgrade
   deployer
   flushCache
   permissionAndOwnership1
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Ends${_RESET}"
}

proc4DO() {
   local PROC_NAME="Deploy-Only"
   defineMemoryLimit
   defineLanguage "$@"
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Starts${_RESET}"
   deployer
   flushCache
   permissionAndOwnership1
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Ends${_RESET}"
}

proc5I() {
   local PROC_NAME="Reindex"
   defineDirectory
   defineMemoryLimit
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Starts${_RESET}"
   $PHP $ML $M2CLI indexer:reindex $2
   flushCache
   permissionAndOwnership2
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Ends${_RESET}"
}

proc6L() {
   defineLanguage "$@"
   echo "${_GREEN}Language/s: $LANGUAGES${_RESET}"
}

proc7U() {
   local PROC_NAME="Upgrade"
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Starts${_RESET}"
   defineDirectory
   defineMemoryLimit
   $PHP $ML $M2CLI setup:upgrade
   flushCache
   permissionAndOwnership1
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Ends${_RESET}"
}

proc8MV() {
   isExistCLI
   defineMemoryLimit
   $PHP $ML $M2CLI --version
}

proc9SO() {
   if [[ -n "$2" ]]; then
      ownerships "$@"
   else
      defineDirectory
      ownerships "$@"
   fi
}

proc10SP() {
   if [[ -n "$2" ]]; then
      definePermissionDirectives
      permissions "$@"
   else
      defineDirectory
      definePermissionDirectives
      permissions "$@"
   fi
}

jointProcess1CD() {
   local PROC_NAME="Compile-Deploy"
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Starts${_RESET}"
   defineMemoryLimit
   defineLanguage "$@"
   $PHP $ML $M2CLI setup:di:compile
   deployer
   flushCache
   permissionAndOwnership1
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Ends${_RESET}"
}

jointProcess2CDI() {
   local PROC_NAME="Compile-Deploy-Reindex"
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Starts${_RESET}"
   defineMemoryLimit
   defineLanguage "$@"
   $PHP $ML $M2CLI setup:di:compile
   deployer
   $PHP $ML $M2CLI indexer:reindex
   flushCache
   permissionAndOwnership1
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Ends${_RESET}"
}

jointProcess3DI() {
   local PROC_NAME="Deploy-Reindex"
   defineMemoryLimit
   defineLanguage "$@"
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Starts${_RESET}"
   $PHP $ML $M2CLI setup:upgrade
   deployer
   $PHP $ML $M2CLI indexer:reindex
   flushCache
   permissionAndOwnership1
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Ends${_RESET}"
}

jointProcess4UCD() {
   local PROC_NAME="Upgrade-Compile-Deploy"
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Starts${_RESET}"
   defineMemoryLimit
   defineLanguage "$@"
   $PHP $ML $M2CLI setup:upgrade
   $PHP $ML $M2CLI setup:di:compile
   deployer
   flushCache
   permissionAndOwnership1
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Ends${_RESET}"
}

jointProcess5UCDI() {
   local PROC_NAME="Upgrade-Compile-Deploy-Reindex"
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Starts${_RESET}"
   defineMemoryLimit
   defineLanguage "$@"
   $PHP $ML $M2CLI setup:upgrade
   $PHP $ML $M2CLI setup:di:compile
   deployer
   $PHP $ML $M2CLI indexer:reindex
   flushCache
   permissionAndOwnership1
   echo "${_GREEN}$(date +%H:%M:%S) $PROC_NAME: Ends${_RESET}"
}

## MAIN FUNCTION:

_processor() {
   case "$1" in
      -A|--admin-uri)          adminUri;;
      -B|--backup)             createBackup "$@";;
      -C|--compile)            proc2C;;	
      -c|-f|--clean|--flush)   proc1FC;;
      --create-admin)          createAdmin;;
      -D|--disable)            _disable "$@";;
      -d|--deploy|-ud|-du)     proc3D "$@";;
      -do|--deploy-only)       proc4DO "$@";;
      -E|--enable)             _enable "$@";;
      -h|--help)               printHelp;;
      -i|--reindex)            proc5I "$@";;
      --indexer)               indexerAll "$@";;
      -L|--list)               listCommands;;
      -l|--language)           proc6L "$@";;
      -m|--mode)               setMode "$@";;
      -O|--set-ownerships|--set-ownership)
                               proc9SO "$@";;
      -P|--set-permissions|--set-permission)
                               proc10SP "$@";;
      -p|--print-directives)   printDirectives;;
      -S|--status)             _status "$@";;
      -s|--cron)               _cron "$@";;
      --store|--stores|--website|--websites)
                               listStoreAndWebsite "$@";;
      -U|--update-di)          howToUpdate;;
      -u|--upgrade)            proc7U;;
      -V|--magento-version)    proc8MV;;
      -v|--version)            echo "${_GREEN}$_VERSION${_RESET}";;
      -dC|-Cd)                 jointProcess1CD "$@";;
      -dCi|-diC|-Cid|-Cdi|-idC|-iCd)
                               jointProcess2CDI "$@";;
      -id|-di|-udi|-uid|-dui|-diu|-idu|-iud)
                               jointProcess3DI "$@";;
      -dCu|-duC|-uCd|-udC|-Cud|-Cdu)
                               jointProcess4UCD "$@";;
      -udCi|-udiC|-uCid|-uCdi|-uidC|-uiCd|-duCi|-duiC|-dCui|-dCiu|-diuC|-diCu|-Cdui|-Cdiu|-Cidu|-Ciud|-Cudi|-Cuid|-iudC|-iuCd|-iduC|-idCu|-iCud|-iCdu)
                               jointProcess5UCDI "$@";;
      *)                       echo "${_RED}Error: Unrecognized option '$1'${_RESET}" >&2
                               echo "${_BLUE_GREEN}Use \"--help\" for more info.${_RESET}"; exit 1;;
   esac
}


###############################################################################
## SCRIPT STARTS:
###############################################################################
_RESET=$(tput sgr0)
_RED=$(tput setaf 124)
_GREEN=$(tput setaf 2)
_ORANGE=$(tput setaf 166)
_BLUE_GREEN=$(tput setaf 30)
_GREY=$(tput setaf 240)

setEnable
_VERSION="version: 5.5.20190624"
_processor "$@"
setDisable
exit
###############################################################################

## Written by Faheem Jafri, System Administrator, Jaipur, Rajasthan, India
## sayedfaheemahmed@gmail.com

