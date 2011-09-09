#!/bin/sh

if [ $# -ne 1 ]; then
	echo "Please pass the name of the directory to format"
	exit 1;
fi

if [ ! -d $1 ]; then
	echo "$1 is not a directory"
	exit 1;
fi

if [ ! `type -P uncrustify` ]; then
	echo "Uncrustify is not a command"
	exit 1;
fi

echo Running formatter on $1

uncrustify -l OC -c ./uncrustify.conf --no-backup $(find $1 -name "*.[mh]")
