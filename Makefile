# Makefile

SHELL := sh -e

LANGUAGES = en $(shell cd manual/po && ls)

DEBUG = 0

all: build

test:
	@echo "Checking for syntax errors... [not implemented yet - FIXME]"
	@echo "Checking for spelling errors... [not implemented yet - FIXME]"

tidy:
	# Removing useless whitespaces at EOL
	for FILE in manual/en/*.ssm manual/en/*.ssi; \
	do \
		sed -i -e 's|[ \t]*$$||' $${FILE}; \
	done

build:
	#FIXME: do a proper dependency-based build
	#FORMATS = epub html odf pdf txt
	#...
	#%.pdf: $(sisu_sources)
	#	sisu-pdf -v live-manual.ssm
	#etc.

	@# FIXME: sisu-concordance sisu-pg sisu-sqlite
	for LANGUAGE in $(LANGUAGES); \
	do \
		cd $(CURDIR)/manual/$${LANGUAGE}; \
		sisu-epub -v live-manual.ssm; \
		sisu-html -v live-manual.ssm; \
		sisu-odf -v live-manual.ssm; \
		sisu-pdf -v live-manual.ssm; \
		sisu-txt -v live-manual.ssm; \
	done
#               for FILE in build/manual/live-manual/*.$${LANGUAGE}.html; \
#		do \
#			../bin/fix-sisu-html.rb $${FILE}; \
#			([ $(DEBUG) -gt 0 ] || rm -f $${FILE}~); \
#		done; \

autobuild: clean build
	rm -rf build
	cp -a html build
	cp -a manual/en/_sisu build

	set +e; for LANGUAGE in $(LANGUAGES); \
	do \
		FROMDIR=$(CURDIR)/manual/$${LANGUAGE}/build/manual; \
		TODIR=$(CURDIR)/build; \
		mkdir -p $${TODIR}; \
		cd $${TODIR}; \
		mkdir -p epub; \
		cp $${FROMDIR}/epub/live-manual.$${LANGUAGE}.epub epub; \
		mkdir -p html; \
		cp $${FROMDIR}/live-manual/*.$${LANGUAGE}.html html; \
		mv html/scroll.$${LANGUAGE}.html html/live-manual.$${LANGUAGE}.html; \
		rm -f html/toc.$${LANGUAGE}.html html/sisu_manifest.$${LANGUAGE}.html html/metadata.$${LANGUAGE}.html; \
		mkdir -p odf; \
		cp $${FROMDIR}/live-manual/opendocument.$${LANGUAGE}.odt odf/live-manual.$${LANGUAGE}.odt; \
		mkdir -p pdf; \
		cp $${FROMDIR}/live-manual/landscape.$${LANGUAGE}.a4.pdf pdf/live-manual.landscape-a4.$${LANGUAGE}.pdf; \
		cp $${FROMDIR}/live-manual/portrait.$${LANGUAGE}.a4.pdf pdf/live-manual.portrait-a4.$${LANGUAGE}.pdf; \
		cp $${FROMDIR}/live-manual/landscape.$${LANGUAGE}.letter.pdf pdf/live-manual.landscape-letter.$${LANGUAGE}.pdf; \
		cp $${FROMDIR}/live-manual/portrait.$${LANGUAGE}.letter.pdf pdf/live-manual.portrait-letter.$${LANGUAGE}.pdf; \
		mkdir -p txt; \
		cp $${FROMDIR}/live-manual/plain.$${LANGUAGE}.txt txt/live-manual.$${LANGUAGE}.txt; \
		sed -e "s|@DATE_BUILD@|$(shell LC_ALL=C date -R)|" \
		    -e "s|@DATE_CHANGE@|$(shell LC_ALL=C git log | grep -m1 Date | awk -FDate: '{ print $2 }' | sed -e 's|  ||g')|" \
		    $${FROMDIR}/../../index.html.in > index.$${LANGUAGE}.html; \
	done

commit: tidy test
	$(MAKE) -C manual rebuild

	@if grep -qs fuzzy manual/po/*/*; \
	then \
		echo "Please fix fuzzy in manual/po/* first."; \
		exit 1; \
	fi

	@echo
	@echo "Successful... please do:"
	@echo
	@echo "  * git add ."
	@echo "  * git commit -a -m \"Your commit message.\""
	@echo "  * git push"

install:

	for LANGUAGE in $(LANGUAGES); \
	do \
		FROMDIR=$(CURDIR)/manual/$${LANGUAGE}/build/manual; \
		TODIR=$(DESTDIR)/usr/share/doc/live-manual; \
		mkdir -p $${TODIR}; \
		cd $${TODIR}; \
		mkdir -p epub; \
		cp $${FROMDIR}/epub/live-manual.$${LANGUAGE}.epub epub; \
		mkdir -p html; \
		cp $${FROMDIR}/live-manual/*.$${LANGUAGE}.html html; \
		mv html/scroll.$${LANGUAGE}.html html/live-manual.$${LANGUAGE}.html; \
		rm -f html/toc.$${LANGUAGE}.html html/sisu_manifest.$${LANGUAGE}.html html/metadata.$${LANGUAGE}.html; \
		mkdir -p odf; \
		cp $${FROMDIR}/live-manual/opendocument.$${LANGUAGE}.odt odf/live-manual.$${LANGUAGE}.odt; \
		mkdir -p txt; \
		cp $${FROMDIR}/live-manual/plain.$${LANGUAGE}.txt txt/live-manual.$${LANGUAGE}.txt; \
		mkdir -p pdf; \
		cp $${FROMDIR}/live-manual/landscape.$${LANGUAGE}.a4.pdf pdf/live-manual.landscape-a4.$${LANGUAGE}.pdf; \
		cp $${FROMDIR}/live-manual/portrait.$${LANGUAGE}.a4.pdf pdf/live-manual.portrait-a4.$${LANGUAGE}.pdf; \
		cp $${FROMDIR}/live-manual/landscape.$${LANGUAGE}.letter.pdf pdf/live-manual.landscape-letter.$${LANGUAGE}.pdf; \
		cp $${FROMDIR}/live-manual/portrait.$${LANGUAGE}.letter.pdf pdf/live-manual.portrait-letter.$${LANGUAGE}.pdf; \
	done

	cp -a manual/en/_sisu $(DESTDIR)/usr/share/doc/live-manual

uninstall:
	rm -rf $(DESTDIR)/usr/share/doc/live-manual

clean:
	rm -rf manual/*/build

distclean: clean
	rm -rf build

rebuild: distclean build
