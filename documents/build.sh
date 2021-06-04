#!/bin/bash
main() {
	opt=$( tr '[:upper:]' '[:lower:]' <<<"$1" )
	case "$opt" in
		"htmld")
			htmldCompile;;
		"torrent")
			torrentCompile;;
		*)
			echo "Compiling all"; htmldCompile; torrentCompile;;
	esac
}
htmldCompile() {
	echo "Compiling HTMLD"
	for i in 1 2; do ( cd src && hevea HTMLD.tex -O -o ../HTMLD/index.html ); done
	printf \n\n | imagen HTMLD/index
	cp src/HelloLinuxWorld.png HTMLD/index001.png
	rm -f HTMLD/*.haux HTMLD/*.htoc HTMLD/*.image*
}
torrentCompile() {
	echo "Compiling TORRENT"
	for i in 1 2; do ( cd src && hevea TORRENT.tex -O -o ../TORRENT/index.html ); done
	rm -f TORRENT/*.haux TORRENT/*.htoc TORRENT/*.image*
}
main "$@"; exit
