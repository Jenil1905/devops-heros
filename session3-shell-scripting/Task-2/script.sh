#!/bin/bash

current_date=$(date)
host_name=$(hostname)
user_name=$(whoami)

echo $current_date
echo $host_name
echo $user_name

df -h

read -p "Enter directory name: " dir_name
read -p "Enter file name: " file_name

mkdir -p "$dir_name"
touch "$dir_name/$file_name"
ps > "$dir_name/$file_name"
