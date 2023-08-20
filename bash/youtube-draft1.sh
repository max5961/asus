#!/bin/bash

videos=~/Videos/downloads
music=~/Music/downloads
if [ ! -d "$videos" ]; then
	mkdir ~/Videos/downloads
fi
if [ ! -d "$music" ]; then
	mkdir ~/Music/downloads
fi

installed=$(yt-dlp --version | awk -F'.' '{print $3}')
latest=$(pip list | grep yt-dlp | awk '{print $2}' | awk -F'.' '{print $3}')

if [ "$installed" -ne "$latest" ]
then
	echo "yt-dlp is not up to date"
	echo "Installed version: $installed"
	echo "Latest version: $latest"
	echo "Installing latest version of yt-dlp..."
	pip install --upgrade yt-dlp
	echo "Latest version of yt-dlp installed"
fi

echo "Enter link:"
read link
if ! echo "$link" | grep -q "https://www."
then
	link="https://www.$link"
fi

echo "audio or video? [a/v]:"
read format
format=$(echo "$format" | tr [:lower:] [:upper:])

echo "playlist? [y/n]:"
read playlist
playlist=$(echo "$playlist" | tr [:lower:] [:upper:])

cd ~/Music/downloads
# AUDIO ONLY AND PLAYLIST = YES
if [ "$format" = "A" ] && [ "$playlist" = "Y" ]
then
	echo "Give folder to save playlist a name:"
	read input_folder
	echo "Artist name?: (optional leave blank)"
	read artist_name

	if [ -d ~/Music/"$artist_name" ]; then
	   cd ~/Music/"$artist_name"
	else
		if [ ! "$artist_name" = "" ]; then
			mkdir ~/Music/"$artist_name"
			cd ~/Music/"$artist_name"
		fi
	fi
	
	newDirectory=$input_folder
	echo "creating folder $newDirectory in..."
	pwd
	mkdir $newDirectory
	cd "$newDirectory"
	yt-dlp -f bestaudio $link
	echo "downloaded to:"
   	pwd	
fi

# AUDIO ONLY AND PLAYLIST = NO
if [ "$format" = "A" ] && [ "$playlist" = "N" ]
then
	yt-dlp -f bestaudio --no-playlist $link
	echo "downloaded to:"
	pwd
fi

# VIDEO
cd ~/Videos/downloads
# A/V AND PLAYLIST = YES
if [ "$format" = "V" ] && [ "$playlist" = "Y" ]
then
	# change directories into /home/Video/downloads
	newDirectory=video-playlist-$(date +"%d-%m-%Y-%H-%M-%S")
	echo "creating folder $newDirectory in..."
	pwd
	mkdir "$newDirectory"
	cd "$newDirectory"
	yt-dlp -f bestaudio+bestvideo $link
	echo "downloaded to:"
	pwd
fi

# A/V AND PLAYLIST = NO
if [ "$format" = "V" ] && [ "$playlist" = "N" ]
then
	yt-dlp -f bestaudio+bestvideo --no-playlist $link
	echo "downloaded to:"
	pwd
fi

echo "Open folder? [y/n]:"
read open
open=$(echo "$open" | tr [:lower:] [:upper:])
if [ "$open" = "Y" ]
then 
	if [ "$format" = "V" ]
	then
		xdg-open ~/Videos/downloads > /dev/null 2>&1
	else
		xdg-open ~/Music/downloads > /dev/null 2>&1
	fi
fi	
