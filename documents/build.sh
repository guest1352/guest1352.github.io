#!/bin/bash
for i in 1 2; do hevea src/HTMLD.tex -o HTMLD/index.html; done
printf \n\n | imagen HTMLD/index
cp src/HelloLinuxWorld.png HTMLD/index001.png
rm -f HTMLD/*.haux HTMLD/*.htoc HTMLD/*.image*
