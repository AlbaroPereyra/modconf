#! /bin/sh -
# The Original ModConf
# Created by Albaro Pereyra Spring 2018
app_name="ModConf";
app_version=".1";

# Global variables
file="";
delimiter="=";
key="";
value="";
force=false;
silent=false;
remove=false;

business_logic() {
  if ! $remove;
  then
    if [ -z "${appendValue}" ];
    then
      # Determine if the key has been set
      keySet=$(grep -E '^${singleQuoteEscapedKey}${singleQuoteEscapedDelimiter}.*' "$file");
      if [ -z "${keySet}" ];
      then
        add_setting;
      else
        keyValueSet=$(printf "${keySet}" | grep -E '^${singleQuoteEscapedKey}${sigleQuoteEscapedDelimiter}${singleQuoteEscapedValue}');
        if [ -z "${keyValueSet}" ];
        then
          overwrite_setting;
        else
          if ! $silent;
          then
            printf "The specified configuration has already been set.\n";
          fi
          exit 0;
        fi
      fi
    else
      append_setting;
    fi
  else
    comment_out_setting;
  fi

}

add_setting() {
  add_comment;
  printf "%s%s%s\n" "${key}" "${delimiter}" "${value}" >> "${file}";
  if ! $silent;
  then
    printf "Sucess!\n";
  fi
  exit 0;
  
}

add_comment() {
  if [ "${comment}" ];
  then
    printf "%s\n" "${comment}" >> "${file}";
  fi
  
}

overwrite_setting() {
  if ! $force;
  then
    printf "The following setting has already been set as follows:\n";
    printf "%s\n" "${keyValueSet}";
    printf "Would you like to overwrite it? (yes/no):";
    old_stty_cfg=$(stty -g)
    stty raw -echo
    overwriteOption=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty $old_stty_cfg
    if echo "$overwriteOption" | grep -iq "^n" ;
    then
      exit 0;
    fi
  fi
  sed -i .modconf.bak "s/${escapedKey}${escapedDelimiter}.*/${escapedKey}${escapedDelimiter}${escapedValue}/" "${file}";
  if ! $silent;
  then
    printf "The specified setting was overwritten\n";
  fi
  exit 0;
  
}

comment_out_setting() {
  sed -i .modconf.bak "s/${escapedKey}${escapedDelimiter}${escapedValue}/# ${escapedKey}${escapedDelimiter}${escapedValue}/" "${file}";
  if ! $silent;
  then
    printf "The specified setting was commented out.\n";
  fi
  exit 0;
  
}

append_setting() {
  escapedKeySet=$(printf "${keySet}" | sed 's/\//\\\//g');
  escapedAppendValue=$(printf "${appendValue}" | sed 's/\//\\\//g');
  sed -i .modconf.bak "s/${escapedKeySet}/${escapedKeySet}${escapedAppendValue}/" "${file}";
  if ! $silent;
  then
    printf "Sucess!\n";
  fi
  exit 0;

}

usage() {
  # optstring a:c:d:fhik:sv:
  printf "name: %s -- modify configuration file\n" "${app_name}";
  printf "\n";
  printf "synopsis: %s [-acdfhikv] [--verbose] file key value\n" "$(basename $0)";
  printf "\n";
  printf "description: monconf is the missing puzzle for creating wizards in *nix like systems.\n";
  printf "\n";
  printf "The following options are available:\n\n";
  printf "\t%s\t\t%s\n\n" "-a" "Append to option, sometimes options take more than one value in which case you can appent by suing this option.";
  printf "\t%s\t\t%s\n\n" "-c" "Comment use this option to add a comment before the modified configuration.";
  printf "\t%s\t\t%s\n\n" "-d" "Delimiter use this option to specify a delimiter this option defaults to ‘=‘.";
  printf "\t%s\t\t%s\n\n" "-f" "Force option, override current options if already set.";
  printf "\t%s\t\t%s\n\n" "-h" "Prints this usage guide.";
  printf "\t%s\t\t%s\n\n" "-k" "Key use this option to specify the key.";
  printf "\t%s\t\t%s\n\n" "-r" "Remove comments out the setting specified.";
  printf "\t%s\t\t%s\n\n" "-s" "Silent mode doesn't even print on error.";
  printf "\t%s\t\t%s\n\n" "-v" "Prints current key value pair if it exists, same as not entering a value.";
  
}

if [ $# == 0 ];
then
  usage;
  exit 0;
fi

# Evaluate ARGs and Global variables
while getopts :a:c:d:fhk:rsv: OPT; do
  case $OPT in
    a|+a)
      appendValue="$OPTARG";
      ;;
    c|+c)
      comment="$OPTARG";
      ;;
    d|+d)
      delimiter="$OPTARG";
      ;;
    f|+f)
      force=true;
      ;;
    h|+h)
      usage;
      ;;
    k|+k)
      key="$OPTARG";
      ;;
    r|+r)
      remove=true;
      ;;
    s|+s)
      silent=true;
      ;;
    v|+v)
      value="$OPTARG";
      ;;
    *)
      printf "usage: $(basename $0) [-a value] [-c comment] [-d delimiter] [-fh] [-k key] [-v value] [-r] [-s] file key value\n";
      exit 0;
  esac
done
shift `expr $OPTIND - 1`
OPTIND=1

file=$1;
shift;

if [ -z "${key}" ];
then
  key=$1;
  shift;
fi

if [ -z "${value}" ] && [ -z "${appendValue}" ];
then
  value=$1;
  shift;
fi

# Escape ARGs for future use with sed
singleQuoteEscapedKey=$(printf "${key}" | sed "s/\'/\\'/g");
singleQuoteEscapedDelimiter=$(printf "${delimiter}" | sed "s/\'/\\'/g");
singleQuoteEscapedValue=$(printf "${value}" | sed "s/\'/\\'/g");
doubleQuoteEscapedKey=$(printf "${singleQuoteEscapedKey}" | sed 's/\"/\\"/g');
doubleQuoteEscapedDelimiter=$(printf "${singleQuoteEscapedDelimiter}" | sed 's/\"/\\"/g');
doubleQuoteEscapedValue=$(printf "${singleQuoteEscapedValue}" | sed 's/\"/\\"/g');
escapedKey=$(printf "${doubleQuoteEscapedKey}" | sed 's/\//\\\//g');
escapedDelimiter=$(printf "${doubleQuoteEscapedDelimiter}" | sed 's/\//\\\//g');
escapedValue=$(printf "${doubleQuoteEscapedValue}" | sed 's/\//\\\//g');

# Debugging Code
echo "appendValue: $appendValue";
echo "comment:     $comment";
echo "file:        $file";
echo "key:         $escapedKey";
echo "delimiter:   $delimiter";
echo "value:       $value";

business_logic;
