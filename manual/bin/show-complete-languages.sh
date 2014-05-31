#!/bin/sh

set -e

# Find 100% translated languages in live-manual

Find_untranslated ()
{
for POFILE in manual/po/"${LANGUAGE}"/*
	do
		
		if [ "$(sed '$!d' ${POFILE})" = 'msgstr ""' ]
			then
				sed '$G' ${POFILE} | grep --extended-regexp --before-context=1 '^$' | grep --count '^msgstr ""$' || continue
		else
			grep --extended-regexp --before-context=1 '^$' ${POFILE} | grep --count '^msgstr ""$' || continue
		fi	
        
	done
}

        for LANGUAGE in $(ls manual/po)
            do
               if [ "$(Find_untranslated | awk '{ sum += $1 } END { print sum }')" -eq "0" ]
                then
                    echo -n "${LANGUAGE}, "
               fi
            done
