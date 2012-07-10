#!/bin/sh 

set -e
 
# Script to help translators to check the integrity of po files in live-manual.
#
# 'msgfmt' performs several checks and outputs some common errors: 
#
#	- Checks format
#	- Checks header
#	- ...
#
# We do not want to compile a .mo file so we use /dev/null.
# 

echo ""
echo "This script can help you check the integrity of po files."
echo "Select: $(ls -C manual/po) ['a' to see all] ['q' to quit] "

# Creating function

Integrity_check()
{
	echo "Checking the integrity of $(ls manual/po/${LANGUAGE}/* | wc -l) po files in ${LANGUAGE}."
	echo ""	
	for POFILE in manual/po/${LANGUAGE}/*
	do
		echo "-$(basename ${POFILE})"
		echo ""	
		msgfmt --verbose --check --output-file=/dev/null ${POFILE}
		if [ "$?" -eq "0" ]
		then
			echo "-> This .po file is 'GOOD'."
			echo ""
		elif [ "$?" -ne "0" ]
		then 
			echo "-> This .po file might be 'BAD'. Please revise it."
			echo ""
		fi
	done
}

# Menu.

read LANGUAGE

case "$LANGUAGE" in
	en)	echo "Nothing to be done, really!"
		;;

	ca|de|es|fr|it|pt_BR|ro)	
		Integrity_check				
		;;

	a)	for LANGUAGE in manual/po/*
		do 
			for POFILE in ${LANGUAGE}/*
			do
				echo "-Checking $(basename ${POFILE}) integrity in ${LANGUAGE}"
				echo ""	
				msgfmt --verbose --check --output-file=/dev/null ${POFILE}
				if [ "$?" -eq "0" ]
				then
					echo "->This .po file is 'GOOD'."
					echo ""
				elif [ "$?" -ne "0" ]
				then 
					echo "->This .po file might be 'BAD'. Please revise it."
					echo ""
				fi
			done
		done
		;;

	q)	exit 0
		;;

	*)	echo "No language chosen. Exiting..."
		;;

esac