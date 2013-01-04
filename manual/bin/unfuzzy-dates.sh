#!/bin/sh

set -e

# Script to automatically fix "predictable" fuzzy strings in live-manual. keep
# in mind that if there is more than one fuzzy string in the po file the script
# will not do anything since manual intervention is needed anyway.
#
# 'XY' is the start line number of the fuzzy strings in the dates.

XY="47"

# Getting the unfuzzying done.

echo "Fixing 'fuzzy' in date strings if necessary..."

for LANGUAGE in $(ls po)
do
	if [ "$(grep --line-number --word-regexp 'fuzzy' po/${LANGUAGE}/live-manual.ssm.po | sed 's|[^0-9]*||g')" -eq "${XY}" ] > /dev/null 2>&1
	then
		sed -i	-e "${XY} s|#, fuzzy, no-wrap|#, no-wrap|" \
			-e "$((${XY} + 1)),$((${XY} + 3))d" \
		po/${LANGUAGE}/live-manual.ssm.po
	fi
done
