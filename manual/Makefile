# Makefile

SHELL := sh -e

LANGUAGES = $(shell cd po && ls)

DEBUG=0
PO4A_FLAGS=

ifeq ($(DEBUG),1)
    PO4A_FLAGS=-d
endif

ifeq ($(DEBUG),2)
    PO4A_FLAGS=-d -v
endif

all: build

po4a.cfg:
	echo "[po4a_langs] $(LANGUAGES)" > po4a.cfg
	echo "[po4a_paths] pot/\$$master.pot \$$lang:po/\$$lang/\$$master.po" >> po4a.cfg

	for FILE in en/*.ssm en/*.ssi; \
	do \
		echo "[type: text] $${FILE} \$$lang:\$$lang/$$(basename $${FILE})" >> po4a.cfg; \
	done

	echo "[type: xhtml] en/index.html.in \$$lang:\$$lang/index.html.in" >> po4a.cfg

update:
	@./bin/update-version.sh

build: check po4a.cfg
	@if [ ! -x "$$(which po4a 2>/dev/null)" ]; \
	then \
		echo "E: po4a - command not found"; \
		echo "I: po4a can be obtained from http://po4a.alioth.debian.org/"; \
		echo "I: On Debian based systems, po4a can be installed with 'apt-get install po4a'."; \
		exit 1; \
	fi

	po4a --keep 0 --package-name live-manual --package-version $(shell cat ../VERSION) $(PO4A_FLAGS) po4a.cfg

clean:
	rm -f po/*/*.po~
	rm -rf ../build

distclean: clean
	rm -f po4a.cfg
	rm -rf $(LANGUAGES)

rebuild: distclean update build

check:
	@echo -n "Checking the integrity of .po files "

	@if [ -x /usr/bin/msgfmt ]; \
	then \
		for POFILE in po/*/*; \
		do \
			msgfmt --check --output-file=/dev/null $${POFILE}; \
			echo -n "."; \
		done; \
	else \
		echo "WARNING: skipping po integrity check. You must install gettext."; \
	fi
	
	@echo " done!"
