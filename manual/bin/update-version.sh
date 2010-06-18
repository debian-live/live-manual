#!/bin/sh

set -e

DATE="$(LC_ALL=C date +%Y-%m-%d)"
VERSION="$(cat ../VERSION)"
YEAR="$(LC_ALL=C date +%Y)"

echo "Updating version information..."

sed -i  -e "s|<!ENTITY pubdate.*$|<!ENTITY pubdate \"${DATE}\">|" \
	-e "s|<!ENTITY releaseinfo.*$|<!ENTITY releaseinfo \"${VERSION}\">|" \
	-e "s|<!ENTITY year.*$|<!ENTITY year \"${YEAR}\">|" \
en/index.xml
