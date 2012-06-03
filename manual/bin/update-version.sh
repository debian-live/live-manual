#!/bin/sh

set -e

VERSION="$(cat ../VERSION)"

DAY="$(LC_ALL=C date +%d)"
MONTH="$(LC_ALL=C date +%m)"
YEAR="$(LC_ALL=C date +%Y)"

echo "Updating version information..."
sed -i  -e "s|^ :published:.*$| :published: ${YEAR}-${MONTH}-${DAY}|" \
	-e "s|(C) 2006-.*|(C) 2006-${YEAR} Debian Live Project|" \
en/live-manual.ssm

if [ -e po/de/live-manual.ssm.po ]
then
	sed -i -e "s|:published: .*.${YEAR}|:published: ${DAY}.${MONTH}.${YEAR}|" \
	po/de/live-manual.ssm.po
fi
