#!/bin/sh

set -e

VERSION="$(cat ../VERSION)"

DAY="$(LC_ALL=C date +%d)"
MONTH="$(LC_ALL=C date +%m)"
YEAR="$(LC_ALL=C date +%Y)"

echo "Updating version information..."
sed -i  -e "s|^ :published:.*$| :published: ${YEAR}-${MONTH}-${DAY}|" \
	-e "s|(C) 2006-.*|(C) 2006-${YEAR} Live Systems Project|" \
en/live-manual.ssm

# European date format
for _LANGUAGE in ca de es fr it pl ro
do
	if [ -e po/${_LANGUAGE}/live-manual.ssm.po ]
	then
		sed -i -e "s|:published: .*.${YEAR}|:published: ${DAY}.${MONTH}.${YEAR}|" \
		po/${_LANGUAGE}/live-manual.ssm.po
	fi
done

# Brazilian date format
if [ -e po/pt_BR/live-manual.ssm.po ]
then
	sed -i -e "s|:published: .*-${YEAR}|:published: ${DAY}-${MONTH}-${YEAR}|" \
	po/pt_BR/live-manual.ssm.po
fi
