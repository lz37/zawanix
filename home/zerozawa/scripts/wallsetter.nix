{
	pkgs,
	rootPath,
	...
}: let
	wallpaperDir = rootPath + "/assets/wallpapers";
in
	pkgs.writeShellScriptBin "wallsetter" ''

		TIMEOUT=720

		for pid in $(pidof -o %PPID -x wallsetter); do
			kill $pid
		done

		if ! [ -d ${wallpaperDir} ]; then notify-send -t 5000 "${wallpaperDir} does not exist" && exit 1; fi
		if [ $(ls -1 ${wallpaperDir} | wc -l) -lt 1 ]; then	notify-send -t 9000 "The wallpaper folder is expected to have more than 1 image. Exiting Wallsetter." && exit 1; fi

		while true; do
		  while [ "$WALLPAPER" == "$PREVIOUS" ]; do
		    WALLPAPER=$(find ${wallpaperDir} -name '*' | awk '!/.git/' | tail -n +2 | shuf -n 1)
		  done

			PREVIOUS=$WALLPAPER

			${pkgs.swww}/bin/swww img "$WALLPAPER" --transition-type random --transition-step 1 --transition-fps 60
			sleep $TIMEOUT
		done
	''
