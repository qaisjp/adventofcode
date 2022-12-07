#! /bin/bash

if [ -z "$1" ]; then
    echo "needs day number as param"
    exit 1
fi

YEAR=2022

daystr=$(printf "day%02d" "$1")
echo "$daystr"

cp -r dayXX $daystr
curl -b session=$(cat token.txt) https://adventofcode.com/$YEAR/day/$1/input > $daystr/input.txt
open "https://adventofcode.com/2022/day/$1"
code . -g "$daystr/main.rb:16"
cd $daystr
echo "Opening shell into new directory"
$SHELL
