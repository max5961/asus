#!/bin/bash

check_empty_input() {
	if [ -z "$1" ]; then
		exit 0
	fi
}

to_lower_case() {
	echo "$1" | tr [:upper:] [:lower:]
}

create_folder() {
	if [ ! -d "$1" ]; then
		mkdir "$1"
	fi
}

check_installed() {
	pip --version 1> /dev/null 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "Pip is necessary for this script to run"
		echo "Install pip? [y/n]"
		read answer
		if [ "$answer" = "Y" ]; then
			sudo apt install pip
		else
			exit 0
		fi
	fi

	yt-dlp --version 1> /dev/null 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "yt-dlp is necessary for this script to run"
		echo "Install yt-dlp? [y/n]"
		read answer
		answer=$(to_lower_case "$answer")
		if [ "$answer" = "y" ]; then
			pip install yt-dlp
		else 
			exit 0
		fi
	fi

	installed=$(yt-dlp --version | awk -F'.' '{print $3}')
	latest=$(pip list | grep yt-dlp | awk '{print $2}' | awk -F'.' '{print $3}')

	if [ "$installed" -ne "$latest" ]; then
		echo "yt-dlp is not up to date"
		echo "Installed version: $installed"
		echo "Latest version: $latest"
		echo "Installing latest version of yt-dlp..."
		pip install --upgrade yt-dlp
		echo "Latest version of yt-dlp installed"
	fi
}

echo "Enter link:"
read link
check_empty_input "$link"
if [ ! "$(echo "$link" | grep -q "https://www.")" ]; then
	link="https://www.$link"
fi

echo "Music, Video, or Audio? [m/v/a]:"
read format
format=$(to_lower_case "$format")

echo "Playlist? [y/n]"
read playlist
playlist=$(to_lower_case "$playlist")

if [ "$format" = "a" ]; then
	cd ~/Documents
	if [ "$playlist" = "y" ]; then
		create_folder "$playlist"
	fi

