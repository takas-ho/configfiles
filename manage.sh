#!/bin/bash

# Links the passed filename to its new location
function link () {
    local filename=$1
    if [[ ! -e $filename ]]; then
        echo "$filename doesn't exist"
        return
    fi

    local path="$HOME/${1#*/}"
    if [[ ! -e "$path" ]]; then
        if [[ ! -e "${path%/*}" ]]; then
            echo "mkdir ${path%/*}"
            mkdir "${path%/*}"
        fi
        echo "Linking $filename to $path"
        ln -s "$PWD/$filename" "$path"
    fi
}

# Delete the linked file path
function unlink_geo () {
    local filename=$1
    local path="$HOME/${1#*/}"

    if [ -e "$path" ]; then
        echo "Removing $path"
        rm "$path"
    elif [ -L "$path" ]; then
        echo "Removing link $path"
        unlink "$path"
    fi
}

# Loops through and link all files without links
function install_links () {
    for FOLDER in ${FOLDERS[@]}
    do
        link $FOLDER
    done
    for FILE in ${FILES[@]}
    do
        link $FILE
    done
}

# Function to remove all linked files
function remove_links () {
    for FOLDER in ${FOLDERS[@]}
    do
        unlink_geo $FOLDER
    done
    for FILE in ${FILES[@]}
    do
        unlink_geo $FILE
    done
}

# Fuction to print the usage and exit when there's bad input
function die () {
    echo "Usage ./manage.sh {install|remove}"
    exit 1
}

# Make sure there is 1 command line argument
if [[ $# != 1 ]]; then
    die
fi

if [ "$(uname)" == "Darwin" ]; then
    FOLDERS=("mac/Library/Preferences/muCommander","mac/Library/Application Support/Code/User")
    FILES=()
elif [ "$(uname)" == "Linux" ]; then
    FOLDERS=("linux/.mucommander")
    FILES=("linux/.config/Code/User/keybindings.json","linux/.config/Code/User/settings.json","linux/.config/krusaderrc")
fi

# Check whether the user is installing or removing
if [[ $1 == "install" ]]; then
    IFS_bak=$IFS
    IFS=','
    install_links
    IFS=$IFS_bak
    ## It's required for this to have these permissions
    #chmod 0600 ~/.mutt/msmtprc
elif [[ $1 == "remove" ]]; then
    IFS_bak=$IFS
    IFS=','
    remove_links
    IFS=$IFS_bak
else
    die
fi
