#!/bin/bash
COSAN=${HOME}/gaeilge/ga2gv/ga2gv
egrep '^[^ ]+_(card|ord)' ${COSAN}/focloir.txt | sed 's/_.*//' | sort -u |
while read x
do
	LINE=`cat ${COSAN}/GV.txt | tr "\n" " " | sed 's/ - /\n/g' | egrep "^$x 128" | head -n 1 | sed 's/ [0-9][0-9]*//g'`
	HEADW=`echo "$LINE" | sed 's/ .*//'`
	echo "$LINE" | sed 's/^[^ ]* //' | tr " " "\n" | sed "s/$/\t${HEADW}\tNUM/"
done | sort -u | sort -k1,1
