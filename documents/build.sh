#!/bin/bash
main() {
	opt=$( tr '[:upper:]' '[:lower:]' <<<"$1" )
	case "$opt" in
		"htmld")
			htmldCompile;;
		"torrent")
			torrentCompile;;
		"qemu")
			qemuCompile;;
		*)
			echo "Compiling all"; htmldCompile; torrentCompile; qemuCompile;;
	esac
}
htmldCompile() {
	echo "Compiling HTMLD"
	date="$(date -I -r src/HTMLD.tex | sed 's/-/ /g')"
	for i in 1 2; do ( cd src && hevea HTMLD.tex -O -o ../HTMLD/index.html ); done
	rm -f HTMLD/*.haux HTMLD/*.htoc HTMLD/*.image*
	sed -i "s/DATE/$date/g" HTMLD/index.html
	sed -i "s/index001.png/\/documents\/src\/images\/hellolinuxworld.png/g" HTMLD/index.html
	sed -i "s/<\/style>/body { background-image: url('\/documents\/src\/images\/bg.png'); \
	 } \nhtml { cursor: url('\/stuff\/cursor.gif'), auto; height: 100% } \n<\/style>/g" HTMLD/index.html
}
torrentCompile() {
	echo "Compiling TORRENT"
	date="$(date -I -r src/TORRENT.tex | sed 's/-/ /g')"
	for i in 1 2; do ( cd src && hevea TORRENT.tex -O -o ../TORRENT/index.html ); done
	rm -f TORRENT/*.haux TORRENT/*.htoc TORRENT/*.image*
	sed -i "s/DATE/$date/g" TORRENT/index.html
	sed -i "s/<\/style>/body { background-image: url('\/documents\/src\/images\/bg.png'); \
	 } \nhtml { cursor: url('\/stuff\/cursor.gif'), auto; height: 100% } \n<\/style>/g" TORRENT/index.html
}
qemuCompile() {
	echo "Compiling QEMU"
	date="$(date -I -r src/QEMU.tex | sed 's/-/ /g')"
	for i in 1 2; do ( cd src && hevea QEMU.tex -O -o ../QEMU/index.html ); done
	rm -f QEMU/*.haux QEMU/*.htoc QEMU/*.image*
	sed -i "s/DATE/$date/g" QEMU/index.html
	sed -i "s/<\/style>/body { background-image: url('\/documents\/src\/images\/bg.png'); \
	 } \nhtml { cursor: url('\/stuff\/cursor.gif'), auto; height: 100% } \n<\/style>/g" QEMU/index.html	
}
main "$@"; exit
