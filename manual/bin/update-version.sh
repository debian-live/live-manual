#!/bin/sh

set -e

DATE="$(LC_ALL=C date +%Y-%m-%d)"
VERSION="$(cat ../VERSION)"

echo "Updating version information..."

sed -i  -e "s|<!ENTITY pubdate.*$|<!ENTITY pubdate \"${DATE}\">|" \
	-e "s|<!ENTITY version.*$|<!ENTITY version \"${VERSION}\">|" \
en/index.xml
