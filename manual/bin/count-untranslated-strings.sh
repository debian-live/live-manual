#!/bin/sh

set -e

# Count total number of untranslated strings in live-manual

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

Count_untranslated_strings | awk '{ sum += $1 } END { print sum }'
