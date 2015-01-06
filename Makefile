# Makefile

## live-manual(7) - Documentation
## Copyright (C) 2006-2015 Live Systems Project <debian-live@lists.debian.org>
##
## live-manual comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


SHELL := sh -e

LANGUAGES := en $(shell cd manual/po && ls)

FORMATS := epub html odf pdf txt

DEBUG := 0

ifeq ($(PROOF),1)
	LANGUAGES=en
	FORMATS=html-scroll
endif

ifeq ($(PROOF),2)
	LANGUAGES=en
	FORMATS=pdf-portrait
endif

all: build

test:
	@echo -n "Checking for syntax errors "

	@for SCRIPT in $(shell ls manual/bin/*.sh); \
	do \
		sh -n $${SCRIPT}; \
		echo -n "."; \
	done

	@echo " done!"

	@echo -n "Checking for bashisms "

	@if [ -x /usr/bin/checkbashisms ]; \
	then \
		for SCRIPT in $(shell ls manual/bin/*.sh); \
		do \
			checkbashisms -f -x $${SCRIPT}; \
			echo -n "."; \
		done; \
	else \
		echo "WARNING: skipping bashism test - you need to install devscripts."; \
	fi

	@echo " done!"
	@echo "To interactively check for spelling mistakes, you can run 'make spell'."

tidy:
	# Removing useless whitespaces at EOL
	for FILE in manual/en/*.ssm manual/en/*.ssi; \
	do \
		sed -i -e 's|[ \t]*$$||' $${FILE}; \
	done

build: clean
	#FIXME: do a proper dependency-based build
	#FORMATS = epub html odf pdf txt
	#...
	#%.pdf: $(sisu_sources)
	#	sisu-pdf -v live-manual.ssm
	#etc.

	@# FIXME: sisu-concordance sisu-pg sisu-sqlite

	cd $(CURDIR)/manual; \
	sisu --configure
	for LANGUAGE in $(LANGUAGES); \
	do \
		for FORMAT in $(FORMATS); \
		do \
			cd $(CURDIR)/manual; \
			sisu-$${FORMAT} --no-manifest --verbose $${LANGUAGE}/live-manual.ssm; \
		done; \
	done; \

autobuild: build
	cd build/manual; \
	set +e; for LANGUAGE in $(LANGUAGES); \
	do \
		FROMDIR=$(CURDIR)/manual/$${LANGUAGE}; \
		TODIR=$(CURDIR)/build/manual; \
		cp $${FROMDIR}/index.html.in $${TODIR}; \
		sed -e "s|@DATE_BUILD@|$(shell LC_ALL=C date -R)|" \
		    -e "s|@DATE_CHANGE@|$(shell LC_ALL=C git log | grep -m1 Date | awk -FDate: '{ print $2 }' | sed -e 's|  ||g')|" \
		$${TODIR}/index.html.in > $${TODIR}/index.$${LANGUAGE}.html; \
		rm $${TODIR}/index.html.in; \
	done

commit: tidy test
	$(MAKE) -C manual rebuild
	$(MAKE) info

info:
	@echo
	@echo "live-manual is currently being translated into $(shell ls manual/po | wc -w) languages."
	@echo "The translation of these languages is complete: $(shell manual/bin/show-complete-languages.sh)"
	@echo "There are $(shell manual/bin/count-untranslated-strings.sh) untranslated strings. You can run 'make translate'."
	
	@if grep -qs fuzzy manual/po/*/*; \
	then \
		echo "There are $(shell grep -w 'fuzzy' manual/po/*/* | wc -l) fuzzy strings. You can run 'make fixfuzzy'." ; \
	fi
	
	@echo
	@echo "You may now proceed...please do:"
	@echo
	@echo "  * git add ."
	@echo "  * git commit -m \"Your commit message.\""
	@echo "  * git push "

install:
	rm -f $(CURDIR)/build/manual/index.html
	mkdir -p $(DESTDIR)/usr/share/doc/live-manual
	cp -a COPYING $(CURDIR)/build/manual/* $(DESTDIR)/usr/share/doc/live-manual

uninstall:
	rm -rf $(DESTDIR)/usr/share/doc/live-manual

clean:
	rm -rf build
	rm -f manual/en/*~
	rm -f manual/po/*/*~
	rm -f manual/po/*/*.mo

distclean: clean
	rm -rf build

rebuild: distclean build

fixfuzzy:
	@if grep -qs fuzzy manual/po/*/*; \
	then \
		./manual/bin/find-fuzzy.sh ; \
	else \
		echo "There are no fuzzy strings to translate." ; \
	fi

check:
	@./manual/bin/po-integrity-check.sh

translate:
	@./manual/bin/find-untranslated.sh

spell:
	@./manual/bin/check-spelling.sh
