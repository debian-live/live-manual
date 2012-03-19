#!/bin/sh

# Script to assist translators in finding and fixing fuzzy strings in live-manual.

echo ""
echo "There are $(grep -w 'fuzzy' manual/po/*/* | wc -l) fuzzy strings altogether in live-manual."
echo "This script can help you find and fix them. What is your language?."
echo "Type: de, es, fr, it, pt_BR or ro ['q' to quit]" 

# Editor defaults to vim unless otherwise specified in preferences.

EDITOR=${EDITOR:-vim}

# Creating the function. Searches 'fuzzy' and offers to open editor to fix them.

find_fuzzy()

{
	echo ""	
	echo "There are $(grep -w 'fuzzy' manual/po/$ANSWER/* | wc -l) fuzzy strings in your language." 
	echo ""	

	grep -w 'fuzzy' manual/po/$ANSWER/*

	if [ "$(grep -w 'fuzzy' manual/po/$ANSWER/* | wc -l)" = "0" ]
	then 	
		echo "You may now proceed...please do:"
		echo ""
		echo "  * git add ."
		echo "  * git commit -a -m \"Your commit message.\""
		echo "  * git push "
		echo ""
		exit 0
	else
		echo ""
		echo "Do you want to launch your text editor to start fixing them? [yes/no]"

			read OPENEDITOR
			case $OPENEDITOR in

				y*|Y*)	$EDITOR $(grep -w 'fuzzy' manual/po/$ANSWER/* | uniq | sed 's|:#, fuzzy.*||')
				;;
				n*|N*)	exit 0
				;;
				*)	echo "You didn't type 'yes'. Exiting..."
					exit 0

			esac

	fi
	exit 0
}

# Languages menu.

read ANSWER  
case "$ANSWER" in

	de)	find_fuzzy
		;;

	en)	echo "Nothing to be done, really."
		echo "Translation English-English not implemented yet!"
		;;

	es)	find_fuzzy
		;;

	fr)	find_fuzzy
		;;

	it)	find_fuzzy
		;;

	pt_BR)	find_fuzzy
		;;

	ro)	find_fuzzy
		;;

	q)	exit
		;;

	*)	echo "No language chosen. Exiting..."

esac




