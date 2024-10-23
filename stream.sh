#!/bin/sh

if [ "$1" = "video" ]; then
	thetitle="$(yt-dlp --get-filename "$2" 2>/dev/null | tail -n 1)"
	if [ "$thetitle" != "" ]; then
		yt-dlp "$2" -4 --sponsorblock-remove all -o - | tee "$thetitle" | mpv -fs -
	else
		echo "Bad URL"
		exit
	fi
elif [ "$1" = "audio" ]; then
	thetitle="$(yt-dlp --get-filename "$2" -f 140 2>/dev/null | tail -n 1)"
	if [ "$thetitle" != "" ]; then
		yt-dlp "$2" -x -f bestaudio -4 --sponsorblock-remove all -o - | tee "$thetitle" | mpv -fs -
	else
		echo "Bad URL"
		exit
	fi
else
echo "Argv1: <video/audio>"
echo "Argv2: <url>"
fi

