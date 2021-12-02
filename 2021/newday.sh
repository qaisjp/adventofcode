#! /bin/bash

if [ -z "$1" ]; then
    echo "needs day number as param"
    exit 1
fi

daystr=$(printf "day%02d" "$1")
echo "$daystr"

cp -r dayXX $daystr
curl -b session=$(cat token.txt) https://adventofcode.com/2021/day/$1/input > $daystr/input.txt
