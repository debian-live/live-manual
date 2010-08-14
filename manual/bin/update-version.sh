#!/bin/sh

set -e

DATE="$(LC_ALL=C date +%Y-%m-%d)"
VERSION="$(cat ../VERSION)"
YEAR="$(LC_ALL=C date +%Y)"

echo "Updating version information..."

sed -i  -e "s|^ :published:.*$| :published: ${DATE}|" \
	-e "s|(C) 2006-.*|(C) 2006-${YEAR} Debian Live Project|" \
en/live-manual.ssm
