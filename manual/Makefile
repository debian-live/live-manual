# Makefile

SHELL := sh -e

LANGUAGES = $(shell cd po && ls)

all: build

po4a.cfg:
	echo "[po4a_langs] $(LANGUAGES)" > po4a.cfg
	echo "[po4a_paths] pot/\$$master.pot \$$lang:po/\$$lang/\$$master.po" >> po4a.cfg

	for FILE in en/*.ssm en/*.ssi; \
	do \
		echo "[type: text] $${FILE} \$$lang:\$$lang/$$(basename $${FILE})" >> po4a.cfg; \
	done

update:
	@./bin/update-version.sh

build: po4a.cfg
	@if [ ! -x "$$(which po4a 2>/dev/null)" ]; \
	then \
		echo "E: po4a - command not found"; \
		echo "I: po4a can be optained from http://po4a.alioth.debian.org/"; \
		echo "I: On Debian systems, po4a can be installed with 'apt-get install po4a'."; \
		exit 1; \
	fi

	po4a --keep 0 --no-backups --package-name live-manual po4a.cfg

	for LANGUAGE in $(LANGUAGES); \
	do \
		cp -a en/_sisu $${LANGUAGE}; \
	done

clean:
	rm -f po/*/*.po~

distclean: clean
	rm -f po4a.cfg
	rm -rf $(LANGUAGES)

rebuild: distclean update build
