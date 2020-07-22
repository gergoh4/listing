#!/bin/bash

#glob valtozo
declare -i arg=$#

list(){

    #ha nem volt argumentum
    if [[ arg -eq 0 ]]; then
        read -p "Create a new project: " input
    fi

    #temp fajl keszitese es redirect
    temp="$(mktemp)"
    ls -A / | LC_ALL=C sort >> "$temp"
    
    echo ""

    #IFS megvaltoztatva
    local c=1
    echo "IFS megváltoztatva"
    while IFS='|' read -r line; do
        echo "$c." "$line"
        ((++c))
    done < "$temp"
    #IFS megvaltoztatva

    echo ""
    
    #Rossz for
    local c=1
    echo "Rossz for"
    for line in $(cat "$temp"); do
        echo "$c.""$line"
        ((++c))
    done
    #Rossz for
    
    echo ""

    #While
    local c=1
    echo "While"
    while IFS= read -r line; do
        echo "$c." "$line"
        ((++c))
    done < "$temp"
    #While

    echo ""

    #Egysoros
    local c=1
    echo "Egy sorban a parancs"
    while IFS= read -r line; do echo "$c." "$line"; ((++c)); done < "$temp"
    #Egysoros

    trap 'rm -f "$temp"' 0
}


#argumentum check
if [[ $1 ]]; then
    echo "Create a new project:" $1
    list
else
    echo "Error: missing argument"
    list
fi
