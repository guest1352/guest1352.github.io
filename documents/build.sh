#!/bin/bash
main() {
	opt=$( tr '[:upper:]' '[:lower:]' <<<"$1" )
	case "$opt" in
		"htmld")
			echo "Compiling HTMLD"; htmldCompile;;
		*)
			echo "Compiling all"; htmldCompile;;
	esac
}
htmldCompile() {
	for i in 1 2; do ( cd src && hevea HTMLD.tex -o ../HTMLD/index.html ); done
	printf \n\n | imagen HTMLD/index
	cp src/HelloLinuxWorld.png HTMLD/index001.png
	rm -f HTMLD/*.haux HTMLD/*.htoc HTMLD/*.image*
}
main "$@"; exit
