#!/bin/sh

set -e

# Script to check English spelling interactively in live-manual.

# Check whether aspell is installed or not with English dictionaries.

if [ ! -x "$(which aspell 2>/dev/null)" ]
    then 
        echo "E: aspell - command not found!"
		echo "I: aspell can be downloaded from ftp://ftp.gnu.org/gnu/aspell/"
		echo "I: On debian based systems, aspell can be installed with 'apt-get install aspell'."
		exit 1
elif [ ! -e "/var/lib/dictionaries-common/aspell/aspell-en" ]
	then
		echo "E: No English dictionary found." 
		echo "I: Please do 'apt-get install aspell-en'."
		exit 1
fi

echo ""
echo "This script can help you check the spelling of these English texts:"
echo ""

# Functions

Check_file ()
{
aspell --check "manual/en/${FILE}" --dont-backup --lang="en"
}

List_files ()
{
ls manual/en | cat --number
printf "\tdebian/changelog"
}

Select_files ()
{
echo ""
echo "Choose a number ['a' to see all] ['c' for changelog] or ['q' to quit]:"

read NUMBER

FILE=$(ls manual/en | cat --number | grep -w ${NUMBER} | sed -e 's|[0-9]*||g' -e 's|^[ \t]*||')

case "$NUMBER" in
    [[:digit:]]*)
				Check_file
				;;

	a)
		echo "Checking all files, one at a time..."
		sleep 2
		for FILE in $(ls manual/en)
			do
				Check_file
			done
		;;
    
	c) 
		echo "Checking spelling in debian/changelog"
		sleep 2
		aspell --check "debian/changelog" --dont-backup --lang="en"
		;;
        
	q)	
		exit 0 
		;;

	*)	
		echo "Nothing to do! Exiting..." 
		;;
		
esac
}

List_files
Select_files
