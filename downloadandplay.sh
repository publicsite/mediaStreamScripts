#!/bin/sh

IFS="
"

usage (){
echo "Argv1: \"video\" or \"audio\""
echo "Argv2: <url>"
echo "Argv3: (optional)<format>"
exit
}

if [ "$1" = "video" ]; then
	if [ "$3" = "" ]; then
		theformat="bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
	else
		theformat="$3"
	fi

	tocheck2="$(find "$PWD" -mindepth 1 -maxdepth 1 -name "*.mp4")"

        checkcommand="$(yt-dlp -4 --sponsorblock-remove all -f "$theformat" "$2" 2>&1 | tee /dev/tty)"
        if [ "$(printf "%s\n" "$checkcommand" | grep "\-\-list\-formats")" != "" ]; then
                echo "USE A FORMAT FOR ARGUMENT 3"
                yt-dlp -4 --list-formats "$2"
                exit
         else
                possibleplay="$(printf "%s\n" "$checkcommand" | grep "\[download\] .* has already been downloaded")"
                if [ "$possibleplay" != "" ]; then
                        thefile="$(echo "$possibleplay" | cut -c 12- | rev | cut -c 29- | rev)"
			mpv -fs "${thefile}"
			echo "The video had already been downloaded, it's called ${thefile}"
			exit
                fi
        fi

        for line in $(find "$PWD" -mindepth 1 -maxdepth 1 -name "*.mp4"); do
                found=0
			for line2 in $(printf "%s\n" "$tocheck2"); do
                        if [ "$line" = "$line2" ] ;then
                                found=1
                                break
                        fi
                done

                if [ "$found" = 0 ]; then
			echo "Playing from complete download ..."
                        mpv -fs "$line"
                        exit
                fi
        done

elif [ "$1" = "audio" ]; then

	if [ "$3" = "" ]; then
		theformat="bestaudio"
	else
		theformat="$3"
	fi

	tocheck="$(find "$PWD" -mindepth 1 -maxdepth 1 -name "*.m4a")"
        checkcommand="$(yt-dlp -4 -x -f ${theformat} --sponsorblock-remove all "$2" 2>&1 | tee /dev/tty)"
	printf "%s\n" "$checkcommand"
        if [ "$(printf "%s\n" "$checkcommand" | grep "\-\-list\-formats")" != "" ]; then
               echo "USE A FORMAT FOR ARGUMENT 3"
               yt-dlp -4 --list-formats "$2"
               exit
        else
		possibleplay="$(printf "%s\n" "$checkcommand" | grep "\[download\] .* has already been downloaded")"
		if [ "$possibleplay" != "" ]; then
			thefile="$(echo "$possibleplay" | cut -c 12- | rev | cut -c 29- | rev)"
			if [ -f "${thefile%????}.mp3" ]; then
				x-terminal-emulator -e "mpv \"${thefile%????}.mp3\""
				echo "The file name is: ${thefile%????}.mp3"
				exit
			elif [ -f "${thefile}" ]; then
                                ffmpeg -nostdin -i "${thefile}" -c:a libmp3lame "${thefile%????}.mp3"
				x-terminal-emulator -e "mpv \"${thefile%????}.mp3\""
                                echo "Converting to mp3 is done - the file name is: ${thefile%????}.mp3"
				exit
			fi
		fi
	fi

	for line in $(find "$PWD" -mindepth 1 -maxdepth 1 -name "*.m4a"); do
		found=0
		for line2 in $(printf "%s\n" "$tocheck"); do
			if [ "$line" = "$line2" ] ;then
				found=1
				break
			fi
		done

		if [ "$found" = 0 ]; then
                        ffmpeg -nostdin -i "${line}" -c:a libmp3lame "${line%????}.mp3"
                        x-terminal-emulator -e "mpv \"${line%????}.mp3\""
                        echo "Converting to mp3 is done - the file name is: ${line%????}.mp3"
			exit
		fi
	done
else
usage
fi
