#!/bin/sh

set -e

# Script to assist translators in finding and fixing untranslated strings in live-manual.

# First, we prepare to count the total number of untranslated strings.

Count_untranslated_strings ()
{
	for POFILE in manual/po/*/*
		do
			if [ "$(sed '$!d' ${POFILE})" = 'msgstr ""' ]
			then
				sed '$G' ${POFILE} | grep --extended-regexp --before-context=1 '^$' | grep --count '^msgstr ""$' || continue
			else
				grep --extended-regexp --before-context=1 '^$' ${POFILE} | grep --count '^msgstr ""$' || continue
			fi
	done
}

# Then, if there is not any untranslated string the script exits.

Check_untranslated_strings ()
{
	if [ "$(Count_untranslated_strings | awk '{ sum += $1 } END { print sum }')" -eq "0" ]
		then
			echo "There are 0 untranslated strings."
			exit 0
	fi
}

Check_untranslated_strings

# Creating other functions.

# An untranslated string is an empty 'msgstr ""' followed by a blank line. We
# grep blank lines and ensure that the previous line only contains 'msgstr ""'.
#
# If the last string in a po file is not translated, there is no blank line at
# the end so we need to add one with "sed '$G''".
#

Find_untranslated ()
{
echo ""
echo " * Searching for 'untranslated strings' in ${LANGUAGE} ..."
echo ""

for POFILE in manual/po/"${LANGUAGE}"/*
	do
		echo "Untranslated strings in ${POFILE}"
		
		if [ "$(sed '$!d' ${POFILE})" = 'msgstr ""' ]
			then
				sed '$G' ${POFILE} | grep --extended-regexp --before-context=1 '^$' | grep --count '^msgstr ""$' || continue
		else
			grep --extended-regexp --before-context=1 '^$' ${POFILE} | grep --count '^msgstr ""$' || continue
		fi	
	done
}

# Showing *only* untranslated strings:
# pros: finer granularity, easier to read...
# cons: Some languages with accents and other similar stuff may greatly benefit 
# from a quick glance at the translated strings, too. And then some...
#
# If there is not any untranslated string in the selected language, then exit.

Show_strings ()
{
if [ "$(Find_untranslated | awk '{ sum += $1 } END { print sum }')" -eq "0" ]
	then
		echo ""
		echo "There are 0 untranslated strings in language: ${LANGUAGE}" | grep --color ${LANGUAGE}
		echo ""
		
		exit 0
fi

echo ""
echo "Do you want to see the $(Find_untranslated | awk '{ sum += $1 } END { print sum }') strings before starting work? [yes/no] ['q' to quit]"

POFILES="$(Find_untranslated | grep --extended-regexp --before-context=1 '[1-9]'| sed -e 's|Untranslated strings in ||' -e 's|--||' -e 's|[0-9]*||g')"

read ANSWER 
case "${ANSWER}" in
		y*|Y*)	
				for POFILE in ${POFILES}
					do 
						echo ""
						echo "Untranslated strings in $(basename ${POFILE})" | grep --color $(basename ${POFILE})
						echo ""
						
						msggrep --invert-match --msgstr --regexp='' ${POFILE}
					done
			
				Open_editor
				;;

		n*|N*)	
				Open_editor
				;;
				
		q) 
				exit 0
				;;

		*)
				echo "You didn't type 'yes'. Exiting..."
				exit 0
				;;
esac
}

# Searches untranslated strings and offers to open editor to fix them.
#
# Editor defaults to vim unless otherwise specified in the environment.

EDITOR="${EDITOR:-vim}"

Open_editor ()
{
echo ""
echo "Do you want to launch your text editor to start fixing them? [yes/no] ['q' to quit]"

POFILESTOEDIT="$(Find_untranslated | grep --extended-regexp --before-context=1 '[1-9]'| sed -e 's|Untranslated strings in ||' -e 's|--||' -e 's|[0-9]*||g')"

read OPENEDITOR

case "$OPENEDITOR" in
	y*|Y*)	
			if [ -z "${POFILESTOEDIT}" ] 
				then
					echo "No po files to edit."
					exit 0
				else
					${EDITOR} ${POFILESTOEDIT}
			fi		
		;;

	n*|N*)
			echo "You typed 'no'. Exiting..."
			exit 0
			;;
		
	q) 
			exit 0
			;;

	*)	
			echo "You didn't type 'yes'. Exiting..."
			exit 0
			;;
esac
}

# Main menu.

echo "Counting untranslated strings...please wait..."
echo ""
echo "There are $(Count_untranslated_strings | awk '{ sum += $1 } END { print sum }') untranslated strings in live-manual."
echo "This script can help you find and fix them. What is your language?."
echo "Type: $(ls -C manual/po) ['a' to see all]['q' to quit]"

read LANGUAGE 
case "$LANGUAGE" in

	ca|de|es|fr|it|ja|pl|pt_BR|ro)
		Find_untranslated
		Show_strings
		;;

	en)	
		echo "Nothing to be done, really."
		echo "Translation English-English not implemented yet!"
		;;

	a)
        for LANGUAGE in $(ls manual/po)
            do
               Find_untranslated
               if [ "$(Find_untranslated | awk '{ sum += $1 } END { print sum }')" -eq "0" ]
                then
                    echo ""
                    echo "There are 0 untranslated strings in language: ${LANGUAGE}" | grep --color ${LANGUAGE}
                    echo ""
                fi
            done
		;;
	
	q)	
		exit 0
		;;

	*)	
		echo "No language chosen. Exiting..."
esac
